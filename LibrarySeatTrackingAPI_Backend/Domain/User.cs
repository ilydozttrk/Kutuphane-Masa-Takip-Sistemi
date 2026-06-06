using LibrarySeatTrackingAPI.Common.Enums; // UserRole enumunu kullanmak için ekledik

namespace LibrarySeatTrackingAPI.Domain; // Bu dosyanın Domain klasörüne ait olduğunu belirtir

public class User
{
    public int Id { get; set; } // Kullanıcının benzersiz kimlik numarası

    public string FullName { get; set; } = string.Empty; // Kullanıcının adı ve soyadı

    public string Email { get; set; } = string.Empty; // Kullanıcının sisteme giriş yapacağı e-posta adresi

    public string PasswordHash { get; set; } = string.Empty; // Kullanıcının şifresinin hashlenmiş hali

    public UserRole Role { get; set; } = UserRole.Student; // Kullanıcının rolü: Student, Staff veya Admin

    public bool IsBlocked { get; set; } = false; // Kullanıcının sisteme erişiminin engellenip engellenmediği

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Kullanıcının oluşturulma tarihi
}