using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IQueueEntryService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Common.Enums; // QueueStatus ve TableStatus enumlarını kullanmak için
using LibrarySeatTrackingAPI.Domain; // QueueEntry entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, ToListAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Bu dosyanın Application/Services katmanına ait olduğunu belirtir

public class QueueEntryService : IQueueEntryService // QueueEntryService, IQueueEntryService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public QueueEntryService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<QueueEntryResponseDto>> CreateAsync(CreateQueueEntryDto request, int userId) // Öğrencinin masa için sıraya girmesini sağlar
    {
        var table = await _db.StudyTables.FirstOrDefaultAsync(x => x.Id == request.StudyTableId && x.IsActive); // Aktif masayı bulur

        if (table is null) // Masa bulunamazsa
        {
            return new ApiResponseDto<QueueEntryResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "Active study table not found.", // Aktif masa bulunamadı mesajı
                Data = null // Veri dönülmez
            };
        }
        var userHasActiveReservation = await _db.Reservations.AnyAsync(x =>
        x.UserId == userId &&
        x.Status == ReservationStatus.Active); // Kullanıcının aktif rezervasyonu var mı kontrol eder

        if (userHasActiveReservation) // Kullanıcının aktif rezervasyonu varsa
        {
            return new ApiResponseDto<QueueEntryResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "You already have an active reservation. You cannot join a queue.", // Aktif rezervasyonu olan kullanıcı sıraya giremez
                Data = null // Veri dönülmez
            };
        }
        if (table.Status == TableStatus.Available) // Masa zaten boşsa
        {
            return new ApiResponseDto<QueueEntryResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "Study table is available. You do not need to join queue.", // Masa boş, sıraya gerek yok mesajı
                Data = null // Veri dönülmez
            };
        }

        var alreadyInQueue = await _db.QueueEntries.AnyAsync(x =>
            x.UserId == userId &&
            x.StudyTableId == request.StudyTableId &&
            x.Status == QueueStatus.Waiting); // Kullanıcı bu masa için zaten beklemede mi kontrol eder

        if (alreadyInQueue) // Kullanıcı zaten sıradaysa
        {
            return new ApiResponseDto<QueueEntryResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "You are already waiting in queue for this table.", // Zaten sıradasın mesajı
                Data = null // Veri dönülmez
            };
        }

        var queueEntry = new QueueEntry // Yeni sıra kaydı oluşturur
        {
            UserId = userId, // Token içinden gelen kullanıcı Id bilgisini aktarır
            StudyTableId = request.StudyTableId, // Sıraya girilecek masa Id bilgisini aktarır
            Status = QueueStatus.Waiting // Sıra kaydını bekliyor durumunda başlatır
        };

        _db.QueueEntries.Add(queueEntry); // Sıra kaydını veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Sıra kaydını veritabanına kaydeder

        var createdQueueEntry = await _db.QueueEntries // Oluşturulan sıra kaydını ilişkili bilgilerle tekrar sorgular
            .Include(x => x.User) // Kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Masa bilgisini getirir
            .FirstAsync(x => x.Id == queueEntry.Id); // Oluşturulan sıra kaydını Id ile bulur

        var response = MapToResponse(createdQueueEntry); // Entity verisini response DTO'ya çevirir

        return new ApiResponseDto<QueueEntryResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Queue entry created successfully.", // Başarı mesajı
            Data = response // Oluşturulan sıra kaydı bilgisi
        };
    }

    public async Task<ApiResponseDto<List<QueueEntryResponseDto>>> GetMyQueueEntriesAsync(int userId) // Giriş yapan öğrencinin kendi sıra kayıtlarını listeler
    {
        var queueEntries = await _db.QueueEntries // QueueEntries tablosundan sorgu başlatır
            .Include(x => x.User) // Kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Masa bilgisini getirir
            .Where(x => x.UserId == userId) // Sadece giriş yapan kullanıcının kayıtlarını filtreler
            .OrderByDescending(x => x.CreatedAt) // En yeni kayıtlar önce gelsin diye sıralar
            .Select(x => new QueueEntryResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Sıra kaydı Id bilgisi
                UserId = x.UserId, // Kullanıcı Id bilgisi
                UserFullName = x.User != null ? x.User.FullName : string.Empty, // Kullanıcı adı soyadı
                StudyTableId = x.StudyTableId, // Masa Id bilgisi
                StudyTableCode = x.StudyTable != null ? x.StudyTable.Code : string.Empty, // Masa kodu
                Status = x.Status, // Sıra durumu
                CreatedAt = x.CreatedAt // Sıraya giriş tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<QueueEntryResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "My queue entries listed successfully.", // Başarı mesajı
            Data = queueEntries // Kullanıcının sıra kayıtları
        };
    }

    public async Task<ApiResponseDto<List<QueueEntryResponseDto>>> GetAllAsync() // Admin veya Staff için tüm sıra kayıtlarını listeler
    {
        var queueEntries = await _db.QueueEntries // QueueEntries tablosundan sorgu başlatır
            .Include(x => x.User) // Kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Masa bilgisini getirir
            .OrderByDescending(x => x.CreatedAt) // En yeni kayıtlar önce gelsin diye sıralar
            .Select(x => new QueueEntryResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Sıra kaydı Id bilgisi
                UserId = x.UserId, // Kullanıcı Id bilgisi
                UserFullName = x.User != null ? x.User.FullName : string.Empty, // Kullanıcı adı soyadı
                StudyTableId = x.StudyTableId, // Masa Id bilgisi
                StudyTableCode = x.StudyTable != null ? x.StudyTable.Code : string.Empty, // Masa kodu
                Status = x.Status, // Sıra durumu
                CreatedAt = x.CreatedAt // Sıraya giriş tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<QueueEntryResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Queue entries listed successfully.", // Başarı mesajı
            Data = queueEntries // Tüm sıra kayıtları
        };
    }

        public async Task<ApiResponseDto<QueueEntryResponseDto>> UpdateStatusAsync(int queueEntryId, UpdateQueueEntryStatusDto request) // Admin/Staff sıra kaydının durumunu günceller
            {
                var queueEntry = await _db.QueueEntries // QueueEntries tablosundan sorgu başlatır
                    .Include(x => x.User) // Sıraya giren kullanıcı bilgisini getirir
                    .Include(x => x.StudyTable) // Sıraya girilen masa bilgisini getirir
                    .FirstOrDefaultAsync(x => x.Id == queueEntryId); // Id'ye göre sıra kaydını bulur

                if (queueEntry is null) // Sıra kaydı bulunamazsa
                {
                    return new ApiResponseDto<QueueEntryResponseDto> // Başarısız cevap döner
                    {
                        Success = false, // İşlem başarısız
                        Message = "Queue entry not found.", // Sıra kaydı bulunamadı mesajı
                        Data = null // Veri dönülmez
                    };
                }

                queueEntry.Status = request.Status; // Sıra kaydının durumunu günceller

                await _db.SaveChangesAsync(); // Değişikliği veritabanına kaydeder

                var response = MapToResponse(queueEntry); // Güncellenmiş entity'yi response DTO'ya çevirir

                return new ApiResponseDto<QueueEntryResponseDto> // Standart API cevabı döner
                {
                    Success = true, // İşlem başarılı
                    Message = "Queue entry status updated successfully.", // Başarı mesajı
                    Data = response // Güncellenmiş sıra kaydı bilgisi
                };
            }
    private static QueueEntryResponseDto MapToResponse(QueueEntry queueEntry) // QueueEntry entity'sini response DTO'ya çevirir
    {
        return new QueueEntryResponseDto // Response DTO oluşturur
        {
            Id = queueEntry.Id, // Sıra kaydı Id bilgisi
            UserId = queueEntry.UserId, // Kullanıcı Id bilgisi
            UserFullName = queueEntry.User?.FullName ?? string.Empty, // Kullanıcı adı soyadı
            StudyTableId = queueEntry.StudyTableId, // Masa Id bilgisi
            StudyTableCode = queueEntry.StudyTable?.Code ?? string.Empty, // Masa kodu
            Status = queueEntry.Status, // Sıra durumu
            CreatedAt = queueEntry.CreatedAt // Sıraya giriş tarihi
        };
    }
}