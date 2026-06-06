namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class CreateIssueReportDto
{
    public int StudyTableId { get; set; } // Sorun bildirilecek masanın Id bilgisi

    public string Description { get; set; } = string.Empty; // Kullanıcının yazdığı sorun açıklaması
}