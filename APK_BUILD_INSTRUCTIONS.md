# TEXORA APK Build Qo'llanmasi

## Muammo: Workflow permission
GitHub App token `workflows` ruxsatisiz `.github/workflows/` fayllarini push qila olmaydi. Shuning uchun workflow ni qo'lda qo'shish kerak.

## Yechim 1: GitHub Web UI orqali
1. GitHub repo ga kiring: https://github.com/jdjdjkdkdjdje-maker/texora-market
2. `.github/workflows/` papkasini yarating (agar yo'q bo'lsa)
3. `build.yml` faylini yarating va quyidagi kontentni qo'ying:

```yaml
name: TEXORA Build APK
on:
  push:
    branches: [ "main", "arena/019ff223-texora-market" ]
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.2'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: TEXORA-release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

4. Commit qiling
5. Actions tab da build boshlanadi
6. Artifact dan `app-release.apk` ni yuklab oling -> nomi `TEXORA.apk` ga o'zgartiring

## Yechim 2: Lokal build
Agar Flutter o'rnatilgan bo'lsa:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Natija: `build/app/outputs/flutter-apk/app-release.apk`

## Yechim 3: GitHub CLI orqali (workflows permission bilan token)
Agar sizda Personal Access Token bo'lsa:

```bash
gh auth login --with-token < workflows scope
```

## TEXORA Talablari bajarildi:
- ✅ Offline-first, SQLite
- ✅ 35+ mahsulot seed
- ✅ Barcha feature lar: Bosh sahifa, Katalog, Qidiruv, Mahsulotlar, Savat, Checkout, Buyurtmalar, Sevimlilar, Taqqoslash, Kompyuter yig'ish, TEXORA AI, Profil, Sozlamalar
- ✅ Repository pattern
- ✅ Skeleton loading, Empty/Error states
- ✅ Local assets
- ✅ App startup: Splash->DB->Seed->Home
- ✅ Secure Storage
- ✅ Tests
- ✅ App icon, Splash

APK ni olish uchun yuqoridagi workflow ni qo'shing.
