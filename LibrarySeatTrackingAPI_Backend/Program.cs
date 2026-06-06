using LibrarySeatTrackingAPI.Infrastructure.Data; // ApplicationDbContext sınıfını kullanmak için
using Microsoft.EntityFrameworkCore; // UseSqlServer metodu için
using LibrarySeatTrackingAPI.Infrastructure.Seed; // DataSeeder sınıfını kullanmak için
using LibrarySeatTrackingAPI.Application.Interfaces; // IAuthService interface'ini kullanmak için
using LibrarySeatTrackingAPI.Application.Services; // AuthService sınıfını kullanmak için
using Microsoft.AspNetCore.Authentication.JwtBearer; // JWT Bearer authentication kullanmak için
using Microsoft.IdentityModel.Tokens; // Token doğrulama ayarları için
using System.Text; // JWT secret key'i byte dizisine çevirmek için
using Microsoft.OpenApi.Models; // Swagger JWT güvenlik ayarı için
using FluentValidation; // Validator sınıflarını sisteme kaydetmek için
using FluentValidation.AspNetCore;
using LibrarySeatTrackingAPI.Application.DTOs; // FluentValidation ASP.NET Core entegrasyonu için
using LibrarySeatTrackingAPI.Middlewares; // ExceptionMiddleware sınıfını kullanmak için
using LibrarySeatTrackingAPI.Infrastructure.Services; // ReservationBackgroundService sınıfını kullanmak için
using FirebaseAdmin; // FirebaseApp başlatmak için
using Google.Apis.Auth.OAuth2; // GoogleCredential kullanmak için

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddOpenApi();
builder.Services.AddSwaggerGen(options => // Swagger ayarlarını özelleştirir
{
    options.SwaggerDoc("v1", new OpenApiInfo // Swagger doküman bilgisi
    {
        Title = "Library Seat Tracking API", // Swagger başlığı
        Version = "v1" // API versiyon bilgisi
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme // Swagger'a JWT Bearer token tanımı ekler
    {
        Name = "Authorization", // Header adı
        Type = SecuritySchemeType.Http, // HTTP authentication tipi
        Scheme = "bearer", // Bearer şeması
        BearerFormat = "JWT", // Token formatı JWT
        In = ParameterLocation.Header, // Token header içinde gönderilecek
        Description = "JWT token giriniz. Örnek: sadece token değerini yapıştırın." // Swagger açıklaması
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement // Endpointlerde JWT kullanılabileceğini belirtir
    {
        {
            new OpenApiSecurityScheme // Kullanılacak güvenlik şeması
            {
                Reference = new OpenApiReference // Yukarıdaki Bearer tanımına referans verir
                {
                    Type = ReferenceType.SecurityScheme, // Referans tipi security scheme
                    Id = "Bearer" // Kullanılacak güvenlik tanımı adı
                }
            },
            Array.Empty<string>() // Ek scope gerekmediğini belirtir
        }
    });
});
builder.Services.AddControllers(); // Controller sınıflarını API endpoint olarak kullanmamızı sağlar
builder.Services.AddHostedService<ReservationBackgroundService>(); // Rezervasyon sürelerini arka planda kontrol eder
builder.Services.AddValidatorsFromAssemblyContaining<LoginRequestDtoValidator>(); // Validator sınıflarını bulup DI sistemine kaydeder

builder.Services.AddFluentValidationAutoValidation(); // Controller'a gelen DTO'ları otomatik validate eder
builder.Services.AddDbContext<ApplicationDbContext>(options => // ApplicationDbContext'i sisteme servis olarak ekler
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")); // appsettings.json içindeki DefaultConnection ile SQL Server'a bağlanır
});


builder.Services.AddScoped<IAuthService, AuthService>(); // IAuthService istenince AuthService nesnesi üretir
builder.Services.AddScoped<ILocationAreaService, LocationAreaService>(); // ILocationAreaService istenince LocationAreaService nesnesi üretir
builder.Services.AddScoped<IStudyTableService, StudyTableService>(); // IStudyTableService istenince StudyTableService nesnesi üretir
builder.Services.AddScoped<IQrCodeRecordService, QrCodeRecordService>(); // IQrCodeRecordService istenince QrCodeRecordService nesnesi üretir
builder.Services.AddScoped<IReservationService, ReservationService>(); // IReservationService istenince ReservationService nesnesi üretir
builder.Services.AddScoped<IQueueEntryService, QueueEntryService>(); // IQueueEntryService istenince QueueEntryService nesnesi üretir
builder.Services.AddScoped<IIssueReportService, IssueReportService>(); // IIssueReportService istenince IssueReportService nesnesi üretir
builder.Services.AddScoped<IBlockRecordService, BlockRecordService>(); // IBlockRecordService istenince BlockRecordService nesnesi üretir
builder.Services.AddScoped<INotificationService, NotificationService>(); // INotificationService istenince NotificationService nesnesi üretir
builder.Services.AddScoped<IUserDeviceTokenService, UserDeviceTokenService>(); // IUserDeviceTokenService istenince UserDeviceTokenService nesnesi üretir
builder.Services.AddScoped<IPushNotificationService, PushNotificationService>(); // IPushNotificationService istenince PushNotificationService nesnesi üretir
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme) // Varsayılan kimlik doğrulama yöntemi JWT Bearer olsun
    .AddJwtBearer(options => // JWT token doğrulama ayarlarını belirler
    {
        options.TokenValidationParameters = new TokenValidationParameters // Token kontrol kuralları
        {
            ValidateIssuer = true, // Tokenı üreten sistem kontrol edilsin

            ValidateAudience = true, // Tokenın hedef kitlesi kontrol edilsin

            ValidateLifetime = true, // Tokenın süresi dolmuş mu kontrol edilsin

            ValidateIssuerSigningKey = true, // Token imza anahtarı doğru mu kontrol edilsin

            ValidIssuer = builder.Configuration["Jwt:Issuer"], // appsettings.json içindeki Issuer değeri

            ValidAudience = builder.Configuration["Jwt:Audience"], // appsettings.json içindeki Audience değeri

            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!) // appsettings.json içindeki gizli key
            )
        };
    });

