using LibrarySeatTrackingAPI.Common.Enums; // QueueStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class QueueEntryResponseDto
{
    public int Id { get; set; } // Sıra kaydının benzersiz Id bilgisi

    public int UserId { get; set; } // Sıraya giren kullanıcının Id bilgisi

    public string UserFullName { get; set; } = string.Empty; // Sıraya giren kullanıcının adı soyadı

    public int StudyTableId { get; set; } // Sıraya girilen masanın Id bilgisi

    public string StudyTableCode { get; set; } = string.Empty; // Sıraya girilen masanın görünen kodu

    public QueueStatus Status { get; set; } // Sıra kaydının durumu: Waiting, Notified, Completed veya Cancelled

    public DateTime CreatedAt { get; set; } // Kullanıcının sıraya girdiği tarih
}