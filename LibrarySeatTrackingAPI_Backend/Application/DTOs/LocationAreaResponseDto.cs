namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class LocationAreaResponseDto
{
    public int Id { get; set; } // Konum alanının benzersiz Id bilgisi

    public string Name { get; set; } = string.Empty; // Konum alanının adı

    public double Latitude { get; set; } // Konum alanının merkez enlem bilgisi

    public double Longitude { get; set; } // Konum alanının merkez boylam bilgisi

    public int RadiusMeters { get; set; } // Konum doğrulama yarıçapı, metre cinsinden

    public bool IsActive { get; set; } // Konum alanının aktif olup olmadığını belirtir

    public DateTime CreatedAt { get; set; } // Konum alanının oluşturulma tarihi
}