using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IReservationService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için
using System.Security.Claims; // Token içinden kullanıcı Id okumak için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/reservations")] // Endpoint adreslerini api/reservations olarak başlatır
public class ReservationsController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IReservationService _reservationService; // Rezervasyon işlemleri için service

    public ReservationsController(IReservationService reservationService) // Service bağımlılığını dışarıdan alır
    {
        _reservationService = reservationService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize(Roles = "Student")] // Bu endpoint'e sadece Student rolündeki kullanıcılar erişebilir
    [HttpPost] // POST api/reservations endpointini oluşturur
    public async Task<IActionResult> Create(CreateReservationDto request) // QR kod ile yeni rezervasyon oluşturur
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized cevabı döner
        }

        var result = await _reservationService.CreateAsync(request, userId); // Rezervasyon oluşturma işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request cevabı döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
    }

    [Authorize(Roles = "Student")] // Bu endpoint'e sadece Student rolündeki kullanıcılar erişebilir
    [HttpGet("my")] // GET api/reservations/my endpointini oluşturur
    public async Task<IActionResult> GetMyReservations() // Giriş yapan öğrencinin kendi rezervasyonlarını listeler
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized cevabı döner
        }

        var result = await _reservationService.GetMyReservationsAsync(userId); // Kullanıcının rezervasyonlarını service'ten ister

        return Ok(result); // Liste sonucunu 200 OK olarak döner
    }
        [Authorize(Roles = "Student")] // Bu endpoint'e sadece Student rolündeki kullanıcılar erişebilir
        [HttpPut("{reservationId}/complete")] // PUT api/reservations/1/complete endpointini oluşturur
        public async Task<IActionResult> Complete(int reservationId) // Öğrencinin aktif rezervasyonunu sonlandırır
        {
            var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

            if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
            {
                return Unauthorized(); // 401 Unauthorized cevabı döner
            }

            var result = await _reservationService.CompleteAsync(reservationId, userId); // Rezervasyon sonlandırma işlemini service'e gönderir

            if (!result.Success) // İşlem başarısızsa
            {
                return BadRequest(result); // 400 Bad Request cevabı döner
            }

            return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
        }


        [Authorize(Roles = "Admin,Staff")] // Bu endpoint'e sadece Admin ve Staff rolündeki kullanıcılar erişebilir
        [HttpPut("{reservationId}/force-complete")] // PUT api/reservations/1/force-complete endpointini oluşturur
        public async Task<IActionResult> ForceComplete(int reservationId, ForceCompleteReservationDto request) // Staff/Admin aktif rezervasyonu açıklama ile sonlandırır
        {
            var result = await _reservationService.ForceCompleteAsync(reservationId, request); // Zorla sonlandırma işlemini service'e gönderir

            if (!result.Success) // İşlem başarısızsa
            {
                return BadRequest(result); // 400 Bad Request cevabı döner
            }

            return Ok(result); // İşlem başarılıysa 200 OK cevabı döner
        }

        [Authorize(Roles = "Student")] // Bu endpoint'e sadece Student rolündeki kullanıcılar erişebilir
[HttpPost("renew")] // POST api/reservations/renew endpointini oluşturur
public async Task<IActionResult> Renew(RenewReservationDto request) // Öğrencinin aktif rezervasyonunu QR kod ile yeniler
{
    var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

    if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
    {
        return Unauthorized(); // 401 Unauthorized döner
    }

    var result = await _reservationService.RenewAsync(request, userId); // Yenileme işlemini service'e gönderir

    if (!result.Success) // İşlem başarısızsa
    {
        return BadRequest(result); // 400 Bad Request döner
    }

    return Ok(result); // İşlem başarılıysa 200 OK döner
}
}