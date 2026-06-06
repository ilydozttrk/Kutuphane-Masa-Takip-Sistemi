namespace LibrarySeatTrackingAPI.Application.DTOs; // Bu dosyanın Application/DTOs katmanına ait olduğunu belirtir

public class ApiResponseDto<T> // T, dönecek verinin tipini temsil eder
{
    public bool Success { get; set; } // İşlemin başarılı olup olmadığını belirtir

    public string Message { get; set; } = string.Empty; // İşlemle ilgili kullanıcıya dönecek mesaj

    public T? Data { get; set; } // İşlem başarılıysa dönecek asıl veri
}