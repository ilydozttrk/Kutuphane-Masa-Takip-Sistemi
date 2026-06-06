using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface ILocationAreaService
{
    Task<ApiResponseDto<LocationAreaResponseDto>> CreateAsync(CreateLocationAreaDto request); // Yeni konum alanı oluşturur

    Task<ApiResponseDto<List<LocationAreaResponseDto>>> GetAllAsync(); // Tüm konum alanlarını listeler
}