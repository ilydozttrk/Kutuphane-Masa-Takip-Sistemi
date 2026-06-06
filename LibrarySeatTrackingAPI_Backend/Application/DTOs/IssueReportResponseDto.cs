using LibrarySeatTrackingAPI.Common.Enums; // IssueStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class IssueReportResponseDto
{
    public int Id { get; set; } // Sorun bildiriminin benzersiz Id bilgisi

    public int UserId { get; set; } // Sorunu bildiren kullanıcının Id bilgisi

    public string UserFullName { get; set; } = string.Empty; // Sorunu bildiren kullanıcının adı soyadı

    public int StudyTableId { get; set; } // Sorun bildirilen masanın Id bilgisi

    public string StudyTableCode { get; set; } = string.Empty; // Sorun bildirilen masanın görünen kodu

    public string Description { get; set; } = string.Empty; // Sorun açıklaması

    public IssueStatus Status { get; set; } // Sorunun mevcut durumu: Open, InProgress, Resolved veya Rejected

    public DateTime CreatedAt { get; set; } // Sorun bildiriminin oluşturulma tarihi
}