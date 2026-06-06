using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface IIssueReportService
{
    Task<ApiResponseDto<IssueReportResponseDto>> CreateAsync(CreateIssueReportDto request, int userId); // Öğrenci veya görevlinin sorun bildirimi oluşturmasını sağlar

    Task<ApiResponseDto<List<IssueReportResponseDto>>> GetAllAsync(); // Admin veya Staff için tüm sorun bildirimlerini listeler

    Task<ApiResponseDto<List<IssueReportResponseDto>>> GetMyReportsAsync(int userId); // Giriş yapan kullanıcının kendi sorun bildirimlerini listeler
    Task<ApiResponseDto<IssueReportResponseDto>> UpdateStatusAsync(int issueReportId, UpdateIssueReportStatusDto request); // Admin/Staff sorun bildirimi durumunu günceller
}