namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class QrCodeRecord
{
    public int Id { get; set; } // QR kod kaydının benzersiz kimlik numarası

    public string Code { get; set; } = string.Empty; // QR kodun içinde tutulacak benzersiz kod değeri

    public int StudyTableId { get; set; } // Bu QR kodun hangi masaya ait olduğunu belirtir

    public StudyTable? StudyTable { get; set; } // StudyTable tablosu ile ilişki kurmak için kullanılır

    public bool IsActive { get; set; } = true; // QR kodun aktif kullanılıp kullanılmadığını belirtir

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // QR kod kaydının oluşturulma tarihi
}