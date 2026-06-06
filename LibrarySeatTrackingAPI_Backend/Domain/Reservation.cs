using LibrarySeatTrackingAPI.Common.Enums; // ReservationStatus enumunu kullanmak için ekledik

namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class Reservation
{
    public int Id { get; set; } // Rezervasyon kaydının benzersiz kimlik numarası

    public int UserId { get; set; } // Rezervasyonu yapan kullanıcının Id bilgisi

    public User? User { get; set; } // User tablosu ile ilişki kurmak için kullanılır

    public int StudyTableId { get; set; } // Rezerve edilen masanın Id bilgisi

    public StudyTable? StudyTable { get; set; } // StudyTable tablosu ile ilişki kurmak için kullanılır

    public DateTime StartTime { get; set; } = DateTime.UtcNow; // Masa kullanımının başlama zamanı

    public DateTime EndTime { get; set; } // Masa kullanımının bitiş zamanı

    public ReservationStatus Status { get; set; } = ReservationStatus.Active; // Rezervasyonun mevcut durumu
    public string? StaffNote { get; set; } // Görevli veya admin tarafından rezervasyon sonlandırılırsa açıklama notunu tutar

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Rezervasyon kaydının oluşturulma tarihi

    public int RenewCount { get; set; } = 0; // Kullanıcının oturumu kaç kez yenilediğini tutar

    public DateTime LastRenewedAt { get; set; } = DateTime.UtcNow; // Oturumun en son ne zaman yenilendiğini tutar
}