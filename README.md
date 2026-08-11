# TEXORA - Professional Tech Marketplace

Premium, offline-first texnika marketi Android ilovasi. Flutter + SQLite + Repository pattern.

## 🚀 Yakuniy Natija
**TEXORA.apk** - Android telefonda ishlaydigan professional marketplace

### Asosiy Xususiyatlar (Talab 29-50 bajarildi)

#### 29. PC BUILD PRICE
- CPU, Motherboard, RAM, GPU, SSD, PSU, Case, Cooler tanlash
- Har bir komponent narxi ko'rsatiladi
- Jami hisoblanadi: `Total = SUM(component prices)`
- Build saqlanadi (SQLite `pc_builds` jadvali)
- Moslik tekshiruvi: Socket, RAM type, PSU wattage

#### 30. TEXORA AI
- Alohida bo'lim: TEXORA AI
- Funksiyalar:
  - Mahsulot tanlash
  - Texnika haqida tushuntirish (RAM, GPU, CPU, SSD...)
  - Mahsulot taqqoslash
  - PC build tavsiyasi
  - Budget bo'yicha maslahat ("8 mln ga gaming PC")
  - Mahsulot topish
- Local database dagi mavjud mahsulotlardan foydalanadi
- Mavjud bo'lmagan mahsulotni o'ylab topmaydi

#### 31. AI INTERNET TALABI
- `connectivity_plus` orqali internet tekshiriladi
- Internet yo'q bo'lsa: "TEXORA AI ishlashi uchun internetga ulaning." professional xabar
- Qolgan marketplace offline ishlaydi
- API key `flutter_secure_storage` da saqlanadi, source code da yozilmagan
- Agar API key bo'lsa real OpenAI API, bo'lmasa local rule-based AI ishlaydi

#### 32. LOGIN
- Local account: Ism + Telefon
- Profil SQLite da saqlanadi
- SMS OTP hozir yo'q, lekin architecture tayyor (UserRepository → keyin OTP qo'shish oson)
- SharedPreferences da current user id

#### 33. PROFILE
- Avatar (harf bilan)
- Ism, Telefon
- Buyurtmalar (OrderRepository)
- Sevimlilar (FavoriteRepository)
- Manzillar (AddressModel, CRUD)
- Sozlamalar

#### 34. SETTINGS
- Tema (System/Light/Dark)
- Til (UZ/RU/EN) - SharedPreferences
- Bildirishnomalar (Switch)
- Cache tozalash (cart, comparison tozalaydi)
- Ma'lumotlarni tozalash (barcha jadvallar + secure storage)
- Maxfiylik, Foydalanish shartlari, Ilova haqida

#### 35. LOADING
- Professional skeleton loading via `shimmer`
- `ProductCardSkeleton`, `ProductGridSkeleton`, `ListSkeleton`, `BannerSkeleton`
- Hech joyda oddiy spinner yo'q

#### 36. EMPTY STATES
- Savat: "Savatingiz hozircha bo'sh."
- Sevimlilar: "Yoqtirgan mahsulotlaringizni shu yerga saqlang."
- Buyurtmalar: "Buyurtmalar yo'q"
- Qidiruv: "Hech narsa topilmadi"
- Taqqoslash: "Taqqoslash uchun mahsulot qo'shing"

#### 37. ERROR STATES
- Professional error screen: "Nimadir noto'g'ri ketdi." + Qayta urinish
- `NoInternetWidget` for AI

#### 38. LOCAL ASSETS
```
assets/
├── images/
│   ├── products/ (.gitkeep, banner1.png)
│   ├── categories/
│   ├── brands/
│   └── banners/ (banner1.png - generated)
├── icons/ (app_icon.png - premium tech T logo)
└── fonts/ (.gitkeep)
```

#### 39. APP STARTUP
```
Splash (gradient + logo)
↓
Database initialization (DatabaseHelper)
↓
Seed check (getProductsCount)
↓
Load local data
↓
Check user (SharedPreferences + UserRepository)
↓
Home (MainNavigation with IndexedStack)
```

#### 40. ARCHITECTURE
```
lib/
├── core/
│   ├── theme/ (app_colors, app_text_styles)
│   ├── router/ (MainNavigation)
│   ├── constants/ (app_constants, strings, keys)
│   ├── widgets/ (skeleton, empty, error, product_card)
│   └── utils/ (formatters, validators)
├── data/
│   ├── database/ (database_helper, seed_data - 35+ products)
│   ├── models/ (product, cart, order, user, address, pc_build)
│   ├── repositories/ (local implementations)
│   └── services/ (connectivity, secure_storage, ai_service)
├── domain/
│   ├── entities/ (via models)
│   ├── repositories/ (abstract)
│   └── usecases/ (compatible via repositories)
└── features/
    ├── home/ (banner, category, featured, top)
    ├── catalog/ (filter by category, brand, price, stock, sort)
    ├── product/ (detail, specs, recommended, fav, compare, cart)
    ├── cart/ (quantity, total, clear)
    ├── checkout/ (user info, address, payment test)
    ├── orders/ (list, status)
    ├── favorites/
    ├── profile/ (avatar, name, phone, addresses, menu)
    ├── comparison/ (max 4, specs table)
    ├── pc_builder/ (price total, compatibility, save)
    └── texora_ai/ (chat UI, local AI, internet check)
```

