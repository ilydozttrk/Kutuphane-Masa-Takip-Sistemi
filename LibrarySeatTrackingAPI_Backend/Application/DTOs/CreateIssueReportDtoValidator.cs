using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateIssueReportDtoValidator : AbstractValidator<CreateIssueReportDto> // CreateIssueReportDto için validation sınıfı
{
    public CreateIssueReportDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.StudyTableId) // Masa Id bilgisi için kural başlatır
            .GreaterThan(0).WithMessage("Study table id must be greater than 0."); // Masa Id 0'dan büyük olmalı

        RuleFor(x => x.Description) // Sorun açıklaması için kural başlatır
            .NotEmpty().WithMessage("Description is required.") // Açıklama boş olamaz
            .MinimumLength(5).WithMessage("Description must be at least 5 characters.") // Açıklama en az 5 karakter olmalı
            .MaximumLength(500).WithMessage("Description cannot exceed 500 characters."); // Açıklama en fazla 500 karakter olabilir
    }
}