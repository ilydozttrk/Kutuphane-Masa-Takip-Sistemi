# Library Seat Tracking App - Flutter Frontend

Bu proje, kütüphane çalışma masalarının durumunu takip etmek, öğrencilerin QR kod ile rezervasyon oluşturmasını sağlamak ve masa kullanım sürecini dijital olarak yönetmek için geliştirilen Flutter mobil uygulamasıdır.

Bu repository yalnızca **Flutter frontend** projesini içerir. Backend projesi ayrı olarak geliştirilmiştir ve bu repoda backend dosyası bulunmaz.

---

## Proje Durumu

Şu ana kadar Flutter tarafında backend ile entegrasyon büyük ölçüde tamamlanmıştır. Backend tarafındaki mevcut endpoint yapısına dokunulmadan, frontend tarafında gerekli servisler, modeller ve ekran bağlantıları oluşturulmuştur.

Temel hedefimiz:

- Backend kodunu değiştirmeden Flutter uygulamasını backend'e uygun hale getirmek
- Öğrenci panelini gerçek backend verileriyle çalıştırmak
- QR kod ile rezervasyon oluşturma ve yenileme akışını bağlamak
- Bildirim, sorun bildirme ve sıraya girme işlemlerini frontend tarafında kullanılabilir hale getirmek

---

## Kullanılan Teknolojiler

- Flutter
- Dart
- ASP.NET Core Web API ile entegrasyon
- REST API
- Firebase Cloud Messaging
- SharedPreferences
- Geolocator
- Mobile Scanner
- HTTP package

---

## Proje Klasör Yapısı

```text
library_seat_tracking_app/
│
├── android/
├── ios/
├── lib/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── firebase_options.dart
│   └── main.dart
│
├── test/
├── web/
├── windows/
├── pubspec.yaml
├── pubspec.lock
├── firebase.json
├── LICENSE
└── README.md
```

---

## Backend Bağlantısı

Flutter uygulaması backend API ile haberleşecek şekilde düzenlenmiştir.

Kullanılan temel base URL yapısı:

```dart
// Web için
http://localhost:5024/api

// Android Emulator için
http://10.0.2.2:5024/api
```

Backend isteklerinde JWT token kullanılmaktadır. Login işleminden sonra alınan `accessToken`, `SharedPreferences` içine kaydedilir ve sonraki API isteklerinde otomatik olarak header içine eklenir.

```http
Authorization: Bearer <accessToken>
```

---

## Eklenen ve Kullanılan Servisler

Flutter tarafında backend endpointleriyle düzenli iletişim kurmak için servis yapısı oluşturulmuştur.

```text
lib/services/api_client.dart
lib/services/auth_service.dart
lib/services/study_table_service.dart
lib/services/reservation_service.dart
lib/services/location_service.dart
lib/services/notification_service.dart
lib/services/device_token_service.dart
lib/services/queue_entry_service.dart
lib/services/issue_report_service.dart
lib/services/app_notification_service.dart
```

---

## Eklenen Modeller

Backend'den gelen verileri Flutter tarafında karşılamak için model sınıfları oluşturulmuştur.

```text
lib/models/study_table_model.dart
lib/models/reservation_model.dart
lib/models/queue_entry_model.dart
lib/models/issue_report_model.dart
lib/models/app_notification_model.dart
```

---

## Giriş Sistemi

Login ekranı backend'deki kimlik doğrulama endpointine bağlanmıştır.

Kullanılan endpoint:

```http
POST /api/auth/login
```

Login başarılı olduğunda backend'den gelen kullanıcı bilgileri alınır:

- fullName
- role
- accessToken
- refreshToken
- email
- userId

Kullanıcı rolü `Student` ise öğrenci paneline yönlendirilir.

---

## Öğrenci Paneli

Öğrenci paneli artık sabit verilerle değil, backend'den gelen gerçek verilerle çalışmaktadır.

