# Library Seat Tracking API

Üniversite kütüphaneleri ve çalışma salonlarında masa kullanımını daha adil yönetmek için geliştirilmiş bir ASP.NET Core Web API projesidir. Sistem; QR kod, konum doğrulama, JWT kimlik doğrulama, rol bazlı yetkilendirme, rezervasyon takibi ve bildirim altyapısı ile masa işgalini azaltmayı hedefler.

## İçindekiler

- [Projenin Amacı](#projenin-amacı)
- [Kullanılan Teknolojiler](#kullanılan-teknolojiler)
- [Roller](#roller)
- [Proje Yapısı](#proje-yapısı)
- [Temel Modüller](#temel-modüller)
- [API Endpointleri](#api-endpointleri)
- [Kurulum](#kurulum)
- [Örnek İstekler](#örnek-istekler)
- [Firebase Ayarı](#firebase-ayarı)
- [Güvenlik Notları](#güvenlik-notları)
- [Mevcut Durum](#mevcut-durum)
- [Geliştirilebilecek Alanlar](#geliştirilebilecek-alanlar)

## Projenin Amacı

Kütüphanelerde sık görülen problemlerden biri, kullanıcıların masayı uzun süre boş bırakmasına rağmen masa üzerindeki eşyalarla kullanım hakkını sürdürmesidir.

Bu sistem ile:

- Öğrenci yalnızca QR kod ve konum doğrulaması ile masa alabilir.
- Masa kullanım süresi sistem tarafından takip edilir.
- Oturum süresi dolmak üzereyken kullanıcıya bildirim gönderilir.
- Kullanıcı QR kodu tekrar okutarak oturumunu yenileyebilir.
- Oturum yenilenmezse sistem masayı otomatik olarak boşa çıkarır.
- Admin ve kütüphane görevlisi masa, QR kod, rezervasyon, sıra ve bildirim kayıtlarını yönetebilir.

## Kullanılan Teknolojiler

| Teknoloji | Açıklama |
| --- | --- |
| ASP.NET Core Web API (.NET 9) | Backend API geliştirme |
| Entity Framework Core | ORM ve veritabanı işlemleri |
| SQL Server | Veritabanı |
| JWT Authentication | Kimlik doğrulama |
| Role Based Authorization | Rol bazlı yetkilendirme |
| BCrypt.Net | Şifre hashleme |
| FluentValidation | DTO doğrulama kuralları |
| Swagger / OpenAPI | API test ve dokümantasyon |
| Firebase Admin SDK | Mobil push notification altyapısı |
| Firebase Cloud Messaging | Mobil cihaza bildirim gönderme |
| BackgroundService | Oturum süresi takibi ve otomatik işlemler |
| QRCoder | QR kod görseli üretme |

## Roller

| Rol | Yetkiler |
| --- | --- |
| Student | Giriş yapar, masaları görür, QR + konum ile masa alır, oturumunu yeniler veya sonlandırır, sıraya girer, sorun bildirir, bildirimlerini görüntüler. |
| Staff | Masa durumlarını görür, QR kodları yönetir, rezervasyonları açıklama ile sonlandırır, sorun bildirimlerini yönetir, sıra kayıtlarını görüntüler. |
| Admin | Kullanıcı bloke, masa, konum, QR, rezervasyon, sıra ve bildirim yönetimi dahil tüm yönetim işlemlerini yapar. |

## Proje Yapısı

```text
LibrarySeatTrackingAPI
├── Application
│   ├── DTOs
│   ├── Interfaces
│   └── Services
├── Common
│   └── Enums
├── Controllers
├── Domain
├── Infrastructure
│   ├── Data
│   ├── Firebase
│   ├── Seed
│   └── Services
├── Middlewares
├── Program.cs
└── appsettings.json
```

| Klasör | Açıklama |
| --- | --- |
| Domain | Veritabanı tablolarına karşılık gelen entity sınıfları |
| Common/Enums | Rol, masa durumu, rezervasyon durumu gibi enum yapıları |
| Application/DTOs | API'ye gelen ve API'den dönen veri modelleri |
| Application/Interfaces | Servis sözleşmeleri |
| Application/Services | İş mantığının bulunduğu servis sınıfları |
| Infrastructure/Data | Entity Framework `DbContext` yapısı |
| Infrastructure/Seed | Başlangıç test verileri |
| Infrastructure/Services | Background service gibi altyapı servisleri |
| Controllers | API endpointleri |
| Middlewares | Global hata yakalama middleware yapısı |

## Temel Modüller

### Authentication

Kullanıcı girişi JWT tabanlıdır. Başarılı login sonrasında access token ve refresh token üretilir. Refresh token ile yeni access token alınabilir, logout işleminde refresh token iptal edilir. Blokeli kullanıcı sisteme giriş yapamaz.

### Masa ve Konum Yönetimi

Admin çalışma masası ve konum alanı oluşturabilir. Her masa bir konum alanına bağlıdır ve `Available`, `Occupied`, `Reserved` veya `Maintenance` durumlarından birine sahip olabilir.

Konum alanı şu bilgileri içerir:

```json
{
  "name": "Merkez Kütüphane 1. Kat",
  "latitude": 38.5015,
  "longitude": 43.3732,
  "radiusMeters": 100
}
```

Öğrenci masa alırken gönderdiği konum bilgisinin ilgili alanın izin verilen yarıçapı içinde olup olmadığı kontrol edilir.

### QR Kod Yönetimi

Admin veya Staff, masalara QR kod tanımlayabilir. QR kodlar aktif/pasif yapılabilir. Pasif QR kod ile rezervasyon oluşturulamaz.

```json
{
  "code": "QR-A101-TEST",
  "studyTableId": 1
}
```

QR kod kayıtları için PNG görüntüleme, indirme ve yazdırma endpointleri de bulunur.

### Rezervasyon Akışı

Öğrenci masa almak için:

1. Login olur ve JWT access token alır.
2. Masadaki QR kodu okutur.
3. Anlık konum bilgisini gönderir.
4. Sistem QR kodu, masa durumunu, aktif rezervasyon durumunu ve konumu doğrular.
5. Masa uygunsa rezervasyon oluşturulur ve masa `Occupied` yapılır.

Oturum süresi dolmak üzereyken kullanıcı aynı QR kodu yeniden okutarak oturumunu yenileyebilir.

### Otomatik Bildirim ve Oturum Sonlandırma

`ReservationBackgroundService`, aktif rezervasyonları arka planda kontrol eder.

| Zaman | İşlem |
| --- | --- |
| 55. dakika | Kullanıcıya oturumun dolmak üzere olduğu bildirilir |
| 65. dakika | Bildirim tekrar gönderilir |
| 70. dakika | Yenileme yapılmadıysa rezervasyon tamamlanır ve masa boşa çıkarılır |

### Sıra Sistemi

Masa doluysa öğrenci sıraya girebilir. Kullanıcının aktif rezervasyonu varsa veya aynı masa için zaten sıradaysa yeni sıra kaydı oluşturulmaz.

### Sorun Bildirimi

Kullanıcılar masalarla ilgili sorun bildirebilir. Admin veya Staff bu bildirimleri görüntüleyip durumlarını güncelleyebilir.

Örnek sorunlar:

- QR kod okunmuyor.
- Masa prizi çalışmıyor.
- Sandalye kırık.
- Masa kirli.

### Kullanıcı Bloke Sistemi

Admin sistemi kötüye kullanan kullanıcıları bloke edebilir. Blokeli kullanıcı login olamaz ve sistemi kullanamaz.

### Bildirim Sistemi

Bildirimler `NotificationLog` tablosunda saklanır. Kullanıcı kendi bildirimlerini listeleyebilir ve okundu olarak işaretleyebilir. Firebase ayarı yapıldığında mobil push notification gönderimi de desteklenir.

## Temel Entity Yapıları

| Entity | Açıklama |
| --- | --- |
| User | Sistemdeki kullanıcıları temsil eder |
| RefreshToken | Oturum yenileme tokenlarını tutar |
| LocationArea | Kütüphane veya çalışma alanı konumlarını tutar |
| StudyTable | Çalışma masalarını temsil eder |
| QrCodeRecord | Masalara bağlı QR kodları tutar |
| Reservation | Masa kullanım oturumlarını tutar |
| QueueEntry | Masa sırası kayıtlarını tutar |
| BlockRecord | Bloke edilen kullanıcı kayıtlarını tutar |
| IssueReport | Masa sorun bildirimlerini tutar |
| NotificationLog | Kullanıcıya gönderilen bildirim kayıtlarını tutar |
| UserDeviceToken | Mobil cihaz FCM tokenlarını tutar |

## Enum Yapıları

| Enum | Değerler |
| --- | --- |
| UserRole | Student, Staff, Admin |
| TableStatus | Available, Occupied, Reserved, Maintenance |
| ReservationStatus | Active, Completed, Cancelled, Expired |
| QueueStatus | Waiting, Notified, Completed, Cancelled |
| IssueStatus | Open, InProgress, Resolved, Rejected |

## API Endpointleri

### Auth

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/auth/login` | Kullanıcı girişi |
| POST | `/api/auth/refresh-token` | Refresh token ile yeni token alma |
| POST | `/api/auth/logout` | Refresh token iptal etme |

### Device Tokens

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/device-tokens/register` | Mobil FCM token kaydetme |

### Location Areas

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/location-areas` | Konum alanı oluşturma |
| GET | `/api/location-areas` | Konum alanlarını listeleme |

### Study Tables

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/study-tables` | Masa oluşturma |
| GET | `/api/study-tables` | Masaları listeleme |
| PUT | `/api/study-tables/{studyTableId}/status` | Masa durumunu güncelleme |

### QR Code Records

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/qr-code-records` | QR kod oluşturma |
| GET | `/api/qr-code-records` | QR kodları listeleme |
| PUT | `/api/qr-code-records/{qrCodeRecordId}/status` | QR kod aktif/pasif güncelleme |
| GET | `/api/qr-code-records/{qrCodeRecordId}/image` | QR kod PNG görüntüsü alma |
| GET | `/api/qr-code-records/{qrCodeRecordId}/download` | QR kod PNG dosyasını indirme |
| GET | `/api/qr-code-records/{qrCodeRecordId}/print` | Yazdırılabilir QR kod sayfası alma |

### Reservations

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/reservations` | QR + konum ile masa alma |
| POST | `/api/reservations/renew` | QR + konum ile oturum yenileme |
| GET | `/api/reservations/my` | Kullanıcının kendi rezervasyonları |
| PUT | `/api/reservations/{reservationId}/complete` | Öğrencinin oturumu sonlandırması |
| PUT | `/api/reservations/{reservationId}/force-complete` | Staff/Admin tarafından oturum sonlandırma |

### Queue Entries

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/queue-entries` | Masa için sıraya girme |
| GET | `/api/queue-entries/my` | Kullanıcının kendi sıra kayıtları |
| GET | `/api/queue-entries` | Tüm sıra kayıtları |
| PUT | `/api/queue-entries/{queueEntryId}/status` | Sıra durumunu güncelleme |

### Issue Reports

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/issue-reports` | Sorun bildirimi oluşturma |
| GET | `/api/issue-reports/my` | Kullanıcının kendi sorun bildirimleri |
| GET | `/api/issue-reports` | Tüm sorun bildirimleri |
| PUT | `/api/issue-reports/{issueReportId}/status` | Sorun durumunu güncelleme |

### Block Records

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| POST | `/api/block-records` | Kullanıcı bloke etme |
| GET | `/api/block-records` | Bloke kayıtlarını listeleme |
| PUT | `/api/block-records/{blockRecordId}/remove` | Blokeyi kaldırma |

### Notifications

| Method | Endpoint | Açıklama |
| --- | --- | --- |
| GET | `/api/notifications/my` | Kullanıcının bildirimlerini listeleme |
| PUT | `/api/notifications/{notificationId}/read` | Bildirimi okundu yapma |

## Kurulum

### 1. Projeyi klonla

```bash
git clone https://github.com/kullanici-adi/LibrarySeatTrackingAPI.git
cd LibrarySeatTrackingAPI
```

### 2. Paketleri yükle

```bash
dotnet restore
```

### 3. Veritabanı bağlantısını ayarla

`appsettings.json` içindeki connection string değerini kendi SQL Server ortamına göre düzenle.

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=LibrarySeatTrackingDb_Rebuild;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

### 4. Migration uygula

```bash
dotnet ef database update
```

> Uygulama başlarken `Program.cs` içinde `MigrateAsync()` çalıştığı için bekleyen migrationlar otomatik uygulanır.

### 5. Uygulamayı çalıştır

```bash
dotnet run
```

Swagger arayüzü development ortamında şu adreste açılır:

```text
http://localhost:5024
```

## Seed Kullanıcıları

İlk çalıştırmada test kullanıcıları, örnek konum alanı, örnek masa ve QR kod oluşturulur.

| Rol | Email | Şifre |
| --- | --- | --- |
| Admin | `admin@example.com` | `Admin123*` |
| Staff | `staff@example.com` | `Staff123*` |
| Student | `student@example.com` | `Student123*` |

Örnek seed verileri:

| Veri | Değer |
| --- | --- |
| Konum | Merkez Kütüphane 1. Kat |
| Masa | A-101 |
| QR kod | QR-A101-TEST |

## Örnek İstekler

### Login

```json
{
  "email": "student@example.com",
  "password": "Student123*"
}
```

Örnek cevap:

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "userId": 3,
    "fullName": "Test Student",
    "email": "student@example.com",
    "role": "Student",
    "accessToken": "...",
    "refreshToken": "..."
  }
}
```

### Rezervasyon Oluşturma

```json
{
  "qrCode": "QR-A101-TEST",
  "userLatitude": 38.5012,
  "userLongitude": 43.3729,
  "durationMinutes": 60
}
```

### Oturum Yenileme

```json
{
  "qrCode": "QR-A101-TEST",
  "userLatitude": 38.5012,
  "userLongitude": 43.3729,
  "extraMinutes": 60
}
```

### Mobil Cihaz Token Kaydı

```http
POST /api/device-tokens/register
Authorization: Bearer <access-token>
Content-Type: application/json
```

```json
{
  "token": "firebase-fcm-device-token",
  "deviceName": "Samsung A52"
}
```

## Firebase Ayarı

Gerçek push notification göndermek için Firebase service account dosyası gerekir.

Beklenen dosya yolu:

```text
Infrastructure/Firebase/firebase-service-account.json
```

`appsettings.json` içine şu ayar eklenebilir:

```json
{
  "Firebase": {
    "ServiceAccountPath": "Infrastructure/Firebase/firebase-service-account.json"
  }
}
```

Bu dosya gizli anahtar içerdiği için repoya yüklenmemelidir. `.gitignore` içine şu satır eklenmelidir:

```gitignore
Infrastructure/Firebase/firebase-service-account.json
```

## Güvenlik Notları

- Şifreler düz metin olarak tutulmaz, BCrypt ile hashlenir.
- JWT token ile kimlik doğrulama yapılır.
- Refresh tokenlar veritabanında saklanır.
- Logout işleminde refresh token iptal edilir.
- Kullanıcı blokeliyse login olamaz.
- Endpointler rol bazlı yetkilendirme ile korunur.
- Firebase service account dosyası GitHub'a yüklenmemelidir.

## Validation

Projede FluentValidation kullanılır. Kontrol edilen bazı alanlar:

- Email formatı
- Boş şifre kontrolü
- QR kodun boş olmaması
- Konum değerlerinin geçerli aralıkta olması
- Rezervasyon süresinin belirlenen aralıkta olması
- Masa kodunun boş olmaması
- Sorun açıklamasının minimum karakter sınırına uyması
- Bloke nedeninin boş olmaması
- Cihaz tokenının boş olmaması

## Global Exception Handling

Beklenmeyen hatalar `ExceptionMiddleware` ile yakalanır ve standart formatta cevap döner.

```json
{
  "success": false,
  "message": "An unexpected error occurred.",
  "data": null
}
```

## Mevcut Durum

Tamamlanan ana modüller:

- Auth, JWT Authentication, Refresh Token ve Logout
- Role Based Authorization
- LocationArea, StudyTable ve QrCodeRecord yönetimi
- QR kod PNG üretme, indirme ve yazdırma
- Reservation oluşturma, yenileme ve sonlandırma
- Background reservation tracking
- Firebase push notification altyapısı
- NotificationLog ve UserDeviceToken
- QueueEntry, IssueReport ve BlockRecord
- FluentValidation
- Global exception middleware

## Geliştirilebilecek Alanlar

- Unit test ve integration test eklenebilir.
- Admin panel geliştirilebilir.
- Flutter mobil uygulama tamamlanabilir.
- Gerçek Firebase tokenlarıyla cihaz bildirimi test edilebilir.
- Bildirim başarısızlıkları ayrı log tablosunda tutulabilir.
- Çoklu kütüphane ve çoklu kampüs desteği geliştirilebilir.
- Kullanıcı kayıt sistemi eklenebilir.
- Raporlama ekranları eklenebilir.
- Masa doluluk istatistikleri çıkarılabilir.
