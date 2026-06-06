namespace LibrarySeatTrackingAPI.Domain; // Domain klasörüne ait olduğunu belirtir

public class UserDeviceToken
{
    public int Id { get; set; } // Cihaz token kaydının benzersiz Id bilgisi

    public int UserId { get; set; } // Tokenın hangi kullanıcıya ait olduğunu belirtir

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır

    public string Token { get; set; } = string.Empty; // Firebase Cloud Messaging cihaz tokenı

    public string? DeviceName { get; set; } // Cihaz adı: örnek iPhone 13, Samsung A52

    public bool IsActive { get; set; } = true; // Token aktif mi pasif mi bilgisini tutar

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Tokenın ilk kaydedildiği tarih

    public DateTime? LastUsedAt { get; set; } // Tokenın en son ne zaman güncellendiğini/kullanıldığını tutar
}