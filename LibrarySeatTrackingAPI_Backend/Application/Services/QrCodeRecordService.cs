using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IQrCodeRecordService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Domain; // QrCodeRecord entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, ToListAsync gibi EF Core metotları için
using QRCoder; // QR kod oluşturmak için QRCoder kütüphanesini kullanmak için

namespace LibrarySeatTrackingAPI.Application.Services; // Bu dosyanın Application/Services katmanına ait olduğunu belirtir

public class QrCodeRecordService : IQrCodeRecordService // QrCodeRecordService, IQrCodeRecordService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public QrCodeRecordService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<QrCodeRecordResponseDto>> CreateAsync(CreateQrCodeRecordDto request) // Yeni QR kod kaydı oluşturur
    {
        var tableExists = await _db.StudyTables.AnyAsync(x => x.Id == request.StudyTableId && x.IsActive); // Aktif masa var mı kontrol eder

        if (!tableExists) // Masa yoksa veya pasifse
        {

            return new ApiResponseDto<QrCodeRecordResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Active study table not found.", // Aktif masa bulunamadı mesajı

                Data = null // Veri dönülmez
            };
        }

        var codeExists = await _db.QrCodeRecords.AnyAsync(x => x.Code == request.Code); // Aynı QR kod daha önce eklenmiş mi kontrol eder

        if (codeExists) // Aynı QR kod varsa
        {
            return new ApiResponseDto<QrCodeRecordResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "QR code already exists.", // Aynı QR kod var mesajı

                Data = null // Veri dönülmez
            };
        }

        var qrCodeRecord = new QrCodeRecord // Yeni QR kod entity nesnesi oluşturur
        {
            Code = request.Code, // DTO'dan gelen QR kod değerini entity'ye aktarır

            StudyTableId = request.StudyTableId, // DTO'dan gelen masa Id bilgisini entity'ye aktarır

            IsActive = true // Yeni QR kod aktif başlatılır
        };

        _db.QrCodeRecords.Add(qrCodeRecord); // QR kodu veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Değişiklikleri veritabanına kaydeder

        var createdQrCode = await _db.QrCodeRecords // Oluşturulan QR kodu ilişkili masa bilgisiyle tekrar sorgular
            .Include(x => x.StudyTable) // QR kodun bağlı olduğu masayı da getirir
            .FirstAsync(x => x.Id == qrCodeRecord.Id); // Oluşturulan QR kodu Id ile bulur

        var response = new QrCodeRecordResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
        {
            Id = createdQrCode.Id, // QR kod Id bilgisini aktarır

            Code = createdQrCode.Code, // QR kod değerini aktarır

            StudyTableId = createdQrCode.StudyTableId, // Bağlı olduğu masa Id bilgisini aktarır

            StudyTableCode = createdQrCode.StudyTable?.Code ?? string.Empty, // Bağlı olduğu masa kodunu aktarır

            IsActive = createdQrCode.IsActive, // Aktiflik bilgisini aktarır

            CreatedAt = createdQrCode.CreatedAt // Oluşturulma tarihini aktarır
        };

        return new ApiResponseDto<QrCodeRecordResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı

            Message = "QR code record created successfully.", // Başarı mesajı

            Data = response // Oluşturulan QR kod bilgisi
        };
    }

    public async Task<ApiResponseDto<List<QrCodeRecordResponseDto>>> GetAllAsync() // Tüm QR kod kayıtlarını listeler
    {
        var qrCodes = await _db.QrCodeRecords // QrCodeRecords tablosundan sorgu başlatır
            .Include(x => x.StudyTable) // Her QR kodun bağlı olduğu masayı da getirir
            .OrderByDescending(x => x.CreatedAt) // En yeni eklenen QR kodlar önce gelsin diye sıralar
            .Select(x => new QrCodeRecordResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // QR kod Id bilgisi

                Code = x.Code, // QR kod değeri

                StudyTableId = x.StudyTableId, // Bağlı olduğu masa Id bilgisi

                StudyTableCode = x.StudyTable != null ? x.StudyTable.Code : string.Empty, // Bağlı olduğu masa kodunu güvenli şekilde aktarır

                IsActive = x.IsActive, // QR kod aktiflik bilgisi

                CreatedAt = x.CreatedAt // QR kod oluşturulma tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<QrCodeRecordResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı

            Message = "QR code records listed successfully.", // Başarı mesajı

            Data = qrCodes // QR kod listesi
        };
    }

    public async Task<ApiResponseDto<QrCodeRecordResponseDto>> UpdateStatusAsync(int qrCodeRecordId, UpdateQrCodeStatusDto request) // Admin/Staff QR kodu aktif veya pasif yapar
        {
            var qrCodeRecord = await _db.QrCodeRecords // QrCodeRecords tablosundan sorgu başlatır
                .Include(x => x.StudyTable) // QR kodun bağlı olduğu masayı getirir
                .FirstOrDefaultAsync(x => x.Id == qrCodeRecordId); // Id'ye göre QR kod kaydını bulur

            if (qrCodeRecord is null) // QR kod kaydı bulunamazsa
            {
                return new ApiResponseDto<QrCodeRecordResponseDto> // Başarısız cevap döner
                {
                    Success = false, // İşlem başarısız
                    Message = "QR code record not found.", // QR kod bulunamadı mesajı
                    Data = null // Veri dönülmez
                };
            }

            qrCodeRecord.IsActive = request.IsActive; // QR kodun aktiflik durumunu günceller

            await _db.SaveChangesAsync(); // Değişikliği veritabanına kaydeder

            var response = new QrCodeRecordResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
            {
                Id = qrCodeRecord.Id, // QR kod Id bilgisi
                Code = qrCodeRecord.Code, // QR kod değeri
                StudyTableId = qrCodeRecord.StudyTableId, // Bağlı masa Id bilgisi
                StudyTableCode = qrCodeRecord.StudyTable?.Code ?? string.Empty, // Bağlı masa kodu
                IsActive = qrCodeRecord.IsActive, // QR kod aktiflik durumu
                CreatedAt = qrCodeRecord.CreatedAt // Oluşturulma tarihi
            };

            return new ApiResponseDto<QrCodeRecordResponseDto> // Standart API cevabı döner
            {
                Success = true, // İşlem başarılı
                Message = "QR code status updated successfully.", // Başarı mesajı
                Data = response // Güncellenmiş QR kod bilgisi
            };
        }
        public async Task<ApiResponseDto<QrCodeFileDto>> GetQrCodePngAsync(int qrCodeRecordId)
{
    var qrCodeRecord = await _db.QrCodeRecords
        .Include(x => x.StudyTable)
        .FirstOrDefaultAsync(x => x.Id == qrCodeRecordId);

    if (qrCodeRecord is null)
    {
        return new ApiResponseDto<QrCodeFileDto>
        {
            Success = false,
            Message = "QR code record not found.",
            Data = null
        };
    }

    if (!qrCodeRecord.IsActive)
    {
        return new ApiResponseDto<QrCodeFileDto>
        {
            Success = false,
            Message = "QR code record is not active.",
            Data = null
        };
    }

    var qrPngBytes = PngByteQRCodeHelper.GetQRCode(
        qrCodeRecord.Code,
        QRCodeGenerator.ECCLevel.Q,
        20
    );

    var studyTableCode = qrCodeRecord.StudyTable?.Code ?? qrCodeRecord.StudyTableId.ToString();

    var safeTableCode = MakeSafeFileName(studyTableCode);

    var response = new QrCodeFileDto
    {
        FileBytes = qrPngBytes,
        FileName = $"table-{safeTableCode}-qr-{qrCodeRecord.Id}.png",
        ContentType = "image/png",
        Code = qrCodeRecord.Code,
        StudyTableCode = studyTableCode
    };

    return new ApiResponseDto<QrCodeFileDto>
    {
        Success = true,
        Message = "QR code image generated successfully.",
        Data = response
    };
}

private static string MakeSafeFileName(string value)
{
    foreach (var invalidChar in Path.GetInvalidFileNameChars())
    {
        value = value.Replace(invalidChar, '-');
    }

    return value.Replace(" ", "-");
}
}