using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface IReservationService
{
    Task<ApiResponseDto<ReservationResponseDto>> CreateAsync(CreateReservationDto request, int userId); // Öğrencinin QR kod ile masa almasını sağlar

    Task<ApiResponseDto<List<ReservationResponseDto>>> GetMyReservationsAsync(int userId); // Giriş yapan kullanıcının kendi rezervasyonlarını listeler

    Task<ApiResponseDto<ReservationResponseDto>> CompleteAsync(int reservationId, int userId); // Öğrencinin aktif rezervasyonunu sonlandırır

    Task<ApiResponseDto<ReservationResponseDto>> ForceCompleteAsync(int reservationId, ForceCompleteReservationDto request); // Staff veya Admin tarafından aktif rezervasyonu açıklama ile sonlandırır
    Task<ApiResponseDto<ReservationResponseDto>> RenewAsync(RenewReservationDto request, int userId); // Öğrencinin QR kod ile aktif oturumunu yenilemesini sağlar

}