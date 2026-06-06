using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IBlockRecordService interface'ini kullanmak için
using Microsoft.AspNetCore.Authorization; // [Authorize] attribute'u için
using Microsoft.AspNetCore.Mvc; // ControllerBase ve API attribute'ları için

namespace LibrarySeatTrackingAPI.Controllers; // Controllers klasörüne ait olduğunu belirtir

[ApiController] // Bu sınıfın API controller olduğunu belirtir
[Route("api/block-records")] // Endpoint adreslerini api/block-records olarak başlatır
public class BlockRecordsController : ControllerBase // API controller temel sınıfından miras alır
{
    private readonly IBlockRecordService _blockRecordService; // Bloke işlemleri için service

    public BlockRecordsController(IBlockRecordService blockRecordService) // Service bağımlılığını dışarıdan alır
    {
        _blockRecordService = blockRecordService; // Gelen service nesnesini sınıf içinde kullanmak için saklar
    }

    [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin erişebilir
    [HttpPost] // POST api/block-records endpointini oluşturur
    public async Task<IActionResult> Create(CreateBlockRecordDto request) // Kullanıcıyı bloke eder
    {
        var result = await _blockRecordService.CreateAsync(request); // Bloke işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK döner
    }

    [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin erişebilir
    [HttpGet] // GET api/block-records endpointini oluşturur
    public async Task<IActionResult> GetAll() // Tüm bloke kayıtlarını listeler
    {
        var result = await _blockRecordService.GetAllAsync(); // Bloke kayıtlarını service'ten ister

        return Ok(result); // Liste sonucunu 200 OK döner
    }

    [Authorize(Roles = "Admin")] // Bu endpoint'e sadece Admin erişebilir
    [HttpPut("{blockRecordId}/remove")] // PUT api/block-records/1/remove endpointini oluşturur
    public async Task<IActionResult> RemoveBlock(int blockRecordId) // Aktif blokeyi kaldırır
    {
        var result = await _blockRecordService.RemoveBlockAsync(blockRecordId); // Bloke kaldırma işlemini service'e gönderir

        if (!result.Success) // İşlem başarısızsa
        {
            return BadRequest(result); // 400 Bad Request döner
        }

        return Ok(result); // İşlem başarılıysa 200 OK döner
    }
}