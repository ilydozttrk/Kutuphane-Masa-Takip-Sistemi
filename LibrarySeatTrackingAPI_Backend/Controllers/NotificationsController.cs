using LibrarySeatTrackingAPI.Application.Interfaces; // INotificationService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için
using System.Security.Claims; // Token içinden kullanıcı Id okumak için

namespace LibrarySeatTrackingAPI.Controllers; // Controllers klasörüne ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/notifications")] // Endpoint adreslerini api/notifications olarak başlatır
public class NotificationsController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly INotificationService _notificationService; // Bildirim işlemleri için service

    public NotificationsController(INotificationService notificationService) // Service bağımlılığını dışarıdan alır
    {
        _notificationService = notificationService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize] // Giriş yapan tüm kullanıcılar kendi bildirimlerini görebilir
    [HttpGet("my")] // GET api/notifications/my endpointini oluşturur
    public async Task<IActionResult> GetMyNotifications() // Kullanıcının kendi bildirimlerini listeler
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized döner
        }

        var result = await _notificationService.GetMyNotificationsAsync(userId); // Kullanıcının bildirimlerini service'ten ister

        return Ok(result); // Liste sonucunu 200 OK döner
    }

    [Authorize] // Giriş yapan kullanıcı kendi bildirimini okundu yapabilir
    [HttpPut("{notificationId}/read")] // PUT api/notifications/1/read endpointini oluşturur
    public async Task<IActionResult> MarkAsRead(int notificationId) // Bildirimi okundu yapar
    {
        var userIdText = User.FindFirstValue(ClaimTypes.NameIdentifier); // Token içinden kullanıcı Id bilgisini okur

        if (!int.TryParse(userIdText, out var userId)) // Kullanıcı Id sayıya çevrilemezse
        {
            return Unauthorized(); // 401 Unauthorized döner
        }

        var result = await _notificationService.MarkAsReadAsync(notificationId, userId); // Bildirimi okundu yapma işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK döner
    }
}