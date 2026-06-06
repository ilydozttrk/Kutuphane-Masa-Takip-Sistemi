namespace LibrarySeatTrackingAPI.Common.Enums;

public enum ReservationStatus
{
    Active = 1, //aktif oturum
    Completed = 2, //Normal şekilde bitmiş
    Cancelled = 3, //iptal edilmiş
    Expired = 4  //süresi dolmuş
}