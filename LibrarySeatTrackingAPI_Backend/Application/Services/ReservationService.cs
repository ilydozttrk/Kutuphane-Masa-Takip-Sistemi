using LibrarySeatTrackingAPI.Application.DTOs; // DTO sınıflarını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IReservationService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Common.Enums; // ReservationStatus ve TableStatus enumlarını kullanmak için
using LibrarySeatTrackingAPI.Domain; // Reservation entity sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext kullanmak için
using Microsoft.EntityFrameworkCore; // Include, AnyAsync, FirstOrDefaultAsync gibi EF Core metotları için

namespace LibrarySeatTrackingAPI.Application.Services; // Bu dosyanın Application/Services katmanına ait olduğunu belirtir

public class ReservationService : IReservationService // ReservationService, IReservationService sözleşmesini uygular
{
    private readonly ApplicationDbContext _db; // Veritabanı işlemleri için kullanılacak DbContext

    public ReservationService(ApplicationDbContext db) // DbContext bağımlılığını dışarıdan alır
    {
        _db = db; // Gelen DbContext'i sınıf içinde kullanmak için saklar
    }

    public async Task<ApiResponseDto<ReservationResponseDto>> CreateAsync(CreateReservationDto request, int userId) // QR kod ile masa alma işlemini yapar
    {
        var userHasActiveReservation = await _db.Reservations.AnyAsync(x =>
            x.UserId == userId &&
            x.Status == ReservationStatus.Active); // Kullanıcının aktif rezervasyonu var mı kontrol eder

        if (userHasActiveReservation) // Kullanıcının aktif rezervasyonu varsa
        {
            return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "You already have an active reservation.", // Kullanıcının zaten aktif rezervasyonu olduğunu belirtir

                Data = null // Veri dönülmez
            };
        }

        var qrCodeRecord = await _db.QrCodeRecords // QR kod tablosundan sorgu başlatır
            .Include(x => x.StudyTable) // QR kodun bağlı olduğu masayı getirir
            .ThenInclude(x => x!.LocationArea) // Masanın bağlı olduğu konum alanını getirir
            .FirstOrDefaultAsync(x => x.Code == request.QrCode && x.IsActive); // Girilen QR kod aktif mi kontrol eder

