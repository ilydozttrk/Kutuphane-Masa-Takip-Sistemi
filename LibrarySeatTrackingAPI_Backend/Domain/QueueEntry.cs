using LibrarySeatTrackingAPI.Common.Enums; // QueueStatus enumunu kullanmak için ekledik

namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class QueueEntry
{
    public int Id { get; set; } // Sıra kaydının benzersiz kimlik numarası

    public int UserId { get; set; } // Sıraya giren kullanıcının Id bilgisi

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır

    public int StudyTableId { get; set; } // Sıraya girilen masanın Id bilgisi

    public StudyTable? StudyTable { get; set; } // StudyTable tablosu ile ilişki kurmak için kullanılır

    public QueueStatus Status { get; set; } = QueueStatus.Waiting; // Sıra kaydının mevcut durumu

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Kullanıcının sıraya girdiği tarih
}