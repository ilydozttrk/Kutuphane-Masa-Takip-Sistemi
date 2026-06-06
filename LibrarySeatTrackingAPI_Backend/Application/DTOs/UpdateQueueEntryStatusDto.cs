using LibrarySeatTrackingAPI.Common.Enums; // QueueStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // DTO klasörüne ait olduğunu belirtir

public class UpdateQueueEntryStatusDto
{
    public QueueStatus Status { get; set; } // Sıra kaydının yeni durumu: Waiting, Notified, Completed veya Cancelled
}