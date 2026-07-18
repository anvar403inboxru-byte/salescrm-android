# ORBITSON CRM — Android Mobile App

Flutter ilə hazırlanmış ORBITSON CRM mobil tətbiqi.

## 📱 Xüsusiyyətlər

- **Dashboard** — Satış analitikası, KPI kartlar, pipeline
- **Müştərilər** — Axtarış, filter, detallı baxış
- **Qiymət Təklifləri** — Status üzrə filter
- **Tapşırıqlar** — Prioritet və status filter
- **Kontaktlar** — Axtarış ilə siyahı
- **Profil** — İstifadəçi məlumatları, çıxış

## 🛠 Texnologiyalar

- Flutter 3.24+
- Dart 3.5+
- Provider (state management)
- GoRouter (navigation)
- flutter_secure_storage (token saxlama)
- http (API sorğuları)

## 🚀 Quraşdırma

```bash
flutter pub get
flutter run
```

## ⚙️ Backend konfiqurasiyası

`lib/services/api_service.dart` faylında `baseUrl`-i dəyişin:

```dart
static const String baseUrl = 'https://YOUR_BACKEND_URL';
```

## 🏢 ORBITSON MMC

2/6 Ahmad Rajabli st., Baku, Azerbaijan  
www.orbitson.com