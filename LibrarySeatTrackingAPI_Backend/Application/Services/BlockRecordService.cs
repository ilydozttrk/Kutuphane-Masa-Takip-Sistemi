using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IBlockRecordService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Domain; // BlockRecord entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, FirstOrDefaultAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Services klasörüne ait olduğunu belirtir

public class BlockRecordService : IBlockRecordService // BlockRecordService, IBlockRecordService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public BlockRecordService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<BlockRecordResponseDto>> CreateAsync(CreateBlockRecordDto request) // Admin kullanıcının bloke edilmesini sağlar
    {
        var user = await _db.Users.FirstOrDefaultAsync(x => x.Id == request.UserId); // Bloke edilecek kullanıcıyı bulur

        if (user is null) // Kullanıcı bulunamazsa
        {
            return new ApiResponseDto<BlockRecordResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "User not found.", // Kullanıcı bulunamadı mesajı
                Data = null // Veri dönülmez
            };
        }

        var activeBlockExists = await _db.BlockRecords.AnyAsync(x =>
            x.UserId == request.UserId &&
            x.IsActive); // Kullanıcının aktif blokesi var mı kontrol eder

        if (activeBlockExists) // Aktif bloke varsa
        {
            return new ApiResponseDto<BlockRecordResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "User already has an active block.", // Kullanıcı zaten blokeli mesajı
                Data = null // Veri dönülmez
            };
        }

        var blockRecord = new BlockRecord // Yeni bloke kaydı oluşturur
        {
            UserId = request.UserId, // Bloke edilecek kullanıcı Id bilgisini aktarır
            Reason = request.Reason, // Bloke nedenini aktarır
            EndsAt = request.EndsAt, // Bloke bitiş tarihini aktarır
            IsActive = true // Blokeyi aktif başlatır
        };

        user.IsBlocked = true; // User tablosundaki kullanıcıyı blokeli yapar

        _db.BlockRecords.Add(blockRecord); // Bloke kaydını veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Bloke kaydını ve kullanıcı durumunu veritabanına kaydeder

        var createdBlock = await _db.BlockRecords // Oluşan bloke kaydını kullanıcı bilgisiyle tekrar sorgular
            .Include(x => x.User) // Bloke edilen kullanıcıyı getirir
            .FirstAsync(x => x.Id == blockRecord.Id); // Oluşturulan bloke kaydını Id ile bulur

        return new ApiResponseDto<BlockRecordResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "User blocked successfully.", // Başarı mesajı
            Data = MapToResponse(createdBlock) // Bloke kaydı bilgisi
        };
    }

    public async Task<ApiResponseDto<List<BlockRecordResponseDto>>> GetAllAsync() // Tüm bloke kayıtlarını listeler
    {
        var blocks = await _db.BlockRecords // BlockRecords tablosundan sorgu başlatır
            .Include(x => x.User) // Bloke edilen kullanıcı bilgisini getirir
            .OrderByDescending(x => x.BlockedAt) // En yeni bloke kayıtları önce gelsin diye sıralar
            .Select(x => new BlockRecordResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Bloke kaydı Id bilgisi
                UserId = x.UserId, // Kullanıcı Id bilgisi
                UserFullName = x.User != null ? x.User.FullName : string.Empty, // Kullanıcının adı soyadı
                UserEmail = x.User != null ? x.User.Email : string.Empty, // Kullanıcının e-posta adresi
                Reason = x.Reason, // Bloke nedeni
                BlockedAt = x.BlockedAt, // Bloke başlangıç tarihi
                EndsAt = x.EndsAt, // Bloke bitiş tarihi
                IsActive = x.IsActive // Bloke aktif mi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<BlockRecordResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Block records listed successfully.", // Başarı mesajı
            Data = blocks // Bloke kayıtları
        };
    }

    public async Task<ApiResponseDto<BlockRecordResponseDto>> RemoveBlockAsync(int blockRecordId) // Aktif blokeyi kaldırır
    {
        var blockRecord = await _db.BlockRecords // BlockRecords tablosundan sorgu başlatır
            .Include(x => x.User) // Bloke edilen kullanıcıyı getirir
            .FirstOrDefaultAsync(x => x.Id == blockRecordId && x.IsActive); // Aktif bloke kaydını bulur

        if (blockRecord is null) // Aktif bloke kaydı bulunamazsa
        {
            return new ApiResponseDto<BlockRecordResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "Active block record not found.", // Aktif bloke kaydı bulunamadı mesajı
                Data = null // Veri dönülmez
            };
        }

        blockRecord.IsActive = false; // Bloke kaydını pasif yapar

        if (blockRecord.User is not null) // Bloke edilen kullanıcı varsa
        {
            blockRecord.User.IsBlocked = false; // Kullanıcının blokeli durumunu kaldırır
        }

        await _db.SaveChangesAsync(); // Değişiklikleri veritabanına kaydeder

        return new ApiResponseDto<BlockRecordResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Block removed successfully.", // Başarı mesajı
            Data = MapToResponse(blockRecord) // Güncellenmiş bloke kaydı bilgisi
        };
    }

    private static BlockRecordResponseDto MapToResponse(BlockRecord blockRecord) // BlockRecord entity'sini response DTO'ya çevirir
    {
        return new BlockRecordResponseDto // Response DTO oluşturur
        {
            Id = blockRecord.Id, // Bloke kaydı Id bilgisi
            UserId = blockRecord.UserId, // Kullanıcı Id bilgisi
            UserFullName = blockRecord.User?.FullName ?? string.Empty, // Kullanıcının adı soyadı
            UserEmail = blockRecord.User?.Email ?? string.Empty, // Kullanıcının e-posta adresi
            Reason = blockRecord.Reason, // Bloke nedeni
            BlockedAt = blockRecord.BlockedAt, // Bloke başlangıç tarihi
            EndsAt = blockRecord.EndsAt, // Bloke bitiş tarihi
            IsActive = blockRecord.IsActive // Bloke aktif mi
        };
    }
}