using LibrarySeatTrackingAPI.Application.DTOs; // LoginRequestDto, LoginResponseDto ve ApiResponseDto kullanmak için

namespace LibrarySeatTrackingAPI.Application.Interfaces; // Bu dosyanın Application/Interfaces katmanına ait olduğunu belirtir

public interface IAuthService
{
    Task<ApiResponseDto<LoginResponseDto>> LoginAsync(LoginRequestDto request); // Kullanıcının giriş yapmasını sağlayacak metot
    Task<ApiResponseDto<LoginResponseDto>> RefreshTokenAsync(RefreshTokenRequestDto request); // Refresh token ile yeni access token üretir
    Task<ApiResponseDto<string>> LogoutAsync(RefreshTokenRequestDto request); // Refresh tokenı iptal ederek çıkış yapar
}