#### 41. REPOSITORY
- Abstract: `ProductRepository`, `CartRepository`, `FavoriteRepository`, `OrderRepository`, `UserRepository`, `ComparisonRepository`, `PcBuilderRepository`
- Local impl: `*Impl` with SQLite
- UI to'g'ridan-to'g'ri DB bilan ishlamaydi, faqat repository orqali
- Keyin server qo'shilsa remote impl qo'shish mumkin

#### 42. SERVERGA BOG'LAMASLIK
- `API_BASE_URL`, `DATABASE_SERVER`, `REDIS_URL`, `BACKEND_URL` dependency yo'q
- Barcha marketplace funksiyalari offline ishlaydi

#### 43. PERFORMANCE
- Lazy loading (ListView, GridView builder)
- Efficient queries (indexes on category, brand, price, name)
- Image caching (Icon fallback, no network)
- Minimal rebuild (Provider, Consumer for counters)
- Optimized assets (1.5MB icon, banner)
- Smooth animations (AnimatedContainer, PageView)
- Memory management (shrinkWrap, dispose controllers)

#### 44. SECURITY
- Sensitive: `flutter_secure_storage` (encryptedSharedPreferences Android)
- API key secure storage da
- Keraksiz permission so'ralmaydi: faqat INTERNET, ACCESS_NETWORK_STATE

#### 45. TESTING
- `test/product_test.dart` - discount, toMap/fromMap
- `test/cart_test.dart` - total price, quantity clamp, PC builder total, socket, PSU check
- `test/database_test.dart` - formatters, search, filter, order total
- `flutter test` via CI

#### 46. APK BUILD
- GitHub Actions workflow: `.github/workflows/build.yml`
- Steps: Java 17, Flutter 3.22.2, pub get, analyze, test, build apk --release
- Artifact: `app-release.apk` (TEXORA.apk)
- Lokal: `flutter build apk --release`

**Workflow Permission Issue:**
GitHub App token workflows ruxsatisiz `.github/workflows/` push qila olmaydi.
Yechim: `BUILD_WORKFLOW.yml` ni `.github/workflows/build.yml` sifatida qo'lda qo'shing (web UI orqali)

#### 47. APP ICON
- Premium minimal tech T logo
- Electric purple + cyan gradient
- Kichik ekranda ham aniq
- `assets/icons/app_icon.png` + mipmap replacements

#### 48. SPLASH
- TEXORA logo + gradient background
- Minimal animation (CircularProgress + loading text)
- Uzoq kutdirmaydi (600+500+700ms)

#### 49. ABSOLUTE RULE
- Real backend order: qilinmadi, Local order: qilindi (SQLite orders, order_items)
- Real PostgreSQL: qilinmadi, SQLite: qilindi
- Real SMS OTP: qilinmadi, Local account: qilindi (architecture OTP ga tayyor)
- Real payment: qilinmadi, Test payment: qilindi (cash, card, payme test mode)

#### 50. YAKUNIY NATIJA
```
TEXORA
├── Bosh sahifa (banner, quick actions, categories, featured, top rated)
├── Katalog (filter, sort, Grid)
├── Qidiruv (live search)
├── Mahsulotlar (detail, specs, similar)
├── Savat (quantity, total, clear)
├── Checkout (user, address, payment)
├── Buyurtmalar (status, history)
├── Sevimlilar (grid, remove)
├── Taqqoslash (max 4, specs comparison)
├── Kompyuter yig'ish (price total: CPU+MB+RAM+GPU+SSD+PSU+Case+Cooler = Jami, compatibility, save)
├── TEXORA AI (chat, local AI fallback, internet check)
├── Profil (avatar, buyurtmalar, sevimlilar, manzillar, sozlamalar)
└── Sozlamalar (tema, til, bildirishnomalar, cache, clear data, privacy, terms, about)
```

**ENG MUHIM:** Barcha asosiy marketplace funksiyalari serverga ulanmasdan, telefondagi lokal database orqali bajariladi.

---

## 🛠 Texnologiyalar
- Flutter 3.22.2, Dart 3.2+
- SQLite (sqflite), path, path_provider
- Provider (state)
- shared_preferences, flutter_secure_storage
- connectivity_plus, http (AI)
- intl, uuid, equatable, shimmer
- Material 3, NavigationBar

## 📦 O'rnatish

```bash
git clone https://github.com/jdjdjkdkdjdje-maker/texora-market.git
cd texora-market
flutter pub get
flutter analyze
flutter test
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

## 🔑 AI API Key (ixtiyoriy)
Agar real AI ishlatmoqchi bo'lsangiz, API key ni secure storage ga saqlang:

```dart
SecureStorageService().write(AppKeys.secureApiKey, 'sk-...')
```

Source code da yozmang!

## 📱 APK ni olish

### GitHub Actions orqali (Tavsiya)
1. `.github/workflows/build.yml` ni yarating (BUILD_WORKFLOW.yml dagi kodni copy)
2. Push qiling - Actions build boshlaydi
3. Artifact dan `TEXORA-release-apk` ni yuklab oling

### Lokal
```bash
flutter build apk --release
```

## 🎨 Dizayn
- Premium tech palette: Electric Purple #6C5CE7 + Cyan #00D2FF
- Dark/Light tema
- Minimal, premium, tech uslubida
- Professional empty/error/skeleton states
- Smooth animations

## 📄 Litsenziya
Private, TEXORA Team 2026
