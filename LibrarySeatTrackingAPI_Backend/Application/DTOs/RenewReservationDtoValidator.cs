using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class RenewReservationDtoValidator : AbstractValidator<RenewReservationDto> // RenewReservationDto için validation sınıfı
{
    public RenewReservationDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.QrCode) // QR kod alanı için kural başlatır
            .NotEmpty().WithMessage("QR code is required."); // QR kod boş olamaz

        RuleFor(x => x.UserLatitude) // Enlem bilgisi için kural başlatır
            .InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90."); // Enlem geçerli aralıkta olmalı

        RuleFor(x => x.UserLongitude) // Boylam bilgisi için kural başlatır
            .InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180."); // Boylam geçerli aralıkta olmalı

        RuleFor(x => x.ExtraMinutes) // Eklenecek süre için kural başlatır
            .InclusiveBetween(15, 240).WithMessage("Extra minutes must be between 15 and 240."); // Ek süre 15-240 dakika arası olmalı
    }
}