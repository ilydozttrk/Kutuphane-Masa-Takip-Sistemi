namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class LocationArea
{
    public int Id { get; set; } // Konum alanının benzersiz kimlik numarası

    public string Name { get; set; } = string.Empty; // Alanın adı: örnek Merkez Kütüphane 1. Kat

    public double Latitude { get; set; } // Alanın merkez enlem bilgisi

    public double Longitude { get; set; } // Alanın merkez boylam bilgisi

    public int RadiusMeters { get; set; } // Bu alan için kabul edilen konum yarıçapı, metre cinsinden

    public bool IsActive { get; set; } = true; // Bu alanın sistemde aktif kullanılıp kullanılmadığı

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Konum alanının oluşturulma tarihi
}