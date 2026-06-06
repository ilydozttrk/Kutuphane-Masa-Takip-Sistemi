namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class CreateQrCodeRecordDto
{
    public string Code { get; set; } = string.Empty; // QR kodun içinde tutulacak benzersiz kod değeri

    public int StudyTableId { get; set; } // QR kodun hangi masaya bağlı olacağını belirtir
}