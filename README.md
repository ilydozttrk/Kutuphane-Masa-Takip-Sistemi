<<<<<<< HEAD
# Kütüphane Masa Takip Sistemi

## Proje Hakkında

Kütüphane Masa Takip Sistemi, kütüphane ve okuma salonlarında çalışma masalarının kullanım durumunu dijital olarak takip etmek amacıyla geliştirilmiş bir yazılım projesidir. Projede öğrencilerin QR kod ile masa rezervasyonu oluşturması, aktif rezervasyonlarını görüntülemesi, rezervasyon süresini yenilemesi, dolu masalar için sıraya girmesi ve masa ile ilgili sorun bildirebilmesi hedeflenmiştir.

Sistem; backend tarafında ASP.NET Core Web API, frontend tarafında ise Flutter mobil uygulaması kullanılarak geliştirilmiştir. Backend API, kullanıcı doğrulama, rol bazlı yetkilendirme, masa yönetimi, QR kod kayıtları, rezervasyon işlemleri, sıra sistemi, sorun bildirimleri ve bildirim kayıtları gibi temel işlemleri yönetmektedir. Flutter uygulaması ise öğrencilerin, staff rolündeki kullanıcıların ve admin kullanıcılarının sisteme arayüz üzerinden erişmesini sağlamaktadır.

---

## Hazırlayanlar

- Ertuğrul EVLİYAOĞLU
- Mehmet CANSEVER
- Semanur YILDIRIM
- İlayda ÖZTÜRK

---

## Projenin Amacı

Bu projenin temel amacı, kütüphane çalışma alanlarında yaşanan masa kullanım problemlerini azaltmak ve masa yönetimini daha düzenli hale getirmektir. Geleneksel kullanımda öğrenciler masaya kitap, çanta veya kişisel eşya bırakarak uzun süre masayı işgal edebilmekte, bu durum diğer öğrencilerin masa bulmasını zorlaştırmaktadır. Geliştirilen sistem sayesinde masa kullanımı QR kod ve süre kontrollü rezervasyon mantığıyla dijital olarak yönetilmektedir.

Sistem ile hedeflenen başlıca kazanımlar şunlardır:

- Masaların anlık durumlarının takip edilmesi
- QR kod ile kontrollü rezervasyon oluşturulması
- Öğrencilerin aktif masa kullanım sürelerini görüntüleyebilmesi
- Dolu veya rezerve masalar için sıraya girme işleminin yapılabilmesi
- Masa arızası veya kullanım problemi gibi durumların bildirilebilmesi
- Admin ve staff rolleri ile yönetim süreçlerinin desteklenmesi
- Bildirim sistemi ile kullanıcıların bilgilendirilmesi

---

## Kullanılan Teknolojiler

### Backend

- ASP.NET Core Web API
- .NET 9
- Entity Framework Core
- SQL Server
- JWT Authentication
- Role Based Authorization
- FluentValidation
- Swagger / OpenAPI
- Firebase Admin SDK
- QRCoder
- Background Service

### Frontend

- Flutter
- Dart
- REST API entegrasyonu
- Firebase Cloud Messaging
- SharedPreferences
- Geolocator
- Mobile Scanner
- HTTP package

---

## Genel Sistem Yapısı

Proje iki ana bölümden oluşmaktadır:

```text
Kutuphane-Masa-Takip-Sistemi/
│
├── LibrarySeatTrackingAPI_Backend/
│   └── ASP.NET Core Web API backend projesi
│
├── library_seat_tracking_app_Frontend(Flutter)/
│   └── Flutter mobil uygulama projesi
│
├── Grup1_Rapor_Guncel.pdf
├── Grup1_Sunum_Guncel.pptx
├── Grup1_Poster1.pdf
└── Grup1_Poster2.pdf
```

Backend tarafı sistemin iş kurallarını, veritabanı işlemlerini ve API servislerini yönetir. Frontend tarafı ise kullanıcıların sisteme mobil arayüz üzerinden erişmesini sağlar.

---

## Backend Özellikleri

Backend projesi, kütüphane masa takip sisteminin temel iş mantığını yöneten ASP.NET Core Web API uygulamasıdır.

Başlıca backend özellikleri:

- Kullanıcı girişi ve JWT token üretimi
- Refresh token desteği
- Logout işlemi
- Rol bazlı yetkilendirme
- Admin, Staff ve Student kullanıcı rolleri
- Lokasyon alanı yönetimi
- Çalışma masası yönetimi
- QR kod kayıt yönetimi
- QR kod görseli oluşturma, indirme ve yazdırma
- Öğrenci rezervasyon oluşturma işlemi
- Aktif rezervasyon görüntüleme
- Rezervasyon tamamlama
- Rezervasyon yenileme
- Admin/Staff tarafından rezervasyon sonlandırma
- Dolu masalar için sıraya girme sistemi
- Sorun bildirme sistemi
- Kullanıcı bildirimleri
- Cihaz token kayıt sistemi
- Firebase bildirim altyapısı
- Süresi dolan rezervasyonları kontrol eden background service
- Global exception middleware ile standart hata formatı
- FluentValidation ile DTO doğrulama

