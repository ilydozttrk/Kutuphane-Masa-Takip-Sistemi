using LibrarySeatTrackingAPI.Domain; // Entity sınıflarını kullanmak için ekledik
using Microsoft.EntityFrameworkCore; // DbContext ve DbSet yapıları için ekledik

namespace LibrarySeatTrackingAPI.Infrastructure.Data; // Bu dosyanın Infrastructure/Data katmanına ait olduğunu belirtir

public class ApplicationDbContext : DbContext // EF Core veritabanı sınıfımız
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
        // DbContext ayarlarını dışarıdan almak için constructor
    }

    public DbSet<User> Users { get; set; } // Users tablosunu temsil eder

    public DbSet<RefreshToken> RefreshTokens { get; set; } // RefreshTokens tablosunu temsil eder

    public DbSet<LocationArea> LocationAreas { get; set; } // LocationAreas tablosunu temsil eder

    public DbSet<StudyTable> StudyTables { get; set; } // StudyTables tablosunu temsil eder

    public DbSet<QrCodeRecord> QrCodeRecords { get; set; } // QrCodeRecords tablosunu temsil eder

    public DbSet<Reservation> Reservations { get; set; } // Reservations tablosunu temsil eder

    public DbSet<QueueEntry> QueueEntries { get; set; } // QueueEntries tablosunu temsil eder

    public DbSet<BlockRecord> BlockRecords { get; set; } // BlockRecords tablosunu temsil eder

    public DbSet<IssueReport> IssueReports { get; set; } // IssueReports tablosunu temsil eder
    public DbSet<NotificationLog> NotificationLogs { get; set; } // NotificationLogs tablosunu temsil eder
    public DbSet<UserDeviceToken> UserDeviceTokens { get; set; } // UserDeviceTokens tablosunu temsil eder
}