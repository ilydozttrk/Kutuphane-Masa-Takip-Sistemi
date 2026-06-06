namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class RenewReservationDto
{
    public string QrCode { get; set; } = string.Empty; // Kullanıcının yeniden okuttuğu QR kod değeri

    public double UserLatitude { get; set; } // Kullanıcının anlık enlem bilgisi

    public double UserLongitude { get; set; } // Kullanıcının anlık boylam bilgisi

    public int ExtraMinutes { get; set; } = 60; // Oturuma eklenecek süre, varsayılan 60 dakika
}