---

## Frontend Özellikleri

Flutter frontend projesi, backend API ile haberleşerek kullanıcıların sistemi mobil arayüz üzerinden kullanmasını sağlar.

Başlıca frontend özellikleri:

- Kullanıcı giriş ekranı
- Rol bazlı ekran yönlendirme
- Öğrenci ana ekranı
- Admin panel ekranları
- Staff kullanıcı ekranı
- QR kod okutma ekranı
- Masa durumlarını listeleme
- Boş, dolu, rezerve ve bakımda olan masa durumlarını gösterme
- Aktif rezervasyon kartı
- Rezervasyon oluşturma
- Rezervasyon yenileme
- Rezervasyon bitirme
- Dolu veya rezerve masalar için sıraya girme
- Masa üzerinden sorun bildirimi oluşturma
- Bildirim paneli
- Okunmamış bildirim sayısı gösterimi
- Firebase Cloud Messaging ile bildirim altyapısı
- Kullanıcı oturum bilgilerinin SharedPreferences ile saklanması
- Çıkış yapma işlemi

---

## Kullanıcı Rolleri

Sistemde üç temel kullanıcı rolü bulunmaktadır.

### Student

Student rolündeki kullanıcılar sistemin öğrenci tarafını kullanır. Öğrenciler QR kod ile rezervasyon oluşturabilir, aktif rezervasyonunu görüntüleyebilir, rezervasyonunu tamamlayabilir, uygun durumlarda rezervasyon süresini yenileyebilir, dolu masalar için sıraya girebilir ve sorun bildirimi oluşturabilir.

### Staff

Staff rolü, sistemde yönetim süreçlerine destek olan sınırlı yetkiye sahip kullanıcı rolüdür. Staff kullanıcıları sorun bildirimlerini, sıra kayıtlarını, QR kod kayıtlarını ve bazı rezervasyon işlemlerini yönetebilir. Hassas işlemlerde yetki sınırlandırması uygulanarak rol bazlı güvenlik sağlanmıştır.

### Admin

Admin rolü sistemde en geniş yetkiye sahip kullanıcıdır. Masa, lokasyon, QR kod, blok kayıtları, sorun bildirimleri, sıra kayıtları ve yönetimsel işlemler admin rolü üzerinden kontrol edilebilir.

---

## Temel API Başlıkları

Backend tarafında yer alan temel API başlıkları şunlardır:

```text
/api/auth
/api/location-areas
/api/study-tables
/api/qr-code-records
/api/reservations
/api/queue-entries
/api/issue-reports
/api/block-records
/api/notifications
/api/device-tokens
/api/test
```

Öne çıkan bazı endpointler:

```http
POST /api/auth/login
POST /api/auth/refresh-token
POST /api/auth/logout

GET  /api/study-tables
POST /api/reservations
GET  /api/reservations/my
PUT  /api/reservations/{reservationId}/complete
PUT  /api/reservations/{reservationId}/force-complete
POST /api/reservations/renew

POST /api/queue-entries
GET  /api/queue-entries/my

POST /api/issue-reports
GET  /api/issue-reports/my

GET  /api/notifications/my
PUT  /api/notifications/{notificationId}/read

POST /api/device-tokens/register
```

---

## Kurulum ve Çalıştırma

### Backend Kurulumu

Öncelikle backend projesi açılır ve gerekli paketler yüklenir.

```bash
cd LibrarySeatTrackingAPI_Backend/LibrarySeatTrackingAPI
dotnet restore
dotnet run
```

Backend çalıştırıldığında Swagger arayüzü geliştirme ortamında açılabilir.

```text
http://localhost:5024
```

> Not: Port numarası local ayarlara göre değişebilir. Gerekirse `Properties/launchSettings.json` dosyası kontrol edilmelidir.

### Veritabanı Ayarı

Backend projesi SQL Server kullanmaktadır. Bağlantı bilgisi `appsettings.json` veya `appsettings.Development.json` dosyasında bulunan `DefaultConnection` alanından düzenlenebilir.

Örnek bağlantı yapısı:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=LibrarySeatTrackingDb;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

Uygulama başlatılırken Entity Framework Core migration işlemleri çalıştırılır ve başlangıç verileri seed edilir.

---

## Flutter Uygulamasını Çalıştırma

Flutter projesi için önce gerekli paketler yüklenir.

```bash
cd library_seat_tracking_app_Frontend(Flutter)/library_seat_tracking_app
flutter pub get
flutter run
```

