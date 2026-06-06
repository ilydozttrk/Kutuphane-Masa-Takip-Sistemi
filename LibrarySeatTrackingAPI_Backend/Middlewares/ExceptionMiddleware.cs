using System.Net; // HttpStatusCode kullanmak için
using System.Text.Json; // JSON serialize işlemi için
using LibrarySeatTrackingAPI.Application.DTOs; // ApiResponseDto kullanmak için

namespace LibrarySeatTrackingAPI.Middlewares; // Middlewares klasörüne ait olduğunu belirtir

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next; // Sıradaki middleware'i temsil eder

    public ExceptionMiddleware(RequestDelegate next) // RequestDelegate bağımlılığını dışarıdan alır
    {
        _next = next; // Gelen middleware zincirini sınıf içinde saklar
    }

    public async Task InvokeAsync(HttpContext context) // Her HTTP isteğinde çalışan metot
    {
        try // Hata oluşabilecek kodları çalıştırır
        {
            await _next(context); // İsteği sıradaki middleware'e gönderir
        }
        catch (Exception) // Beklenmeyen hata yakalanır
        {
            context.Response.StatusCode = (int)HttpStatusCode.InternalServerError; // HTTP 500 döner

            context.Response.ContentType = "application/json"; // Cevap tipini JSON yapar

            var response = new ApiResponseDto<string> // Standart hata cevabı oluşturur
            {
                Success = false, // İşlem başarısız
                Message = "An unexpected error occurred.", // Genel hata mesajı
                Data = null // Veri dönülmez
            };

            var json = JsonSerializer.Serialize(response); // Cevabı JSON string'e çevirir

            await context.Response.WriteAsync(json); // JSON cevabı kullanıcıya döner
        }
    }
}