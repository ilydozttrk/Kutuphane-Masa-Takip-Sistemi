namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class LoginRequestDto
{
    public string Email { get; set; } = string.Empty; // Kullanıcının giriş yaparken yazdığı e-posta adresi

    public string Password { get; set; } = string.Empty; // Kullanıcının giriş yaparken yazdığı düz şifre
}