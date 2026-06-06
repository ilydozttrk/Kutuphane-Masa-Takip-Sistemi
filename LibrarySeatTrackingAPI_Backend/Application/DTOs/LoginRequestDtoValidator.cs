using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class LoginRequestDtoValidator : AbstractValidator<LoginRequestDto> // LoginRequestDto için validation sınıfı
{
    public LoginRequestDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.Email) // Email alanı için kural başlatır
            .NotEmpty().WithMessage("Email is required.") // Email boş olamaz
            .EmailAddress().WithMessage("Email format is invalid."); // Email geçerli formatta olmalı

        RuleFor(x => x.Password) // Password alanı için kural başlatır
            .NotEmpty().WithMessage("Password is required."); // Password boş olamaz
    }
}