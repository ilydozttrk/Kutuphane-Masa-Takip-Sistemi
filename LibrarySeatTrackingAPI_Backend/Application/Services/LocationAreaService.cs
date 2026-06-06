using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // ILocationAreaService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Domain; // LocationArea entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // ToListAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Bu dosyanın Application/Services katmanına ait olduğunu belirtir

public class LocationAreaService : ILocationAreaService // LocationAreaService, ILocationAreaService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public LocationAreaService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<LocationAreaResponseDto>> CreateAsync(CreateLocationAreaDto request) // Yeni konum alanı oluşturur
    {
        var locationArea = new LocationArea // Yeni LocationArea entity nesnesi oluşturur
        {
            Name = request.Name, // DTO'dan gelen konum alanı adını entity'ye aktarır

            Latitude = request.Latitude, // DTO'dan gelen enlem bilgisini entity'ye aktarır

            Longitude = request.Longitude, // DTO'dan gelen boylam bilgisini entity'ye aktarır

            RadiusMeters = request.RadiusMeters, // DTO'dan gelen yarıçap bilgisini entity'ye aktarır

            IsActive = true // Yeni oluşturulan konum alanını aktif başlatır
        };

        _db.LocationAreas.Add(locationArea); // Yeni konum alanını veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Değişiklikleri veritabanına kaydeder

        var response = new LocationAreaResponseDto // Kullanıcıya dönecek cevap DTO'sunu oluşturur
        {
            Id = locationArea.Id, // Oluşan konum alanının Id bilgisini aktarır

            Name = locationArea.Name, // Konum alanı adını aktarır

            Latitude = locationArea.Latitude, // Enlem bilgisini aktarır

            Longitude = locationArea.Longitude, // Boylam bilgisini aktarır

            RadiusMeters = locationArea.RadiusMeters, // Yarıçap bilgisini aktarır

            IsActive = locationArea.IsActive, // Aktiflik bilgisini aktarır

            CreatedAt = locationArea.CreatedAt // Oluşturulma tarihini aktarır
        };

        return new ApiResponseDto<LocationAreaResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlemin başarılı olduğunu belirtir

            Message = "Location area created successfully.", // Başarı mesajı

            Data = response // Oluşturulan konum alanı bilgisi
        };
    }

    public async Task<ApiResponseDto<List<LocationAreaResponseDto>>> GetAllAsync() // Tüm konum alanlarını listeler
    {
        var locationAreas = await _db.LocationAreas // LocationAreas tablosundan sorgu başlatır
            .OrderByDescending(x => x.CreatedAt) // En yeni eklenenler önce gelsin diye sıralar
            .Select(x => new LocationAreaResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Konum alanı Id bilgisi

                Name = x.Name, // Konum alanı adı

                Latitude = x.Latitude, // Enlem bilgisi

                Longitude = x.Longitude, // Boylam bilgisi

                RadiusMeters = x.RadiusMeters, // Yarıçap bilgisi

                IsActive = x.IsActive, // Aktiflik bilgisi

                CreatedAt = x.CreatedAt // Oluşturulma tarihi
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<LocationAreaResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlemin başarılı olduğunu belirtir

            Message = "Location areas listed successfully.", // Başarı mesajı

            Data = locationAreas // Konum alanı listesi
        };
    }
}