using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IQrCodeRecordService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için
using System.Net; // HttpStatusCode kullanmak için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/qr-code-records")] // Endpoint adreslerini api/qr-code-records olarak başlatır
public class QrCodeRecordsController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IQrCodeRecordService _qrCodeRecordService; // QR kod işlemleri için service

    public QrCodeRecordsController(IQrCodeRecordService qrCodeRecordService) // Service bağımlılığını dışarıdan alır
    {
        _qrCodeRecordService = qrCodeRecordService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e Admin ve Staff rolündeki kullanıcılar erişebilir
    [HttpPost] // POST api/qr-code-records endpointini oluşturur
    public async Task<IActionResult> Create(CreateQrCodeRecordDto request) // Yeni QR kod kaydı ekler
    {
        var result = await _qrCodeRecordService.CreateAsync(request); // QR kod ekleme işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request cevabı döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
    }

    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e Admin ve Staff rolündeki kullanıcılar erişebilir
    [HttpGet] // GET api/qr-code-records endpointini oluşturur
    public async Task<IActionResult> GetAll() // Tüm QR kod kayıtlarını listeler
    {
        var result = await _qrCodeRecordService.GetAllAsync(); // QR kod listeleme işlemini service'e gönderir

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }
    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e Admin ve Staff erişebilir
        [HttpPut("{qrCodeRecordId}/status")] // PUT api/qr-code-records/1/status endpointini oluşturur
        public async Task<IActionResult> UpdateStatus(int qrCodeRecordId, UpdateQrCodeStatusDto request) // QR kodu aktif/pasif yapar
        {
            var result = await _qrCodeRecordService.UpdateStatusAsync(qrCodeRecordId, request); // Durum güncelleme işlemini service'e gönderir

            if (!result.Success) // İşlem başarısızsa
            {
                return BadRequest(result); // 400 Bad Request döner
            }

            return Ok(result); // İşlem başarılıysa 200 OK döner
        }
        [Authorize(Roles = "Admin,Staff")]
[HttpGet("{qrCodeRecordId}/image")]
public async Task<IActionResult> GetQrCodeImage(int qrCodeRecordId)
{
    var result = await _qrCodeRecordService.GetQrCodePngAsync(qrCodeRecordId);

    if (!result.Success || result.Data is null)
    {
        return BadRequest(result);
    }

    return File(result.Data.FileBytes, result.Data.ContentType);
}

[Authorize(Roles = "Admin,Staff")]
[HttpGet("{qrCodeRecordId}/download")]
public async Task<IActionResult> DownloadQrCodeImage(int qrCodeRecordId)
{
    var result = await _qrCodeRecordService.GetQrCodePngAsync(qrCodeRecordId);

    if (!result.Success || result.Data is null)
    {
        return BadRequest(result);
    }

    return File(result.Data.FileBytes, result.Data.ContentType, result.Data.FileName);
}

[Authorize(Roles = "Admin,Staff")]
[HttpGet("{qrCodeRecordId}/print")]
public async Task<IActionResult> PrintQrCode(int qrCodeRecordId)
{
    var result = await _qrCodeRecordService.GetQrCodePngAsync(qrCodeRecordId);

    if (!result.Success || result.Data is null)
    {
        return BadRequest(result);
    }

    var qrBase64 = Convert.ToBase64String(result.Data.FileBytes);
    var tableCode = WebUtility.HtmlEncode(result.Data.StudyTableCode);
    var code = WebUtility.HtmlEncode(result.Data.Code);

    var html = $$"""
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="utf-8" />
    <title>Masa QR Kodu - {{tableCode}}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: #f5f5f5;
        }

        .card {
            width: 420px;
            padding: 32px;
            background: white;
            border: 1px solid #ddd;
            border-radius: 12px;
            text-align: center;
        }

        h1 {
            font-size: 22px;
            margin-bottom: 8px;
        }

        h2 {
            font-size: 28px;
            margin: 12px 0 24px;
        }

        img {
            width: 280px;
            height: 280px;
        }

        .code {
            margin-top: 20px;
            font-size: 14px;
            word-break: break-all;
        }

        .note {
            margin-top: 16px;
            font-size: 13px;
            color: #555;
        }

        @media print {
            body {
                background: white;
            }

            .card {
                border: 1px solid #000;
            }
        }
    </style>
</head>
<body onload="window.print()">
    <div class="card">
        <h1>Library Seat Tracking API</h1>
        <h2>Masa: {{tableCode}}</h2>

        <img src="data:image/png;base64,{{qrBase64}}" alt="QR Code" />

        <p class="code">
            QR Kod: {{code}}
        </p>

        <p class="note">
            Bu QR kod ilgili masaya aittir. Öğrenci mobil uygulama ile okutarak masa rezervasyonu oluşturur veya oturumunu yeniler.
        </p>
    </div>
</body>
</html>
""";

    return Content(html, "text/html; charset=utf-8");
}
}