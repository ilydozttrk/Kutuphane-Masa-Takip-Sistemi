using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Interfaces klasörüne ait olduğunu belirtir

public interface IUserDeviceTokenService
{
    Task<ApiResponseDto<string>> RegisterAsync(RegisterDeviceTokenDto request, int userId); // Kullanıcının mobil cihaz FCM tokenını kaydeder
}