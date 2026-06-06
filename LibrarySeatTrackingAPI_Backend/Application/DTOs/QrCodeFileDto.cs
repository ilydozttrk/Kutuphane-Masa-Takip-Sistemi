namespace LibrarySeatTrackingAPI.Application.DTOs;

public class QrCodeFileDto
{
    public byte[] FileBytes { get; set; } = Array.Empty<byte>();

    public string FileName { get; set; } = string.Empty;

    public string ContentType { get; set; } = "image/png";

    public string Code { get; set; } = string.Empty;

    public string StudyTableCode { get; set; } = string.Empty;
}