using LibrarySeatTrackingAPI.Common.Enums; // IssueStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class UpdateIssueReportStatusDto
{
    public IssueStatus Status { get; set; } // Sorun bildiriminin yeni durumu
}