using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateBlockRecordDtoValidator : AbstractValidator<CreateBlockRecordDto> // CreateBlockRecordDto için validation sınıfı
{
    public CreateBlockRecordDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.UserId) // Bloke edilecek kullanıcı Id bilgisi için kural başlatır
            .GreaterThan(0).WithMessage("User id must be greater than 0."); // Kullanıcı Id 0'dan büyük olmalı

        RuleFor(x => x.Reason) // Bloke nedeni için kural başlatır
            .NotEmpty().WithMessage("Reason is required.") // Bloke nedeni boş olamaz
            .MinimumLength(5).WithMessage("Reason must be at least 5 characters.") // Bloke nedeni en az 5 karakter olmalı
            .MaximumLength(500).WithMessage("Reason cannot exceed 500 characters."); // Bloke nedeni en fazla 500 karakter olabilir
    }
}