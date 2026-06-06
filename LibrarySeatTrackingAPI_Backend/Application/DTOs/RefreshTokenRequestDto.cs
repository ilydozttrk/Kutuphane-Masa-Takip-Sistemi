namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class RefreshTokenRequestDto
{
    public string RefreshToken { get; set; } = string.Empty; // Yeni access token almak için gönderilecek refresh token değeri
}