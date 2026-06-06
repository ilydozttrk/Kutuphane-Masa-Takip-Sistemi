namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class QrCodeRecordResponseDto
{
    public int Id { get; set; } // QR kod kaydının benzersiz Id bilgisi

    public string Code { get; set; } = string.Empty; // QR kodun içinde tutulan benzersiz kod değeri

    public int StudyTableId { get; set; } // QR kodun bağlı olduğu masanın Id bilgisi

    public string StudyTableCode { get; set; } = string.Empty; // QR kodun bağlı olduğu masanın görünen kodu

    public bool IsActive { get; set; } // QR kodun aktif olup olmadığını belirtir

    public DateTime CreatedAt { get; set; } // QR kod kaydının oluşturulma tarihi
}