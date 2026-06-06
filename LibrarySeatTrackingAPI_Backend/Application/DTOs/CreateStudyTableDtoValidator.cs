using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateStudyTableDtoValidator : AbstractValidator<CreateStudyTableDto> // CreateStudyTableDto için validation sınıfı
{
    public CreateStudyTableDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.Code) // Masa kodu için kural başlatır
            .NotEmpty().WithMessage("Table code is required.") // Masa kodu boş olamaz
            .MaximumLength(50).WithMessage("Table code cannot exceed 50 characters."); // Masa kodu en fazla 50 karakter olabilir

        RuleFor(x => x.LocationAreaId) // Konum alanı Id için kural başlatır
            .GreaterThan(0).WithMessage("Location area id must be greater than 0."); // Id 0'dan büyük olmalı
    }
}