using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IQueueEntryService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için
using System.Security.Claims; // Token içinden kullanıcı Id okumak için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/queue-entries")] // Endpoint adreslerini api/queue-entries olarak başlatır
public class QueueEntriesController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IQueueEntryService _queueEntryService; // Sıra işlemleri için service

    public QueueEntriesController(IQueueEntryService queueEntryService) // Service bağımlılığını dışarıdan alır
    {
        _queueEntryService = queueEntryService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize(Roles = "Student")] // Bu endpoint'e sadece Student rolündeki kullanıcılar erişebilir
    [HttpPost] // POST api/queue-entries endpointini oluşturur
    public async Task<IActionResult> Create(CreateQueueEntryDto request) // Öğrencinin masa için sıraya girmesini sağlar
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized cevabı döner
        }

        var result = await _queueEntryService.CreateAsync(request, userId); // Sıraya girme işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request cevabı döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
    }

    [Authorize(Roles = "Student")] // Bu endpoint'e sadece Student rolündeki kullanıcılar erişebilir
    [HttpGet("my")] // GET api/queue-entries/my endpointini oluşturur
    public async Task<IActionResult> GetMyQueueEntries() // Öğrencinin kendi sıra kayıtlarını listeler
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized cevabı döner
        }

        var result = await _queueEntryService.GetMyQueueEntriesAsync(userId); // Kullanıcının sıra kayıtlarını service'ten ister

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }

    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e sadece Admin ve Staff rolündeki kullanıcılar erişebilir
    [HttpGet] // GET api/queue-entries endpointini oluşturur
    public async Task<IActionResult> GetAll() // Tüm sıra kayıtlarını listeler
    {
        var result = await _queueEntryService.GetAllAsync(); // Tüm sıra kayıtlarını service'ten ister

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }
    
    [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e sadece Admin ve Staff erişebilir
        [HttpPut("{queueEntryId}/status")] // PUT api/queue-entries/1/status endpointini oluşturur
        public async Task<IActionResult> UpdateStatus(int queueEntryId, UpdateQueueEntryStatusDto request) // Sıra kaydının durumunu günceller
        {
            var result = await _queueEntryService.UpdateStatusAsync(queueEntryId, request); // Durum güncelleme işlemini service'e gönderir

            if (!result.Success) // İşlem başarısızsa
            {
                return BadRequest(result); // 400 Bad Request döner
            }

            return Ok(result); // İşlem başarılıysa 200 OK döner
        }
}