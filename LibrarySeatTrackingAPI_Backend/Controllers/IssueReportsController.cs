using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IIssueReportService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için
using System.Security.Claims; // Token içinden kullanıcı Id okumak için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/issue-reports")] // Endpoint adreslerini api/issue-reports olarak başlatır
public class IssueReportsController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IIssueReportService _issueReportService; // Sorun bildirimi işlemleri için service

    public IssueReportsController(IIssueReportService issueReportService) // Service bağımlılığını dışarıdan alır
    {
        _issueReportService = issueReportService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize] // Giriş yapmış tüm kullanıcılar sorun bildirimi oluşturabilir
    [HttpPost] // POST api/issue-reports endpointini oluşturur
    public async Task<IActionResult> Create(CreateIssueReportDto request) // Yeni sorun bildirimi oluşturur
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized cevabı döner
        }

        var result = await _issueReportService.CreateAsync(request, userId); // Sorun bildirimi oluşturma işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request cevabı döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
    }

    [Authorize] // Giriş yapmış tüm kullanıcılar kendi bildirimlerini görebilir
    [HttpGet("my")] // GET api/issue-reports/my endpointini oluşturur
    public async Task<IActionResult> GetMyReports() // Kullanıcının kendi sorun bildirimlerini listeler
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized cevabı döner
        }

        var result = await _issueReportService.GetMyReportsAsync(userId); // Kullanıcının sorun bildirimlerini service'ten ister

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }

    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e sadece Admin ve Staff rolündeki kullanıcılar erişebilir
    [HttpGet] // GET api/issue-reports endpointini oluşturur
    public async Task<IActionResult> GetAll() // Tüm sorun bildirimlerini listeler
    {
        var result = await _issueReportService.GetAllAsync(); // Tüm sorun bildirimlerini service'ten ister

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }
    
    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e sadece Admin ve Staff erişebilir
    [HttpPut("{issueReportId}/status")] // PUT api/issue-reports/1/status endpointini oluşturur
    public async Task<IActionResult> UpdateStatus(int issueReportId, UpdateIssueReportStatusDto request) // Sorun bildirimi durumunu günceller
    {
        var result = await _issueReportService.UpdateStatusAsync(issueReportId, request); // Durum güncelleme işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK döner
    }
}