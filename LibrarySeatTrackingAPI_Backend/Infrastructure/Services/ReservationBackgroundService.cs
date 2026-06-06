using LibrarySeatTrackingAPI.Application.Interfaces; // IPushNotificationService kullanmak için
using LibrarySeatTrackingAPI.Common.Enums; // ReservationStatus ve TableStatus enumlarını kullanmak için
using LibrarySeatTrackingAPI.Domain; // NotificationLog entity'sini kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, ToListAsync için

namespace LibrarySeatTrackingAPI.Infrastructure.Services; // Infrastructure/Services klasörüne ait olduğunu belirtir

public class ReservationBackgroundService : BackgroundService // Arka planda sürekli çalışan servis
{
    private readonly IServiceScopeFactory _scopeFactory; // Scoped servisleri background service içinde kullanmak için

    public ReservationBackgroundService(IServiceScopeFactory scopeFactory) // Bağımlılığı dışarıdan alır
    {
        _scopeFactory = scopeFactory; // ScopeFactory nesnesini sınıf içinde saklar
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken) // Background service çalışınca tetiklenir
    {
        while (!stoppingToken.IsCancellationRequested) // Uygulama kapanmadığı sürece döner
        {
            await CheckReservationsAsync(stoppingToken); // Aktif rezervasyonları kontrol eder

            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken); // Her 1 dakikada bir kontrol eder
        }
    }

    private async Task CheckReservationsAsync(CancellationToken stoppingToken) // Rezervasyon sürelerini kontrol eder
    {
        using var scope = _scopeFactory.CreateScope(); // Yeni scope oluşturur

        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>(); // DbContext alır

        var pushNotificationService = scope.ServiceProvider.GetRequiredService<IPushNotificationService>(); // Push notification servisini alır

        var now = DateTime.UtcNow; // Şu anki zamanı alır

        var activeReservations = await db.Reservations // Reservations tablosundan sorgu başlatır
            .Include(x => x.StudyTable) // Rezervasyonun masasını getirir
            .Where(x => x.Status == ReservationStatus.Active) // Sadece aktif rezervasyonları alır
            .ToListAsync(stoppingToken); // Listeye çevirir

        foreach (var reservation in activeReservations) // Her aktif rezervasyonu gezer
        {
            var elapsedMinutes = (now - reservation.LastRenewedAt).TotalMinutes; // Son yenilemeden itibaren geçen dakika

            if (elapsedMinutes >= 55) // 55 dakika geçtiyse
            {
                var added = await AddNotificationIfNotExistsAsync(
                    db,
                    reservation,
                    "ReservationReminder55",
                    "Oturumunuz dolmak üzere",
                    "Oturumunuz dolmak üzere. Lütfen devam etmek için yeniden QR kod okutunuz.",
                    stoppingToken); // 55. dakika bildirimi ekler

                if (added) // Bildirim yeni eklendiyse
                {
                    await pushNotificationService.SendToUserAsync(
                        reservation.UserId,
                        "Oturumunuz dolmak üzere",
                        "Oturumunuz dolmak üzere. Lütfen devam etmek için yeniden QR kod okutunuz."); // Telefona push gönderir
                }
            }

            if (elapsedMinutes >= 65) // 65 dakika geçtiyse
            {
                var added = await AddNotificationIfNotExistsAsync(
                    db,
                    reservation,
                    "ReservationReminder65",
                    "Oturumunuz dolmak üzere",
                    "Oturumunuz dolmak üzere. Lütfen devam etmek için yeniden QR kod okutunuz.",
                    stoppingToken); // 65. dakika bildirimi ekler

                if (added) // Bildirim yeni eklendiyse
                {
                    await pushNotificationService.SendToUserAsync(
                        reservation.UserId,
                        "Oturumunuz dolmak üzere",
                        "Oturumunuz dolmak üzere. Lütfen devam etmek için yeniden QR kod okutunuz."); // Telefona push gönderir
                }
            }

            if (elapsedMinutes >= 70) // 70 dakika geçtiyse
            {
                reservation.Status = ReservationStatus.Completed; // Rezervasyonu tamamlandı yapar

                reservation.EndTime = now; // Bitiş zamanını şu an yapar

                if (reservation.StudyTable is not null) // Masa varsa
                {
                    reservation.StudyTable.Status = TableStatus.Available; // Masayı boşa çıkarır
                }

                var added = await AddNotificationIfNotExistsAsync(
                    db,
                    reservation,
                    "ReservationAutoCompleted",
                    "Oturum sonlandırıldı",
                    "Oturumunuz yenilenmediği için otomatik olarak sonlandırıldı.",
                    stoppingToken); // Otomatik sonlandırma bildirimi ekler

                if (added) // Bildirim yeni eklendiyse
                {
                    await pushNotificationService.SendToUserAsync(
                        reservation.UserId,
                        "Oturum sonlandırıldı",
                        "Oturumunuz yenilenmediği için otomatik olarak sonlandırıldı."); // Telefona push gönderir
                }
            }
        }

        await db.SaveChangesAsync(stoppingToken); // Tüm değişiklikleri veritabanına kaydeder
    }

    private static async Task<bool> AddNotificationIfNotExistsAsync(
        ApplicationDbContext db,
        Reservation reservation,
        string type,
        string title,
        string message,
        CancellationToken stoppingToken) // Aynı bildirim daha önce eklenmemişse ekler
    {
        var exists = await db.NotificationLogs.AnyAsync(x =>
            x.ReservationId == reservation.Id &&
            x.Type == type,
            stoppingToken); // Aynı rezervasyon için aynı tip bildirim var mı kontrol eder

        if (exists) // Bildirim zaten varsa
        {
            return false; // Yeni bildirim eklenmedi
        }

        var notification = new NotificationLog // Yeni bildirim kaydı oluşturur
        {
            UserId = reservation.UserId, // Bildirim gönderilecek kullanıcı Id bilgisi

            ReservationId = reservation.Id, // Bildirimin bağlı olduğu rezervasyon Id bilgisi

            Title = title, // Bildirim başlığı

            Message = message, // Bildirim mesajı

            Type = type, // Bildirim tipi

            IsRead = false // Bildirim başlangıçta okunmamış olur
        };

        db.NotificationLogs.Add(notification); // Bildirimi veritabanına eklenmek üzere hazırlar

        return true; // Yeni bildirim eklendi
    }
}