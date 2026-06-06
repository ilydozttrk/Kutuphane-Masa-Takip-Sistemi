namespace LibrarySeatTrackingAPI.Domain; // Domain klasörüne ait olduğunu belirtir

public class NotificationLog
{
    public int Id { get; set; } // Bildirim kaydının benzersiz Id bilgisi

    public int UserId { get; set; } // Bildirimin gönderileceği kullanıcının Id bilgisi

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır

    public int? ReservationId { get; set; } // Bildirim bir rezervasyona bağlıysa rezervasyon Id bilgisini tutar

    public Reservation? Reservation { get; set; } // Reservation tablosu ile ilişki kurmak için kullanılır

    public string Title { get; set; } = string.Empty; // Bildirimin başlığı

    public string Message { get; set; } = string.Empty; // Bildirimin mesaj içeriği

    public string Type { get; set; } = string.Empty; // Bildirim türü: ReservationReminder55, ReservationReminder65, AutoCompleted gibi

    public bool IsRead { get; set; } = false; // Kullanıcı bildirimi okudu mu bilgisini tutar

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Bildirimin oluşturulma tarihi
}