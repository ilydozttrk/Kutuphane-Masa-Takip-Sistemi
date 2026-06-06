using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // INotificationService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // ToListAsync, FirstOrDefaultAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Services klasörüne ait olduğunu belirtir

public class NotificationService : INotificationService // NotificationService, INotificationService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public NotificationService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<List<NotificationLogResponseDto>>> GetMyNotificationsAsync(int userId) // Kullanıcının kendi bildirimlerini listeler
    {
        var notifications = await _db.NotificationLogs // NotificationLogs tablosundan sorgu başlatır
            .Where(x => x.UserId == userId) // Sadece giriş yapan kullanıcıya ait bildirimleri filtreler
            .OrderByDescending(x => x.CreatedAt) // En yeni bildirimler önce gelsin diye sıralar
            .Select(x => new NotificationLogResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Bildirim Id bilgisi
                UserId = x.UserId, // Kullanıcı Id bilgisi
                ReservationId = x.ReservationId, // Rezervasyon Id bilgisi
                Title = x.Title, // Bildirim başlığı
                Message = x.Message, // Bildirim mesajı
                Type = x.Type, // Bildirim tipi
                IsRead = x.IsRead, // Okundu bilgisi
                CreatedAt = x.CreatedAt // Oluşturulma tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<NotificationLogResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Notifications listed successfully.", // Başarı mesajı
            Data = notifications // Bildirim listesi
        };
    }

    public async Task<ApiResponseDto<string>> MarkAsReadAsync(int notificationId, int userId) // Bildirimi okundu yapar
    {
        var notification = await _db.NotificationLogs // NotificationLogs tablosundan sorgu başlatır
            .FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId); // Bildirim bu kullanıcıya mı ait kontrol eder

        if (notification is null) // Bildirim bulunamazsa
        {
            return new ApiResponseDto<string> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "Notification not found.", // Bildirim bulunamadı mesajı
                Data = null // Veri dönülmez
            };
        }

        notification.IsRead = true; // Bildirimi okundu yapar

        await _db.SaveChangesAsync(); // Değişikliği veritabanına kaydeder

        return new ApiResponseDto<string> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Notification marked as read.", // Başarı mesajı
            Data = "Notification read." // İşlem sonucu
        };
    }
}