Flutter uygulaması backend API ile haberleşir. Android emulator için backend adresi genellikle şu şekilde kullanılır:

```text
http://10.0.2.2:5024/api
```

Web veya masaüstü çalıştırmalarda aşağıdaki adres kullanılabilir:

```text
http://localhost:5024/api
```

Backend bağlantı adresi gerektiğinde Flutter tarafındaki API client dosyasından düzenlenmelidir.

---

## Firebase Bildirim Sistemi

Projede Firebase Cloud Messaging ile bildirim altyapısı kullanılmıştır. Flutter tarafında kullanıcıdan bildirim izni alınır, cihaz tokenı üretilir ve backend tarafına gönderilir. Backend tarafında Firebase Admin SDK kullanılarak bildirim gönderme altyapısı desteklenir.

Kullanılan temel işlem:

```http
POST /api/device-tokens/register
```

> Not: Firebase servis hesabı, API anahtarları ve gizli bilgiler gerçek ortamda herkese açık şekilde paylaşılmamalıdır. Güvenlik için bu dosyalar `.gitignore` ile korunmalı veya ortam değişkenleri üzerinden yönetilmelidir.

---

## Masa Durumları

Sistemde çalışma masaları farklı durumlara sahip olabilir.

| Durum | Açıklama |
|---|---|
| Boş | Masa kullanıma uygundur. |
| Dolu | Masa aktif olarak kullanılmaktadır. |
| Rezerve | Masa için aktif rezervasyon bulunmaktadır. |
| Bakımda | Masa geçici olarak kullanıma kapalıdır. |

Flutter arayüzünde masa durumları kullanıcıların kolay anlayabileceği şekilde renklendirilerek gösterilir.

---

## Rezervasyon Akışı

1. Öğrenci sisteme giriş yapar.
2. QR kod okutma ekranını açar.
3. Masaya ait QR kodu okutur.
4. Uygulama QR kod ve konum bilgisini backend tarafına gönderir.
5. Backend QR kodu, masa durumunu, kullanıcı rolünü, aktif rezervasyon durumunu ve konum bilgisini kontrol eder.
6. Uygunsa rezervasyon oluşturulur.
7. Masa durumu güncellenir.
8. Öğrenci aktif rezervasyonunu uygulama üzerinden görüntüler.

---

## Sıra ve Sorun Bildirme Akışı

Dolu veya rezerve masalar için öğrenci sıraya girebilir. Böylece masa uygun hale geldiğinde sistem üzerinden takip yapılabilir. Ayrıca masa ile ilgili bir problem olduğunda öğrenci sorun bildirimi oluşturabilir. Bu bildirimler Admin ve Staff rolleri tarafından görüntülenip durum bilgisi güncellenebilir.

---

## Test Edilen Başlıca Akışlar

- Backend projesinin çalıştırılması
- Swagger erişimi
- Veritabanı bağlantısı ve migration kontrolü
- Seed data kontrolü
- Login işlemi
- JWT token ile yetkili endpoint erişimi
- Rol bazlı yetkilendirme
- Refresh token ve logout işlemleri
- Lokasyon alanı işlemleri
- Masa işlemleri
- QR kod işlemleri
- Rezervasyon oluşturma, yenileme ve tamamlama
- Staff/Admin force complete işlemleri
- Queue entry işlemleri
- Issue report işlemleri
- Bildirim ve device token işlemleri
- Flutter login ekranı
- Flutter öğrenci paneli
- QR kod ile rezervasyon oluşturma
- Aktif rezervasyon görüntüleme
- Masa durumlarının listelenmesi
- Sorun bildirme ve bildirim paneli

---

## Güvenlik ve Yetkilendirme

Sistemde JWT tabanlı kimlik doğrulama kullanılmaktadır. Kullanıcı giriş yaptıktan sonra access token alır ve sonraki API isteklerinde bu token `Authorization` header alanında gönderilir.

```http
Authorization: Bearer <accessToken>
```

Endpointler role göre sınırlandırılmıştır. Böylece Student, Staff ve Admin kullanıcıları yalnızca kendi yetki alanlarına uygun işlemleri gerçekleştirebilir.

---

## Proje İçeriği

Arşiv içerisinde aşağıdaki dosyalar bulunmaktadır:

- Backend kaynak kodları
- Flutter frontend kaynak kodları
- Proje raporu
- Proje sunumu
- Poster dosyaları

Bu yapı sayesinde proje hem teknik kaynak kodları hem de sunum/rapor materyalleriyle birlikte bütüncül olarak hazırlanmıştır.

---

## Lisans

Bu proje eğitim ve dönem sonu uygulaması kapsamında geliştirilmiştir. Kullanım ve paylaşım sürecinde proje ekibinin emeğine atıf yapılması önerilir.
=======

