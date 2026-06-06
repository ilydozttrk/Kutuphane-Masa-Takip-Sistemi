using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class RegisterDeviceTokenDtoValidator : AbstractValidator<RegisterDeviceTokenDto> // RegisterDeviceTokenDto için validation sınıfı
{
    public RegisterDeviceTokenDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.Token) // FCM token alanı için kural başlatır
            .NotEmpty().WithMessage("Device token is required.") // Token boş olamaz
            .MaximumLength(1000).WithMessage("Device token cannot exceed 1000 characters."); // Token çok uzun olamaz

        RuleFor(x => x.DeviceName) // Cihaz adı için kural başlatır
            .MaximumLength(100).WithMessage("Device name cannot exceed 100 characters."); // Cihaz adı en fazla 100 karakter olabilir
    }
}