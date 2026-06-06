namespace LibrarySeatTrackingAPI.Common.Enums;

public enum QueueStatus
{
    Waiting = 1, //sırada bekliyor
    Notified = 2, //Kullanıcıya bildirim gitmiş
    Completed = 3, //Sıra işi tamamlanmış
    Cancelled = 4 //Sıradan çıkmış
}