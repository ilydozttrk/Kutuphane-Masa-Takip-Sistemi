using LibrarySeatTrackingAPI.Common.Enums; // TableStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class UpdateStudyTableStatusDto
{
    public TableStatus Status { get; set; } // Masanın yeni durumu: Available, Occupied, Reserved veya Maintenance
}