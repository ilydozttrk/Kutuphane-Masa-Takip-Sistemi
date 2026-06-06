using LibrarySeatTrackingAPI.Common.Enums; // TableStatus enumunu kullanmak için

namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class StudyTableResponseDto
{
    public int Id { get; set; } // Masanın benzersiz Id bilgisi

    public string Code { get; set; } = string.Empty; // Masanın görünen kodu: örnek A-101

    public TableStatus Status { get; set; } // Masanın mevcut durumu: Available, Occupied, Reserved veya Maintenance

    public int LocationAreaId { get; set; } // Masanın bağlı olduğu konum alanının Id bilgisi

    public string LocationAreaName { get; set; } = string.Empty; // Masanın bağlı olduğu konum alanının adı

    public bool IsActive { get; set; } // Masanın aktif olup olmadığını belirtir

    public DateTime CreatedAt { get; set; } // Masanın oluşturulma tarihi
}