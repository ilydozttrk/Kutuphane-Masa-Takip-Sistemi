using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase, ApiController, Route gibi yapılar için
using System.Security.Claims; // Token içindeki kullanıcı bilgilerini okumak için

namespace LibrarySeatTrackingAPI.Controllers; // Bu dosyanın Controllers katmanına ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/[controller]")] // Route adresini api/test şeklinde oluşturur
public class TestController : ControllerBase // API controller temel sınıfından miras alır
{
    [Authorize] // Bu endpoint'e sadece geçerli JWT token ile erişilebilir
    [HttpGet("secure")] // GET api/test/secure endpointini oluşturur
    public IActionResult Secure() // Token doğrulama testi için endpoint

    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        var fullName = User.FindFirstValue(ClaimTypes.Name); // Token içinden ad soyad bilgisini okur

        var email = User.FindFirstValue(ClaimTypes.Email); // Token içinden e-posta bilgisini okur

        var role = User.FindFirstValue(ClaimTypes.Role); // Token içinden rol bilgisini okur

        return Ok(new // Başarılı cevap döner
        {
            Message = "Token geçerli, korumalı endpoint'e eriştin.", // Test mesajı

            UserId = userId, // Token içinden gelen kullanıcı Id

            FullName = fullName, // Token içinden gelen ad soyad

            Email = email, // Token içinden gelen e-posta

            Role = role // Token içinden gelen rol
        });
    }

    
        [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin rolündeki kullanıcılar erişebilir
        [HttpGet("admin-only")] // GET api/test/admin-only endpointini oluşturur
        public IActionResult AdminOnly() // Admin rol testi için endpoint
        {
            var email = User.FindFirstValue(ClaimTypes.Email); // Token içinden e-posta bilgisini okur

            var role = User.FindFirstValue(ClaimTypes.Role); // Token içinden rol bilgisini okur

            return Ok(new // Başarılı cevap döner
            {
                Message = "Bu endpoint'e sadece Admin erişebilir.", // Test mesajı

                Email = email, // Token içinden gelen e-posta

                Role = role // Token içinden gelen rol
            });
        }
}