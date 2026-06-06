using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateQrCodeRecordDtoValidator : AbstractValidator<CreateQrCodeRecordDto> // CreateQrCodeRecordDto için validation sınıfı
{
    public CreateQrCodeRecordDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.Code) // QR kod değeri için kural başlatır
            .NotEmpty().WithMessage("QR code is required.") // QR kod boş olamaz
            .MaximumLength(200).WithMessage("QR code cannot exceed 200 characters."); // QR kod en fazla 200 karakter olabilir

        RuleFor(x => x.StudyTableId) // Masa Id bilgisi için kural başlatır
            .GreaterThan(0).WithMessage("Study table id must be greater than 0."); // Masa Id 0'dan büyük olmalı
    }
}