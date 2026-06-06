using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Interfaces klasörüne ait olduğunu belirtir

public interface IBlockRecordService
{
    Task<ApiResponseDto<BlockRecordResponseDto>> CreateAsync(CreateBlockRecordDto request); // Admin kullanıcının bloke edilmesini sağlar

    Task<ApiResponseDto<List<BlockRecordResponseDto>>> GetAllAsync(); // Tüm bloke kayıtlarını listeler

    Task<ApiResponseDto<BlockRecordResponseDto>> RemoveBlockAsync(int blockRecordId); // Aktif blokeyi kaldırır
}