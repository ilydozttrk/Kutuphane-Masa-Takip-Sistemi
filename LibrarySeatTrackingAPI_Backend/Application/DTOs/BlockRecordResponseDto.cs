namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class BlockRecordResponseDto
{
    public int Id { get; set; } // Bloke kaydının Id bilgisi

    public int UserId { get; set; } // Bloke edilen kullanıcının Id bilgisi

    public string UserFullName { get; set; } = string.Empty; // Bloke edilen kullanıcının adı soyadı

    public string UserEmail { get; set; } = string.Empty; // Bloke edilen kullanıcının e-posta adresi

    public string Reason { get; set; } = string.Empty; // Bloke nedeni

    public DateTime BlockedAt { get; set; } // Blokenin başladığı tarih

    public DateTime? EndsAt { get; set; } // Blokenin biteceği tarih, süresizse boş olabilir

    public bool IsActive { get; set; } // Blokenin aktif olup olmadığını belirtir
}