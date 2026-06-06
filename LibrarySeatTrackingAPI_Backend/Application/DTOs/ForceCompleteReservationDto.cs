namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class ForceCompleteReservationDto
{
    public string Note { get; set; } = string.Empty; // Görevli veya adminin rezervasyonu neden sonlandırdığını açıklayan not
}