Öğrenci panelinde bulunan temel özellikler:

- Hoş geldin alanı
- Çıkış yap butonu
- QR okut butonu
- Aktif rezervasyon kartı
- Masa durumları listesi
- Dolu/rezerve masalarda sıraya girme kontrolü
- Sorun bildir butonu
- Bildirim ikonu ve sağdan açılan bildirim paneli
- Yenile butonu

---

## Masa Durumları

Masa verileri backend'den çekilmektedir.

Kullanılan endpoint:

```http
GET /api/study-tables
```

Masa durumlarına göre arayüzde renklendirme yapılmıştır:

| Masa Durumu | Renk |
|---|---|
| Boş | Yeşil |
| Dolu | Kırmızı |
| Rezerve | Turuncu |
| Bakımda | Gri |

Masa kartlarında masa kodu, durum bilgisi, konum alanı, sorun bildirme ve sıraya girme alanları gösterilmektedir.

---

## Aktif Rezervasyon

Öğrencinin aktif rezervasyonu backend'den alınmaktadır.

Kullanılan endpoint:

```http
GET /api/reservations/my
```

Aktif rezervasyon varsa öğrenci panelinde şu bilgiler gösterilir:

- Masa kodu
- Başlangıç zamanı
- Bitiş zamanı
- Kalan süre
- Rezervasyonu bitir butonu

Aktif rezervasyon yoksa kullanıcıya bilgi mesajı gösterilir.

---

## QR Kod ile Rezervasyon

QR okutma akışı backend'e uygun hale getirilmiştir. QR kod değeri frontend tarafında değiştirilmeden backend'e gönderilir.

Örnek QR kod:

```text
QR-A101-TEST
```

Rezervasyon oluşturma sırasında gönderilen temel bilgiler:

- qrCode
- userLatitude
- userLongitude
- durationMinutes

Kullanılan endpoint:

```http
POST /api/reservations
```

Konum kontrolü frontend tarafında yapılmaz. Flutter yalnızca cihaz konumunu backend'e gönderir. Kullanıcının masa alanı içinde olup olmadığına backend karar verir.

---

## Rezervasyon Yenileme

Aktif rezervasyon varsa QR okutulduğunda yeni rezervasyon oluşturmak yerine yenileme isteği gönderilir.

Kullanılan endpoint:

```http
POST /api/reservations/renew
```

Gönderilen temel bilgiler:

- qrCode
- userLatitude
- userLongitude
- extraMinutes

Yenileme iznini backend belirler. Frontend sadece QR ve konum bilgisini gönderir.

---

## Rezervasyonu Bitirme

Aktif rezervasyon kartına rezervasyonu bitirme butonu eklenmiştir.

Kullanılan servis metodu:

```dart
ReservationService.completeReservation(...)
```

İşlem başarılı olduğunda:

- Aktif rezervasyon bilgisi yenilenir
- Masa listesi tekrar çekilir
- Masa durumu güncellenir

---

## Sıraya Girme Sistemi

Dolu veya rezerve masalar için sıraya girme sistemi Flutter tarafına eklenmiştir.

Kullanılan endpointler:

```http
GET  /api/queue-entries/my
POST /api/queue-entries
```

Aktif rezervasyonu olan öğrencinin sıraya girmesi frontend tarafında da engellenmiştir. Böylece kullanıcı gereksiz backend hatası almadan bilgilendirilir.

---

## Sorun Bildirme Sistemi

Öğrenci, masa kartı üzerinden sorun bildirimi oluşturabilir.

Kullanılan endpointler:

```http
GET  /api/issue-reports/my
POST /api/issue-reports
```

Gönderilen temel bilgiler:

- studyTableId
- description

Açıklama alanı için minimum karakter kontrolü yapılmıştır.

---

## Bildirim Sistemi

Firebase Cloud Messaging entegrasyonu yapılmıştır.

Yapılanlar:

- Firebase projesi oluşturuldu
- `flutterfire configure` çalıştırıldı
- `lib/firebase_options.dart` dosyası oluşturuldu
- `main.dart` içinde Firebase başlatıldı
- Bildirim izni alındı
- FCM token üretildi
- Login sonrası cihaz tokenı backend'e kaydedildi

Token kayıt endpointi:

```http
POST /api/device-tokens/register
```

Bildirimleri listelemek için kullanılan endpointler:

```http
GET /api/notifications/my
PUT /api/notifications/{notificationId}/read
```

Öğrenci panelinde sağ üstte bildirim ikonu bulunur. Okunmamış bildirim sayısı ikon üzerinde gösterilir. Bildirimler sağdan açılan panelde listelenir.

---

## Çıkış Yapma

Öğrenci paneline çıkış yapma özelliği eklenmiştir.

Çıkış yapıldığında `SharedPreferences` içindeki şu bilgiler temizlenir:

- accessToken
- refreshToken
- role
- fullName
- email
- userId

Daha sonra kullanıcı login ekranına yönlendirilir. Geri tuşu ile öğrenci paneline dönülmesi engellenmiştir.

---

## Şu Ana Kadar Test Edilen Akışlar

- Modern login ekranı açıldı
- Öğrenci hesabıyla giriş yapıldı
- Firebase bildirim izni alındı
- FCM token üretildi
- FCM token backend'e kaydedildi
- Öğrenci paneli açıldı
- Masa listesi backend'den geldi
- QR test ekranı açıldı
- QR kod ile rezervasyon oluşturuldu
- Aktif rezervasyon kartı görüntülendi
- Masa durumu güncellendi
- Aktif rezervasyon varken sıraya girme engellendi
- Sorun bildir butonu çalışır hale getirildi
- Bildirim drawer paneli eklendi
- Çıkış yapma işlemi eklendi

---

## Projeyi Çalıştırma

Önce backend projesi çalıştırılmalıdır.

Backend örnek çalıştırma komutu:

```powershell
cd C:\Users\husey\OneDrive\Masaüstü\LibrarySeatTrackingAPI-main
dotnet run --launch-profile http
```

Flutter projesi için:

```powershell
cd C:\Projects\library_seat_tracking_app
flutter pub get
flutter run
```

---

## Test Kullanıcısı

Öğrenci hesabı:

```text
Email: student@example.com
Şifre: Student123*
```

---

## Dikkat Edilen Noktalar

Bu projede backend dosyaları değiştirilmemiştir. Yapılan geliştirmeler yalnızca Flutter frontend tarafındadır.

Backend yalnızca endpoint yapısını ve veri formatını anlamak için incelenmiştir. Flutter tarafı, backend'in mevcut yapısına uygun şekilde geliştirilmiştir.

---

## Bundan Sonra Yapılacaklar

Sıradaki geliştirme adımı Admin/Staff panelinin backend'e uygun hale getirilmesidir.

Planlanan işler:

- Admin/Staff ekranının incelenmesi
- Yönetim paneli için gerekli modellerin oluşturulması
- Yönetim paneli için servislerin eklenmesi
- Masa yönetimi işlemlerinin bağlanması
- Sorun bildirimlerinin yönetim ekranına alınması
- QR kod yönetiminin eklenmesi
- Konum alanı yönetiminin bağlanması
- Kullanıcı rolüne göre ekran yönlendirmelerinin geliştirilmesi

Öğrenci panelinde yapılabilecek küçük iyileştirmeler:

- Türkçe karakterlerin manuel olarak düzeltilmesi
- QR test butonlarının finalde gizlenmesi veya kaldırılması
- Bildirim paneli tasarımının geliştirilmesi
- Emulator üzerinde final testlerinin yapılması

---

## Lisans

Bu proje MIT lisansı ile lisanslanmıştır.

```text
Copyright (c) 2026 Semanur YILDIRIM - İlayda ÖZTÜRK
```
