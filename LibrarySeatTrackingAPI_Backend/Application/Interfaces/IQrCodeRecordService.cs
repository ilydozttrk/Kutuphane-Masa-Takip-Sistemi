using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface IQrCodeRecordService
{
    Task<ApiResponseDto<QrCodeRecordResponseDto>> CreateAsync(CreateQrCodeRecordDto request); // Yeni QR kod kaydı oluşturur

    Task<ApiResponseDto<List<QrCodeRecordResponseDto>>> GetAllAsync(); // Tüm QR kod kayıtlarını listeler

    Task<ApiResponseDto<QrCodeRecordResponseDto>> UpdateStatusAsync(int qrCodeRecordId, UpdateQrCodeStatusDto request); // Admin/Staff QR kodu aktif veya pasif yapar
    Task<ApiResponseDto<QrCodeFileDto>> GetQrCodePngAsync(int qrCodeRecordId);
}
