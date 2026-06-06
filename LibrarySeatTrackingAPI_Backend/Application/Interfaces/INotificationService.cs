using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Interfaces klasörüne ait olduğunu belirtir

public interface INotificationService
{
    Task<ApiResponseDto<List<NotificationLogResponseDto>>> GetMyNotificationsAsync(int userId); // Kullanıcının kendi bildirimlerini listeler

    Task<ApiResponseDto<string>> MarkAsReadAsync(int notificationId, int userId); // Kullanıcının bir bildirimi okundu yapmasını sağlar
}