using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IUserDeviceTokenService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için
using System.Security.Claims; // Token içinden kullanıcı Id okumak için

namespace LibrarySeatTrackingAPI.Controllers; // Controllers klasörüne ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/device-tokens")] // Endpoint adreslerini api/device-tokens olarak başlatır
public class UserDeviceTokensController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IUserDeviceTokenService _userDeviceTokenService; // Cihaz token işlemleri için service

    public UserDeviceTokensController(IUserDeviceTokenService userDeviceTokenService) // Service bağımlılığını dışarıdan alır
    {
        _userDeviceTokenService = userDeviceTokenService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize] // Giriş yapan kullanıcı cihaz tokenını kaydedebilir
    [HttpPost("register")] // POST api/device-tokens/register endpointini oluşturur
    public async Task<IActionResult> Register(RegisterDeviceTokenDto request) // Mobil cihaz FCM tokenını kaydeder
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized döner
        }

        var result = await _userDeviceTokenService.RegisterAsync(request, userId); // Token kaydetme işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK döner
    }
}