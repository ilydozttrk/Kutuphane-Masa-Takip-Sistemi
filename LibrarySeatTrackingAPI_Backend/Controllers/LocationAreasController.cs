using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // ILocationAreaService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/location-areas")] // Endpoint adreslerini api/location-areas olarak başlatır
public class LocationAreasController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly ILocationAreaService _locationAreaService; // Konum alanı işlemleri için service

    public LocationAreasController(ILocationAreaService locationAreaService) // Service bağımlılığını dışarıdan alır
    {
        _locationAreaService = locationAreaService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin rolündeki kullanıcılar erişebilir
    [HttpPost] // POST api/location-areas endpointini oluşturur
    public async Task<IActionResult> Create(CreateLocationAreaDto request) // Yeni konum alanı ekler
    {
        var result = await _locationAreaService.CreateAsync(request); // Ekleme işlemini service'e gönderir

        return Ok(result); // Başarılı cevabı döner
    }

    [Authorize] // Bu endpoint'e giriş yapmış tüm kullanıcılar erişebilir
    [HttpGet] // GET api/location-areas endpointini oluşturur
    public async Task<IActionResult> GetAll() // Tüm konum alanlarını listeler
    {
        var result = await _locationAreaService.GetAllAsync(); // Listeleme işlemini service'e gönderir

        return Ok(result); // Liste sonucunu döner
    }
}