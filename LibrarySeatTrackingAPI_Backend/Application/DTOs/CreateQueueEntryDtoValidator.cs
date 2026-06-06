using FluentValidation; // FluentValidation kurallarını yazmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class CreateQueueEntryDtoValidator : AbstractValidator<CreateQueueEntryDto> // CreateQueueEntryDto için validation sınıfı
{
    public CreateQueueEntryDtoValidator() // Kuralların yazıldığı constructor
    {
        RuleFor(x => x.StudyTableId) // Sıraya girilecek masa Id bilgisi için kural başlatır
            .GreaterThan(0).WithMessage("Study table id must be greater than 0."); // Masa Id 0'dan büyük olmalı
    }
}