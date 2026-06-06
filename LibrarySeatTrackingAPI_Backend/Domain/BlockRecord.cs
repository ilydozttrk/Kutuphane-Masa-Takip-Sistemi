namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class BlockRecord
{
    public int Id { get; set; } // Bloke kaydının benzersiz kimlik numarası

    public int UserId { get; set; } // Bloke edilen kullanıcının Id bilgisi

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır

    public string Reason { get; set; } = string.Empty; // Kullanıcının neden bloke edildiğini tutar

    public DateTime BlockedAt { get; set; } = DateTime.UtcNow; // Blokenin başladığı tarih

    public DateTime? EndsAt { get; set; } // Blokenin biteceği tarih, süresizse boş olabilir

    public bool IsActive { get; set; } = true; // Blokenin şu an aktif olup olmadığını belirtir
}