        if (qrCodeRecord is null || qrCodeRecord.StudyTable is null) // QR kod bulunamazsa veya masaya bağlı değilse
        {
            return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Valid QR code not found.", // Geçerli QR kod bulunamadı mesajı

                Data = null // Veri dönülmez
            };
        }

        var table = qrCodeRecord.StudyTable; // QR kodun bağlı olduğu masa alınır

        if (!table.IsActive) // Masa pasifse
        {
            return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Study table is not active.", // Masa aktif değil mesajı

                Data = null // Veri dönülmez
            };
        }

        if (table.Status != TableStatus.Available) // Masa boş değilse
        {
            return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Study table is not available.", // Masa uygun değil mesajı

                Data = null // Veri dönülmez
            };
        }

        var locationArea = table.LocationArea; // Masanın bağlı olduğu konum alanı alınır

        if (locationArea is null || !locationArea.IsActive) // Konum alanı yoksa veya pasifse
        {
            return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "Location area is not active.", // Konum alanı aktif değil mesajı

                Data = null // Veri dönülmez
            };
        }

        var distanceMeters = CalculateDistanceMeters(
            request.UserLatitude,
            request.UserLongitude,
            locationArea.Latitude,
            locationArea.Longitude); // Kullanıcı konumu ile alan merkezi arasındaki mesafeyi hesaplar

        if (distanceMeters > locationArea.RadiusMeters) // Kullanıcı izin verilen yarıçapın dışındaysa
        {
            return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
            {
                Success = false, // İşlem başarısız

                Message = "You are outside the allowed location area.", // Kullanıcı konum alanı dışında mesajı

                Data = null // Veri dönülmez
            };
        }

        var reservation = new Reservation // Yeni rezervasyon entity nesnesi oluşturur
        {
            UserId = userId, // Token içinden gelen kullanıcı Id bilgisini aktarır

            StudyTableId = table.Id, // QR koddan bulunan masa Id bilgisini aktarır

            StartTime = DateTime.UtcNow, // Rezervasyon başlangıç zamanını şu an olarak ayarlar

            EndTime = DateTime.UtcNow.AddMinutes(request.DurationMinutes), // Rezervasyon bitiş zamanını süreye göre ayarlar

            Status = ReservationStatus.Active // Rezervasyonu aktif başlatır
        };

        table.Status = TableStatus.Occupied; // Masa durumunu dolu yapar

        _db.Reservations.Add(reservation); // Yeni rezervasyonu veritabanına eklenmek üzere hazırlar

        await _db.SaveChangesAsync(); // Rezervasyonu ve masa durumunu veritabanına kaydeder

        var createdReservation = await _db.Reservations // Oluşturulan rezervasyonu ilişkili bilgilerle tekrar sorgular
            .Include(x => x.User) // Rezervasyonu yapan kullanıcıyı getirir
            .Include(x => x.StudyTable) // Rezerve edilen masayı getirir
            .FirstAsync(x => x.Id == reservation.Id); // Oluşturulan rezervasyonu Id ile bulur

        var response = new ReservationResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
        {
            Id = createdReservation.Id, // Rezervasyon Id bilgisini aktarır

            UserId = createdReservation.UserId, // Kullanıcı Id bilgisini aktarır

            UserFullName = createdReservation.User?.FullName ?? string.Empty, // Kullanıcı ad soyad bilgisini aktarır

            StudyTableId = createdReservation.StudyTableId, // Masa Id bilgisini aktarır

            StudyTableCode = createdReservation.StudyTable?.Code ?? string.Empty, // Masa kodunu aktarır

            StartTime = createdReservation.StartTime, // Başlangıç zamanını aktarır

            EndTime = createdReservation.EndTime, // Bitiş zamanını aktarır

            Status = createdReservation.Status // Rezervasyon durumunu aktarır
        };

        return new ApiResponseDto<ReservationResponseDto> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı

            Message = "Reservation created successfully.", // Başarı mesajı

            Data = response // Oluşturulan rezervasyon bilgisi
        };
    }

    public async Task<ApiResponseDto<List<ReservationResponseDto>>> GetMyReservationsAsync(int userId) // Kullanıcının kendi rezervasyonlarını listeler
    {
        var reservations = await _db.Reservations // Reservations tablosundan sorgu başlatır
            .Include(x => x.User) // Kullanıcı bilgisini getirir
            .Include(x => x.StudyTable) // Masa bilgisini getirir
            .Where(x => x.UserId == userId) // Sadece giriş yapan kullanıcıya ait rezervasyonları filtreler
            .OrderByDescending(x => x.StartTime) // En yeni rezervasyonlar önce gelsin diye sıralar
            .Select(x => new ReservationResponseDto // Entity verisini response DTO'ya çevirir
            {
                Id = x.Id, // Rezervasyon Id bilgisi

                UserId = x.UserId, // Kullanıcı Id bilgisi

                UserFullName = x.User != null ? x.User.FullName : string.Empty, // Kullanıcı adı soyadı

                StudyTableId = x.StudyTableId, // Masa Id bilgisi

                StudyTableCode = x.StudyTable != null ? x.StudyTable.Code : string.Empty, // Masa kodu

                StartTime = x.StartTime, // Başlangıç zamanı

                EndTime = x.EndTime, // Bitiş zamanı

                Status = x.Status // Rezervasyon durumu
            })
            .ToListAsync(); // Sorguyu çalıştırır ve listeye çevirir

        return new ApiResponseDto<List<ReservationResponseDto>> // Standart API cevabı döner
        {
            Success = true, // İşlem başarılı

            Message = "Reservations listed successfully.", // Başarı mesajı

            Data = reservations // Rezervasyon listesi
        };
    }
    public async Task<ApiResponseDto<ReservationResponseDto>> CompleteAsync(int reservationId, int userId) // Öğrencinin aktif rezervasyonunu sonlandırır
        {
            var reservation = await _db.Reservations // Reservations tablosundan sorgu başlatır
                .Include(x => x.User) // Rezervasyonu yapan kullanıcıyı getirir
                .Include(x => x.StudyTable) // Rezervasyonun bağlı olduğu masayı getirir
                .FirstOrDefaultAsync(x =>
                    x.Id == reservationId &&
                    x.UserId == userId &&
                    x.Status == ReservationStatus.Active); // Sadece giriş yapan kullanıcının aktif rezervasyonunu arar

            if (reservation is null) // Rezervasyon bulunamazsa
            {
                return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
                {
                    Success = false, // İşlem başarısız

                    Message = "Active reservation not found.", // Aktif rezervasyon bulunamadı mesajı

                    Data = null // Veri dönülmez
                };
            }

            reservation.Status = ReservationStatus.Completed; // Rezervasyon durumunu tamamlandı yapar

            reservation.EndTime = DateTime.UtcNow; // Rezervasyon bitiş zamanını şu an olarak günceller

            if (reservation.StudyTable is not null) // Rezervasyona bağlı masa varsa
            {
                reservation.StudyTable.Status = TableStatus.Available; // Masayı tekrar boş hale getirir
            }

            await _db.SaveChangesAsync(); // Rezervasyon ve masa durumunu veritabanına kaydeder

            var response = new ReservationResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
            {
                Id = reservation.Id, // Rezervasyon Id bilgisini aktarır

                UserId = reservation.UserId, // Kullanıcı Id bilgisini aktarır

                UserFullName = reservation.User?.FullName ?? string.Empty, // Kullanıcı ad soyad bilgisini aktarır

                StudyTableId = reservation.StudyTableId, // Masa Id bilgisini aktarır

                StudyTableCode = reservation.StudyTable?.Code ?? string.Empty, // Masa kodunu aktarır

                StartTime = reservation.StartTime, // Başlangıç zamanını aktarır

                EndTime = reservation.EndTime, // Bitiş zamanını aktarır

                Status = reservation.Status // Rezervasyon durumunu aktarır
            };

            return new ApiResponseDto<ReservationResponseDto> // Standart API cevabı döner
            {
                Success = true, // İşlem başarılı

                Message = "Reservation completed successfully.", // Başarı mesajı

                Data = response // Sonlandırılan rezervasyon bilgisi
            };
        }
        public async Task<ApiResponseDto<ReservationResponseDto>> ForceCompleteAsync(int reservationId, ForceCompleteReservationDto request) // Staff veya Admin tarafından aktif rezervasyonu açıklama ile sonlandırır
        {
            var reservation = await _db.Reservations // Reservations tablosundan sorgu başlatır
                .Include(x => x.User) // Rezervasyonu yapan kullanıcıyı getirir
                .Include(x => x.StudyTable) // Rezervasyonun bağlı olduğu masayı getirir
                .FirstOrDefaultAsync(x =>
                    x.Id == reservationId &&
                    x.Status == ReservationStatus.Active); // Sadece aktif rezervasyonu arar

            if (reservation is null) // Aktif rezervasyon bulunamazsa
            {
                return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
                {
                    Success = false, // İşlem başarısız

                    Message = "Active reservation not found.", // Aktif rezervasyon bulunamadı mesajı

                    Data = null // Veri dönülmez
                };
            }

            reservation.Status = ReservationStatus.Completed; // Rezervasyon durumunu tamamlandı yapar

            reservation.EndTime = DateTime.UtcNow; // Rezervasyon bitiş zamanını şu an olarak günceller

            reservation.StaffNote = request.Note; // Staff veya Admin tarafından yazılan açıklama notunu kaydeder

            if (reservation.StudyTable is not null) // Rezervasyona bağlı masa varsa
            {
                reservation.StudyTable.Status = TableStatus.Available; // Masayı tekrar boş hale getirir
            }

            await _db.SaveChangesAsync(); // Rezervasyon ve masa durumunu veritabanına kaydeder

            var response = new ReservationResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
            {
                Id = reservation.Id, // Rezervasyon Id bilgisini aktarır

                UserId = reservation.UserId, // Kullanıcı Id bilgisini aktarır

                UserFullName = reservation.User?.FullName ?? string.Empty, // Kullanıcı ad soyad bilgisini aktarır

                StudyTableId = reservation.StudyTableId, // Masa Id bilgisini aktarır

                StudyTableCode = reservation.StudyTable?.Code ?? string.Empty, // Masa kodunu aktarır

                StartTime = reservation.StartTime, // Başlangıç zamanını aktarır

                EndTime = reservation.EndTime, // Bitiş zamanını aktarır

                Status = reservation.Status, // Rezervasyon durumunu aktarır

                StaffNote = reservation.StaffNote // Staff/Admin sonlandırma notunu aktarır
            };

            return new ApiResponseDto<ReservationResponseDto> // Standart API cevabı döner
            {
                Success = true, // İşlem başarılı

                Message = "Reservation force completed successfully.", // Başarı mesajı

                Data = response // Sonlandırılan rezervasyon bilgisi
            };
        }

        public async Task<ApiResponseDto<ReservationResponseDto>> RenewAsync(RenewReservationDto request, int userId) // Öğrencinin QR kod ile aktif oturumunu yenilemesini sağlar
{
    var reservation = await _db.Reservations // Reservations tablosundan sorgu başlatır
        .Include(x => x.User) // Rezervasyonu yapan kullanıcıyı getirir
        .Include(x => x.StudyTable) // Rezervasyonun bağlı olduğu masayı getirir
        .ThenInclude(x => x!.LocationArea) // Masanın bağlı olduğu konum alanını getirir
        .FirstOrDefaultAsync(x =>
            x.UserId == userId &&
            x.Status == ReservationStatus.Active); // Kullanıcının aktif rezervasyonunu bulur

    if (reservation is null) // Aktif rezervasyon yoksa
    {
        return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
        {
            Success = false, // İşlem başarısız
            Message = "Active reservation not found.", // Aktif rezervasyon bulunamadı mesajı
            Data = null // Veri dönülmez
        };
    }

    var qrCodeRecord = await _db.QrCodeRecords // QR kod tablosundan sorgu başlatır
        .FirstOrDefaultAsync(x =>
            x.Code == request.QrCode &&
            x.IsActive &&
            x.StudyTableId == reservation.StudyTableId); // QR kod aktif mi ve aynı masaya mı ait kontrol eder

    if (qrCodeRecord is null) // QR kod geçersizse veya başka masaya aitse
    {
        return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
        {
            Success = false, // İşlem başarısız
            Message = "Valid QR code for this reservation not found.", // Bu rezervasyon için geçerli QR kod bulunamadı
            Data = null // Veri dönülmez
        };
    }

    var table = reservation.StudyTable; // Rezervasyona bağlı masayı alır

    if (table is null || !table.IsActive) // Masa yoksa veya pasifse
    {
        return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
        {
            Success = false, // İşlem başarısız
            Message = "Study table is not active.", // Masa aktif değil mesajı
            Data = null // Veri dönülmez
        };
    }

    var locationArea = table.LocationArea; // Masanın konum alanını alır

    if (locationArea is null || !locationArea.IsActive) // Konum alanı yoksa veya pasifse
    {
        return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
        {
            Success = false, // İşlem başarısız
            Message = "Location area is not active.", // Konum alanı aktif değil mesajı
            Data = null // Veri dönülmez
        };
    }

    var distanceMeters = CalculateDistanceMeters(
        request.UserLatitude,
        request.UserLongitude,
        locationArea.Latitude,
        locationArea.Longitude); // Kullanıcı konumu ile alan merkezi arasındaki mesafeyi hesaplar

    if (distanceMeters > locationArea.RadiusMeters) // Kullanıcı izin verilen alan dışındaysa
    {
        return new ApiResponseDto<ReservationResponseDto> // Başarısız cevap döner
        {
            Success = false, // İşlem başarısız
            Message = "You are outside the allowed location area.", // Kullanıcı konum alanı dışında mesajı
            Data = null // Veri dönülmez
        };
    }

    reservation.RenewCount += 1; // Yenileme sayısını artırır

    reservation.LastRenewedAt = DateTime.UtcNow; // Son yenileme zamanını günceller

    reservation.EndTime = DateTime.UtcNow.AddMinutes(request.ExtraMinutes); // Yeni bitiş zamanını ayarlar

    await _db.SaveChangesAsync(); // Değişiklikleri veritabanına kaydeder

    var response = new ReservationResponseDto // Kullanıcıya dönecek response DTO'sunu oluşturur
    {
        Id = reservation.Id, // Rezervasyon Id bilgisi
        UserId = reservation.UserId, // Kullanıcı Id bilgisi
        UserFullName = reservation.User?.FullName ?? string.Empty, // Kullanıcı ad soyad bilgisi
        StudyTableId = reservation.StudyTableId, // Masa Id bilgisi
        StudyTableCode = reservation.StudyTable?.Code ?? string.Empty, // Masa kodu
        StartTime = reservation.StartTime, // Başlangıç zamanı
        EndTime = reservation.EndTime, // Yeni bitiş zamanı
        Status = reservation.Status, // Rezervasyon durumu
        StaffNote = reservation.StaffNote // Staff/Admin notu varsa döner
    };

    return new ApiResponseDto<ReservationResponseDto> // Standart API cevabı döner
    {
        Success = true, // İşlem başarılı
        Message = "Reservation renewed successfully.", // Başarı mesajı
        Data = response // Yenilenen rezervasyon bilgisi
    };
}
    private static double CalculateDistanceMeters(double userLat, double userLng, double areaLat, double areaLng) // İki koordinat arası mesafeyi metre cinsinden hesaplar
    {
        const double earthRadiusMeters = 6371000; // Dünya yarıçapı metre cinsinden yaklaşık değer

        var userLatRad = DegreesToRadians(userLat); // Kullanıcı enlemini radyana çevirir

        var areaLatRad = DegreesToRadians(areaLat); // Alan enlemini radyana çevirir

        var latDifference = DegreesToRadians(areaLat - userLat); // Enlem farkını radyana çevirir

        var lngDifference = DegreesToRadians(areaLng - userLng); // Boylam farkını radyana çevirir

        var a =
            Math.Sin(latDifference / 2) * Math.Sin(latDifference / 2) +
            Math.Cos(userLatRad) * Math.Cos(areaLatRad) *
            Math.Sin(lngDifference / 2) * Math.Sin(lngDifference / 2); // Haversine formülünün ara değeri

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a)); // Açısal mesafeyi hesaplar

        return earthRadiusMeters * c; // Metre cinsinden mesafeyi döner
    }

    private static double DegreesToRadians(double degrees) // Dereceyi radyana çevirir
    {
        return degrees * Math.PI / 180; // Derece-radyan dönüşüm formülü
    }
}