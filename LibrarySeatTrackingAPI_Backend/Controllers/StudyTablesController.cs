using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IStudyTableService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/study-tables")] // Endpoint adreslerini api/study-tables olarak başlatır
public class StudyTablesController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IStudyTableService _studyTableService; // Masa işlemleri için service

    public StudyTablesController(IStudyTableService studyTableService) // Service bağımlılığını dışarıdan alır
    {
        _studyTableService = studyTableService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin rolündeki kullanıcılar erişebilir
    [HttpPost] // POST api/study-tables endpointini oluşturur
    public async Task<IActionResult> Create(CreateStudyTableDto request) // Yeni masa ekler
    {
        var result = await _studyTableService.CreateAsync(request); // Masa ekleme işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request cevabı döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
    }

    [Authorize] // Bu endpoint'e giriş yapmış tüm kullanıcılar erişebilir
    [HttpGet] // GET api/study-tables endpointini oluşturur
    public async Task<IActionResult> GetAll() // Tüm masaları listeler
    {
        var result = await _studyTableService.GetAllAsync(); // Masa listeleme işlemini service'e gönderir

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }

    [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin erişebilir
    [HttpPut("{studyTableId}/status")] // PUT api/study-tables/1/status endpointini oluşturur
    public async Task<IActionResult> UpdateStatus(int studyTableId, UpdateStudyTableStatusDto request) // Masa durumunu günceller
    {
        var result = await _studyTableService.UpdateStatusAsync(studyTableId, request); // Durum güncelleme işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK döner
    }
}