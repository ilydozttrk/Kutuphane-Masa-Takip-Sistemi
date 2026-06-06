using LibrarySeatTrackingAPI.Common.Enums; // TableStatus enumunu kullanmak için ekledik

namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain katmanına ait olduğunu belirtir

public class StudyTable
{
    public int Id { get; set; } // Masanın benzersiz kimlik numarası

    public string Code { get; set; } = string.Empty; // Masanın görünen kodu: örnek A-101, B-205

    public TableStatus Status { get; set; } = TableStatus.Available; // Masanın mevcut durumu: boş, dolu, rezerve veya bakımda

    public int LocationAreaId { get; set; } // Masanın hangi konum alanına ait olduğunu belirtir

    public LocationArea? LocationArea { get; set; } // LocationArea tablosu ile ilişki kurmak için kullanılır

    public bool IsActive { get; set; } = true; // Masanın sistemde aktif kullanılıp kullanılmadığı

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Masanın sisteme eklenme tarihi
}