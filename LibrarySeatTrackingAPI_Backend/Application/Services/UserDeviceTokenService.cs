using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IUserDeviceTokenService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Domain; // UserDeviceToken entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // FirstOrDefaultAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Services klasörüne ait olduğunu belirtir

public class UserDeviceTokenService : IUserDeviceTokenService // UserDeviceTokenService, IUserDeviceTokenService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public UserDeviceTokenService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<string>> RegisterAsync(RegisterDeviceTokenDto request, int userId) // Kullanıcının mobil cihaz FCM tokenını kaydeder
    {
        var existingToken = await _db.UserDeviceTokens // UserDeviceTokens tablosundan sorgu başlatır
            .FirstOrDefaultAsync(x => x.Token == request.Token); // Aynı token daha önce kayıtlı mı kontrol eder

        if (existingToken is not null) // Token zaten kayıtlıysa
        {
            existingToken.UserId = userId; // Tokenı mevcut kullanıcıya bağlar
            existingToken.DeviceName = request.DeviceName; // Cihaz adını günceller
            existingToken.IsActive = true; // Tokenı aktif yapar
            existingToken.LastUsedAt = DateTime.UtcNow; // Son kullanım zamanını günceller

            await _db.SaveChangesAsync(); // Güncellemeleri veritabanına kaydeder

            return new ApiResponseDto<string> // Başarılı cevap döner
            {
                Success = true, // İşlem başarılı
                Message = "Device token updated successfully.", // Token güncellendi mesajı
                Data = "Device token updated." // İşlem sonucu
            };
        }

        var deviceToken = new UserDeviceToken // Yeni cihaz token kaydı oluşturur
        {
            UserId = userId, // Tokenı giriş yapan kullanıcıya bağlar
            Token = request.Token, // Mobil uygulamadan gelen FCM tokenı kaydeder
            DeviceName = request.DeviceName, // Cihaz adını kaydeder
            IsActive = true, // Tokenı aktif başlatır
            LastUsedAt = DateTime.UtcNow // Son kullanım zamanını şu an yapar
        };

        _db.UserDeviceTokens.Add(deviceToken); // Yeni tokenı veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Tokenı veritabanına kaydeder

        return new ApiResponseDto<string> // Başarılı cevap döner
        {
            Success = true, // İşlem başarılı
            Message = "Device token registered successfully.", // Token kaydedildi mesajı
            Data = "Device token registered." // İşlem sonucu
        };
    }
}