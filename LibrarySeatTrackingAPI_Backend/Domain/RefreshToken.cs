namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class RefreshToken
{
    public int Id { get; set; } // Refresh token kaydının benzersiz kimlik numarası

    public string Token { get; set; } = string.Empty; // Kullanıcıya verilen refresh token değeri

    public DateTime ExpiresAt { get; set; } // Refresh tokenın geçerlilik bitiş tarihi

    public bool IsRevoked { get; set; } = false; // Tokenın iptal edilip edilmediğini tutar

    public int UserId { get; set; } // Bu tokenın hangi kullanıcıya ait olduğunu belirtir

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır
}