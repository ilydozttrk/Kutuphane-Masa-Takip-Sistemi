using LibrarySeatTrackingAPI.Common.Enums; // UserRole ve TableStatus enumlarını kullanmak için
using LibrarySeatTrackingAPI.Domain; // User, LocationArea, StudyTable, QrCodeRecord entitylerini kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext sınıfını kullanmak için
using Microsoft.EntityFrameworkCore; // AnyAsync gibi EF Core metotlarını kullanmak için

namespace LibrarySeatTrackingAPI.Infrastructure.Seed; // Bu dosyanın Infrastructure/Seed katmanına ait olduğunu belirtir

public static class DataSeeder
{
    public static async Task SeedAsync(ApplicationDbContext db) // Veritabanına başlangıç verilerini ekleyen metot
    {
        if (await db.Users.AnyAsync()) // Users tablosunda herhangi bir kullanıcı varsa seed işlemini tekrar yapmaz
        {
            return; // Veri zaten varsa metottan çıkar
        }

        var admin = new User // Admin kullanıcısı oluşturulur
        {
            FullName = "Test Admin", // Admin kullanıcısının adı soyadı
            Email = "admin@example.com", // Admin giriş e-postası
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123*"), // Admin şifresinin hashlenmiş hali
            Role = UserRole.Admin, // Kullanıcının rolü Admin
            IsBlocked = false // Kullanıcı blokeli değil
        };

        var staff = new User // Kütüphane görevlisi kullanıcısı oluşturulur
        {
            FullName = "Test Staff", // Görevli kullanıcısının adı soyadı
            Email = "staff@example.com", // Görevli giriş e-postası
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Staff123*"), // Görevli şifresinin hashlenmiş hali
            Role = UserRole.Staff, // Kullanıcının rolü Staff
            IsBlocked = false // Kullanıcı blokeli değil
        };

        var student = new User // Öğrenci kullanıcısı oluşturulur
        {
            FullName = "Test Student", // Öğrenci kullanıcısının adı soyadı
            Email = "student@example.com", // Öğrenci giriş e-postası
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Student123*"), // Öğrenci şifresinin hashlenmiş hali
            Role = UserRole.Student, // Kullanıcının rolü Student
            IsBlocked = false // Kullanıcı blokeli değil
        };

        db.Users.AddRange(admin, staff, student); // Üç kullanıcıyı Users tablosuna eklenmek üzere hazırlar

        var locationArea = new LocationArea // Örnek kütüphane alanı oluşturulur
        {
            Name = "Merkez Kütüphane 1. Kat", // Konum alanının adı
            Latitude = 38.5012, // Alanın örnek enlem bilgisi
            Longitude = 43.3729, // Alanın örnek boylam bilgisi
            RadiusMeters = 100, // 100 metre içinde olan kullanıcılar bu alanda kabul edilir
            IsActive = true // Konum alanı aktif
        };

        db.LocationAreas.Add(locationArea); // Konum alanını eklenmek üzere hazırlar

        await db.SaveChangesAsync(); // Kullanıcıları ve konum alanını veritabanına kaydeder

        var table = new StudyTable // Örnek masa oluşturulur
        {
            Code = "A-101", // Masanın görünen kodu
            Status = TableStatus.Available, // Masa başlangıçta boş
            LocationAreaId = locationArea.Id, // Masa oluşturulan konum alanına bağlanır
            IsActive = true // Masa aktif
        };

        db.StudyTables.Add(table); // Masayı eklenmek üzere hazırlar

        await db.SaveChangesAsync(); // Masayı veritabanına kaydeder

        var qrCode = new QrCodeRecord // Örnek QR kod kaydı oluşturulur
        {
            Code = "QR-A101-TEST", // QR kodun içinde tutulacak örnek kod
            StudyTableId = table.Id, // QR kod oluşturulan masaya bağlanır
            IsActive = true // QR kod aktif
        };

        db.QrCodeRecords.Add(qrCode); // QR kodu eklenmek üzere hazırlar

        await db.SaveChangesAsync(); // QR kodu veritabanına kaydeder
    }
}