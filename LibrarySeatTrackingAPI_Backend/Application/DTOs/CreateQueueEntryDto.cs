namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class CreateQueueEntryDto
{
    public int StudyTableId { get; set; } // Öğrencinin sıraya girmek istediği masanın Id bilgisi
}