using LibrarySeatTrackingAPI.Common.Enums; // ReservationStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class ReservationResponseDto
{
    public int Id { get; set; } // Rezervasyon kaydının benzersiz Id bilgisi

    public int UserId { get; set; } // Rezervasyonu yapan kullanıcının Id bilgisi

    public string UserFullName { get; set; } = string.Empty; // Rezervasyonu yapan kullanıcının adı soyadı

    public int StudyTableId { get; set; } // Rezerve edilen masanın Id bilgisi

    public string StudyTableCode { get; set; } = string.Empty; // Rezerve edilen masanın görünen kodu

    public DateTime StartTime { get; set; } // Masa kullanımının başlama zamanı

    public DateTime EndTime { get; set; } // Masa kullanımının bitiş zamanı

    public ReservationStatus Status { get; set; } // Rezervasyonun mevcut durumu
    public string? StaffNote { get; set; } // Görevli veya admin tarafından yazılan sonlandırma notu
}