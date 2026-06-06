namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class LoginResponseDto
{
    public int UserId { get; set; } // Giriş yapan kullanıcının Id bilgisi

    public string FullName { get; set; } = string.Empty; // Giriş yapan kullanıcının adı soyadı

    public string Email { get; set; } = string.Empty; // Giriş yapan kullanıcının e-posta adresi

    public string Role { get; set; } = string.Empty; // Giriş yapan kullanıcının rol bilgisi

    public string AccessToken { get; set; } = string.Empty; // API isteklerinde kullanılacak JWT access token

    public string RefreshToken { get; set; } = string.Empty; // Access token süresi bitince yenileme için kullanılacak token
}