using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IIssueReportService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Common.Enums; // IssueStatus enumunu kullanmak için
using LibrarySeatTrackingAPI.Domain; // IssueReport entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, ToListAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Bu dosyanın Application/Services katmanına ait olduğunu belirtir

public class IssueReportService : IIssueReportService // IssueReportService, IIssueReportService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public IssueReportService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<IssueReportResponseDto>> CreateAsync(CreateIssueReportDto request, int userId) // Sorun bildirimi oluşturur
    {
        var tableExists = await _db.StudyTables.AnyAsync(x => x.Id == request.StudyTableId && x.IsActive); // Aktif masa var mı kontrol eder

        if (!tableExists) // Masa yoksa veya pasifse
        {
            return new ApiResponseDto<IssueReportResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız
                Message = "Active study table not found.", // Aktif masa bulunamadı mesajı
                Data = null // Veri dönülmez
            };
        }

        var issueReport = new IssueReport // Yeni sorun bildirimi nesnesi oluşturur
        {
            UserId = userId, // Token içinden gelen kullanıcı Id bilgisini aktarır
            StudyTableId = request.StudyTableId, // DTO'dan gelen masa Id bilgisini aktarır
            Description = request.Description, // DTO'dan gelen sorun açıklamasını aktarır
            Status = IssueStatus.Open // Sorun bildirimini açık durumda başlatır
        };

        _db.IssueReports.Add(issueReport); // Sorun bildirimini veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Sorun bildirimini veritabanına kaydeder

        var createdIssue = await _db.IssueReports // Oluşturulan sorun bildirimini ilişkili bilgilerle tekrar sorgular
            .Include(x => x.User) // Bildiren kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Sorun bildirilen masa bilgisini getirir
            .FirstAsync(x => x.Id == issueReport.Id); // Oluşturulan bildirimi Id ile bulur

        var response = MapToResponse(createdIssue); // Entity verisini response DTO'ya çevirir

        return new ApiResponseDto<IssueReportResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Issue report created successfully.", // Başarı mesajı
            Data = response // Oluşturulan sorun bildirimi bilgisi
        };
    }

    public async Task<ApiResponseDto<List<IssueReportResponseDto>>> GetAllAsync() // Admin/Staff için tüm sorun bildirimlerini listeler
    {
        var reports = await _db.IssueReports // IssueReports tablosundan sorgu başlatır
            .Include(x => x.User) // Bildiren kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Masa bilgisini getirir
            .OrderByDescending(x => x.CreatedAt) // En yeni bildirimler önce gelsin diye sıralar
            .Select(x => new IssueReportResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Sorun bildirimi Id bilgisi
                UserId = x.UserId, // Bildiren kullanıcı Id bilgisi
                UserFullName = x.User != null ? x.User.FullName : string.Empty, // Bildiren kullanıcı adı soyadı
                StudyTableId = x.StudyTableId, // Masa Id bilgisi
                StudyTableCode = x.StudyTable != null ? x.StudyTable.Code : string.Empty, // Masa kodu
                Description = x.Description, // Sorun açıklaması
                Status = x.Status, // Sorun durumu
                CreatedAt = x.CreatedAt // Oluşturulma tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<IssueReportResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "Issue reports listed successfully.", // Başarı mesajı
            Data = reports // Sorun bildirimleri listesi
        };
    }

    public async Task<ApiResponseDto<List<IssueReportResponseDto>>> GetMyReportsAsync(int userId) // Giriş yapan kullanıcının kendi sorun bildirimlerini listeler

    {
        var reports = await _db.IssueReports // IssueReports tablosundan sorgu başlatır
            .Include(x => x.User) // Bildiren kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Masa bilgisini getirir
            .Where(x => x.UserId == userId) // Sadece giriş yapan kullanıcıya ait kayıtları filtreler
            .OrderByDescending(x => x.CreatedAt) // En yeni bildirimler önce gelsin diye sıralar
            .Select(x => new IssueReportResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Sorun bildirimi Id bilgisi
                UserId = x.UserId, // Bildiren kullanıcı Id bilgisi
                UserFullName = x.User != null ? x.User.FullName : string.Empty, // Bildiren kullanıcı adı soyadı
                StudyTableId = x.StudyTableId, // Masa Id bilgisi
                StudyTableCode = x.StudyTable != null ? x.StudyTable.Code : string.Empty, // Masa kodu
                Description = x.Description, // Sorun açıklaması
                Status = x.Status, // Sorun durumu
                CreatedAt = x.CreatedAt // Oluşturulma tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<IssueReportResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı
            Message = "My issue reports listed successfully.", // Başarı mesajı
            Data = reports // Kullanıcının kendi sorun bildirimleri
        };
    }

        public async Task<ApiResponseDto<IssueReportResponseDto>> UpdateStatusAsync(int issueReportId, UpdateIssueReportStatusDto request) // Admin/Staff sorun bildirimi durumunu günceller
        {
            var issueReport = await _db.IssueReports // IssueReports tablosundan sorgu başlatır
                .Include(x => x.User) // Bildiren kullanıcı bilgisini getirir
                .Include(x => x.StudyTable) // Masa bilgisini getirir
                .FirstOrDefaultAsync(x => x.Id == issueReportId); // Id'ye göre sorun bildirimini bulur

            if (issueReport is null) // Sorun bildirimi bulunamazsa
            {
                return new ApiResponseDto<IssueReportResponseDto> // Başarısız cevap döner
                {
                    Success = false, // İşlem başarısız
                    Message = "Issue report not found.", // Sorun bildirimi bulunamadı mesajı
                    Data = null // Veri dönülmez
                };
            }

            issueReport.Status = request.Status; // Sorun bildiriminin durumunu günceller

            await _db.SaveChangesAsync(); // Değişikliği veritabanına kaydeder

            var response = MapToResponse(issueReport); // Güncellenmiş entity'yi response DTO'ya çevirir

            return new ApiResponseDto<IssueReportResponseDto> // Standart API cevabı döner
            {
                Success = true, // İşlem başarılı
                Message = "Issue report status updated successfully.", // Başarı mesajı
                Data = response // Güncellenmiş sorun bildirimi bilgisi
            };
        }

    private static IssueReportResponseDto MapToResponse(IssueReport issueReport) // IssueReport entity'sini response DTO'ya çevirir
    {
        return new IssueReportResponseDto // Response DTO oluşturur
        {
            Id = issueReport.Id, // Sorun bildirimi Id bilgisi
            UserId = issueReport.UserId, // Bildiren kullanıcı Id bilgisi
            UserFullName = issueReport.User?.FullName ?? string.Empty, // Bildiren kullanıcı adı soyadı
            StudyTableId = issueReport.StudyTableId, // Masa Id bilgisi
            StudyTableCode = issueReport.StudyTable?.Code ?? string.Empty, // Masa kodu
            Description = issueReport.Description, // Sorun açıklaması
            Status = issueReport.Status, // Sorun durumu
            CreatedAt = issueReport.CreatedAt // Oluşturulma tarihi
        };
    }
}