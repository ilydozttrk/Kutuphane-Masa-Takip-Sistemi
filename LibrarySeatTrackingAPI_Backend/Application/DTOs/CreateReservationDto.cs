namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class CreateReservationDto
{
    public string QrCode { get; set; } = string.Empty; // Öğrencinin okuttuğu QR kod değeri

    public double UserLatitude { get; set; } // Öğrencinin telefondan gelen anlık enlem bilgisi

    public double UserLongitude { get; set; } // Öğrencinin telefondan gelen anlık boylam bilgisi

    public int DurationMinutes { get; set; } = 60; // Masa kullanım süresi, varsayılan 60 dakika
}