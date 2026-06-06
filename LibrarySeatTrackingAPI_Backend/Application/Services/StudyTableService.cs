using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IStudyTableService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Common.Enums; // TableStatus enumunu kullanmak için
using LibrarySeatTrackingAPI.Domain; // StudyTable entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, ToListAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Bu dosyanın Application/Services katmanına ait olduğunu belirtir

public class StudyTableService : IStudyTableService // StudyTableService, IStudyTableService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public StudyTableService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<StudyTableResponseDto>> CreateAsync(CreateStudyTableDto request) // Yeni masa oluşturur
    {
        var locationAreaExists = await _db.LocationAreas.AnyAsync(x => x.Id == request.LocationAreaId && x.IsActive); // Aktif konum alanı var mı kontrol eder

        if (!locationAreaExists) // Konum alanı yoksa veya pasifse
        {
            return new ApiResponseDto<StudyTableResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Active location area not found.", // Konum alanı bulunamadı mesajı

                Data = null // Veri dönülmez
            };
        }

        var codeExists = await _db.StudyTables.AnyAsync(x => x.Code == request.Code); // Aynı masa kodu daha önce eklenmiş mi kontrol eder

        if (codeExists) // Aynı kod varsa
        {
            return new ApiResponseDto<StudyTableResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Study table code already exists.", // Aynı masa kodu var mesajı

                Data = null // Veri dönülmez
            };
        }

        var studyTable = new StudyTable // Yeni StudyTable entity nesnesi oluşturur
        {
            Code = request.Code, // DTO'dan gelen masa kodunu entity'ye aktarır

            LocationAreaId = request.LocationAreaId, // DTO'dan gelen konum alanı Id bilgisini entity'ye aktarır

            Status = TableStatus.Available, // Yeni masa başlangıçta boş olarak ayarlanır

            IsActive = true // Yeni masa aktif başlatılır
        };

        _db.StudyTables.Add(studyTable); // Yeni masayı veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Değişiklikleri veritabanına kaydeder

        var createdTable = await _db.StudyTables // Yeni oluşturulan masayı ilişkili LocationArea bilgisiyle tekrar sorgular
            .Include(x => x.LocationArea) // Masanın bağlı olduğu konum alanını da getirir
            .FirstAsync(x => x.Id == studyTable.Id); // Oluşturulan masayı Id ile bulur

        var response = new StudyTableResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
        {
            Id = createdTable.Id, // Masanın Id bilgisini aktarır

            Code = createdTable.Code, // Masanın kodunu aktarır

            Status = createdTable.Status, // Masanın durumunu aktarır

            LocationAreaId = createdTable.LocationAreaId, // Bağlı olduğu konum alanı Id bilgisini aktarır

            LocationAreaName = createdTable.LocationArea?.Name ?? string.Empty, // Bağlı olduğu konum alanı adını aktarır

            IsActive = createdTable.IsActive, // Aktiflik bilgisini aktarır

            CreatedAt = createdTable.CreatedAt // Oluşturulma tarihini aktarır
        };

        return new ApiResponseDto<StudyTableResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı

            Message = "Study table created successfully.", // Başarı mesajı

            Data = response // Oluşturulan masa bilgisi
        };
    }

    public async Task<ApiResponseDto<List<StudyTableResponseDto>>> GetAllAsync() // Tüm masaları listeler
    {
        var tables = await _db.StudyTables // StudyTables tablosundan sorgu başlatır
            .Include(x => x.LocationArea) // Her masanın bağlı olduğu konum alanını da getirir
            .OrderByDescending(x => x.CreatedAt) // En yeni eklenen masalar önce gelsin diye sıralar
            .Select(x => new StudyTableResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Masanın Id bilgisi

                Code = x.Code, // Masanın kodu

                Status = x.Status, // Masanın mevcut durumu

                LocationAreaId = x.LocationAreaId, // Bağlı olduğu konum alanı Id bilgisi

                LocationAreaName = x.LocationArea != null ? x.LocationArea.Name : string.Empty, // Konum alanı adını güvenli şekilde aktarır

                IsActive = x.IsActive, // Masanın aktiflik bilgisi

                CreatedAt = x.CreatedAt // Masanın oluşturulma tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<StudyTableResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı

            Message = "Study tables listed successfully.", // Başarı mesajı

            Data = tables // Masa listesi
        };
    }
    public async Task<ApiResponseDto<StudyTableResponseDto>> UpdateStatusAsync(int studyTableId, UpdateStudyTableStatusDto request) // Admin masanın durumunu günceller
        {
            var studyTable = await _db.StudyTables // StudyTables tablosundan sorgu başlatır
                .Include(x => x.LocationArea) // Masanın bağlı olduğu konum alanını getirir
                .FirstOrDefaultAsync(x => x.Id == studyTableId); // Id'ye göre masayı bulur

            if (studyTable is null) // Masa bulunamazsa
            {
                return new ApiResponseDto<StudyTableResponseDto> // Başarısız cevap döner
                {
                    Success = false, // İşlem başarısız
                    Message = "Study table not found.", // Masa bulunamadı mesajı
                    Data = null // Veri dönülmez
                };
            }

            studyTable.Status = request.Status; // Masanın durumunu günceller

            await _db.SaveChangesAsync(); // Değişikliği veritabanına kaydeder

            var response = new StudyTableResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
            {
                Id = studyTable.Id, // Masa Id bilgisi
                Code = studyTable.Code, // Masa kodu
                Status = studyTable.Status, // Masa durumu
                LocationAreaId = studyTable.LocationAreaId, // Konum alanı Id bilgisi
                LocationAreaName = studyTable.LocationArea?.Name ?? string.Empty, // Konum alanı adı
                IsActive = studyTable.IsActive, // Masa aktif mi
                CreatedAt = studyTable.CreatedAt // Oluşturulma tarihi
            };

            return new ApiResponseDto<StudyTableResponseDto> // Standart API cevabı döner
            {
                Success = true, // İşlem başarılı
                Message = "Study table status updated successfully.", // Başarı mesajı
                Data = response // Güncellenmiş masa bilgisi
            };
        }
}