namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateBlockRecordDto
{
    public int UserId { get; set; } // Bloke edilecek kullanıcının Id bilgisi

    public string Reason { get; set; } = string.Empty; // Kullanıcının neden bloke edildiğini açıklar

    public DateTime? EndsAt { get; set; } // Blokenin biteceği tarih, süresizse boş bırakılabilir
}