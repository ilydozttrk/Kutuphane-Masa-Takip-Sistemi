using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface IStudyTableService
{
    Task<ApiResponseDto<StudyTableResponseDto>> CreateAsync(CreateStudyTableDto request); // Yeni masa oluşturur

    Task<ApiResponseDto<List<StudyTableResponseDto>>> GetAllAsync(); // Tüm masaları listeler
    Task<ApiResponseDto<StudyTableResponseDto>> UpdateStatusAsync(int studyTableId, UpdateStudyTableStatusDto request); // Admin masanın durumunu günceller
}