namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class CreateStudyTableDto
{
    public string Code { get; set; } = string.Empty; // Masanın görünen kodu: örnek A-101, B-205

    public int LocationAreaId { get; set; } // Masanın hangi konum alanına bağlı olacağını belirtir
}