using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateLocationAreaDtoValidator : AbstractValidator<CreateLocationAreaDto> // CreateLocationAreaDto için validation sınıfı
{
    public CreateLocationAreaDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.Name) // Konum alanı adı için kural başlatır
            .NotEmpty().WithMessage("Location area name is required.") // Konum alanı adı boş olamaz
            .MaximumLength(100).WithMessage("Location area name cannot exceed 100 characters."); // En fazla 100 karakter olabilir

        RuleFor(x => x.Latitude) // Enlem bilgisi için kural başlatır
            .InclusiveBetween(-90, 90).WithMessage("Latitude must be between -90 and 90."); // Enlem geçerli aralıkta olmalı

        RuleFor(x => x.Longitude) // Boylam bilgisi için kural başlatır
            .InclusiveBetween(-180, 180).WithMessage("Longitude must be between -180 and 180."); // Boylam geçerli aralıkta olmalı

        RuleFor(x => x.RadiusMeters) // Konum yarıçapı için kural başlatır
            .InclusiveBetween(10, 1000).WithMessage("Radius must be between 10 and 1000 meters."); // Yarıçap 10-1000 metre arası olmalı
    }
}