namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class NotificationLogResponseDto
{
    public int Id { get; set; } // Bildirim kaydının Id bilgisi

    public int UserId { get; set; } // Bildirimin ait olduğu kullanıcı Id bilgisi

    public int? ReservationId { get; set; } // Bildirim rezervasyona bağlıysa rezervasyon Id bilgisi

    public string Title { get; set; } = string.Empty; // Bildirim başlığı

    public string Message { get; set; } = string.Empty; // Bildirim mesajı

    public string Type { get; set; } = string.Empty; // Bildirim türü

    public bool IsRead { get; set; } // Bildirim okundu mu bilgisi

    public DateTime CreatedAt { get; set; } // Bildirimin oluşturulma tarihi
}