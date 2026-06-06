namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class RegisterDeviceTokenDto
{
    public string Token { get; set; } = string.Empty; // Mobil uygulamadan gelen Firebase FCM cihaz tokenı

    public string? DeviceName { get; set; } // Cihaz adı: örnek iPhone 13, Samsung A52
}