using LibrarySeatTrackingAPI.Application.DTOs; // ApiResponseDto kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Interfaces klasörüne ait olduğunu belirtir

public interface IPushNotificationService
{
    Task<ApiResponseDto<string>> SendToUserAsync(int userId, string title, string message); // Belirli kullanıcıya push bildirim gönderir
}