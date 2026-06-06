namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class UpdateQrCodeStatusDto
{
    public bool IsActive { get; set; } // QR kodun aktif mi pasif mi olacağını belirtir
}