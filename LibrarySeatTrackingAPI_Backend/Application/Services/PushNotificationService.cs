using FirebaseAdmin.Messaging; // FirebaseMessaging ve Message sınıfları için
using LibrarySeatTrackingAPI.Application.DTOs; // ApiResponseDto kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IPushNotificationService interface'i için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // ToListAsync için

namespace LibrarySeatTrackingAPI.Application.Services; // Services klasörüne ait olduğunu belirtir

public class PushNotificationService : IPushNotificationService // PushNotificationService, IPushNotificationService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public PushNotificationService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde saklar
    }

    public async Task<ApiResponseDto<string>> SendToUserAsync(int userId, string title, string message) // Belirli kullanıcıya push bildirimi gönderir
    {
        var tokens = await _db.UserDeviceTokens // UserDeviceTokens tablosundan sorgu başlatır
            .Where(x => x.UserId == userId && x.IsActive) // Kullanıcının aktif cihaz tokenlarını filtreler
            .Select(x => x.Token) // Sadece token değerlerini alır
            .ToListAsync(); // Listeye çevirir

        if (!tokens.Any()) // Kullanıcının aktif cihaz tokenı yoksa
        {
            return new ApiResponseDto<string> // Standart cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "Active device token not found.", // Aktif cihaz tokenı bulunamadı
                Data = null // Veri dönülmez
            };
        }

        var successCount = 0; // Başarılı gönderim sayısını tutar
        var failedCount = 0; // Başarısız gönderim sayısını tutar

        foreach (var token in tokens) // Kullanıcının tüm aktif cihaz tokenlarını gezer
        {
            try // Firebase gönderiminde hata oluşabilir
            {
                var firebaseMessage = new Message // Firebase mesaj nesnesi oluşturur
                {
                    Token = token, // Bildirimin gönderileceği cihaz tokenı

                    Notification = new Notification // Telefonda görünecek bildirim içeriği
                    {
                        Title = title, // Bildirim başlığı

                        Body = message // Bildirim mesajı
                    },

                    Data = new Dictionary<string, string> // Mobil uygulamanın okuyabileceği ek veriler
                    {
                        { "title", title }, // Başlığı data olarak da gönderir

                        { "message", message }, // Mesajı data olarak da gönderir

                        { "type", "reservation_reminder" } // Bildirim tipini gönderir
                    }
                };

                await FirebaseMessaging.DefaultInstance.SendAsync(firebaseMessage); // Firebase üzerinden bildirimi gönderir

                successCount++; // Başarılı sayısını artırır
            }
            catch // Firebase gönderimi başarısız olursa
            {
                failedCount++; // Başarısız sayısını artırır
            }
        }

        return new ApiResponseDto<string> // Standart cevap döner
        {
            Success = successCount > 0, // En az bir cihaza gittiyse başarılı kabul eder

            Message = $"Push notification sent. Success: {successCount}, Failed: {failedCount}", // Gönderim sonucunu açıklar

            Data = "Push notification process completed." // İşlem sonucu
        };
    }
}