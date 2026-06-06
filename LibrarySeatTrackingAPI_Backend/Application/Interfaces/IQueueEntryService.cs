using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface IQueueEntryService
{
    Task<ApiResponseDto<QueueEntryResponseDto>> CreateAsync(CreateQueueEntryDto request, int userId); // Öğrencinin masa için sıraya girmesini sağlar

    Task<ApiResponseDto<List<QueueEntryResponseDto>>> GetMyQueueEntriesAsync(int userId); // Giriş yapan öğrencinin kendi sıra kayıtlarını listeler

    Task<ApiResponseDto<List<QueueEntryResponseDto>>> GetAllAsync(); // Admin veya Staff için tüm sıra kayıtlarını listeler
    Task<ApiResponseDto<QueueEntryResponseDto>> UpdateStatusAsync(int queueEntryId, UpdateQueueEntryStatusDto request); // Admin/Staff sıra kaydının durumunu günceller
}