builder.Services.AddAuthorization(); // Yetkilendirme sistemini aktif eder

var firebaseServiceAccountPath = builder.Configuration["Firebase:ServiceAccountPath"]; // appsettings içindeki Firebase servis hesabı yolunu okur

if (!string.IsNullOrWhiteSpace(firebaseServiceAccountPath) && FirebaseApp.DefaultInstance is null) // Firebase yolu varsa ve Firebase henüz başlatılmadıysa
{
    FirebaseApp.Create(new AppOptions // Firebase uygulamasını başlatır
    {
        Credential = GoogleCredential.FromFile(firebaseServiceAccountPath) // Service account JSON dosyasını kullanır
    });
}


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();

    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Library Seat Tracking API v1");
        options.RoutePrefix = string.Empty;
    });
}
app.UseMiddleware<ExceptionMiddleware>(); // Beklenmeyen hataları yakalayıp standart JSON cevap döner
app.UseHttpsRedirection();
app.UseAuthentication(); // Gelen istekte JWT token var mı ve geçerli mi kontrol eder

app.UseAuthorization(); // Kullanıcının ilgili endpoint için yetkisi var mı kontrol eder

using (var scope = app.Services.CreateScope()) // Uygulama servislerinden geçici bir kullanım alanı oluşturur
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>(); // ApplicationDbContext nesnesini alır

    await db.Database.MigrateAsync(); // Bekleyen migration varsa veritabanına uygular

    await DataSeeder.SeedAsync(db); // Test kullanıcılarını, örnek alanı, masayı ve QR kodu ekler
}
app.MapControllers(); // Controller içindeki endpointleri uygulamaya bağlar
app.Run();