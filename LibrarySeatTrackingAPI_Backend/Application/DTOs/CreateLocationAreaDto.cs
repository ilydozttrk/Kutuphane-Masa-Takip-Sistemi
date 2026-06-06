namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class CreateLocationAreaDto
{
    public string Name { get; set; } = string.Empty; // Oluşturulacak konum alanının adı

    public double Latitude { get; set; } // Konum alanının merkez enlem bilgisi

    public double Longitude { get; set; } // Konum alanının merkez boylam bilgisi

    public int RadiusMeters { get; set; } // Konum doğrulamada kabul edilecek yarıçap, metre cinsinden
}