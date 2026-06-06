using LibrarySeatTrackingAPI.Common.Enums; // IssueStatus enumunu kullanmak için ekledik

namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class IssueReport
{
    public int Id { get; set; } // Sorun bildiriminin benzersiz kimlik numarası

    public int UserId { get; set; } // Sorunu bildiren kullanıcının Id bilgisi

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır

    public int StudyTableId { get; set; } // Sorun bildirilen masanın Id bilgisi

    public StudyTable? StudyTable { get; set; } // StudyTable tablosu ile ilişki kurmak için kullanılır

    public string Description { get; set; } = string.Empty; // Kullanıcının yazdığı sorun açıklaması

    public IssueStatus Status { get; set; } = IssueStatus.Open; // Sorunun mevcut durumu: açık, inceleniyor, çözüldü veya reddedildi

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Sorun bildiriminin oluşturulma tarihi
}