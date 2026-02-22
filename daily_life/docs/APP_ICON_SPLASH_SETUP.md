# DailyLife — Android App Icon & Splash Screen Setup

## 🎨 App Icon

### Step 1: Install the launcher icon package

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3
```

### Step 2: Add icon configuration

Add this at the bottom of `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#0A1628" # deepSapphire color
  adaptive_icon_foreground: "assets/icon/app_icon_fg.png"
```

### Step 3: Create icon assets

Create a **1024×1024 PNG** icon:

- Background: `#0A1628` (deep sapphire)
- Foreground: A white/blue daily planner icon with a checkmark
- Place it at: `assets/icon/app_icon.png`
- For adaptive icon, create a **432×432** foreground at: `assets/icon/app_icon_fg.png`

### Step 4: Generate

```bash
flutter pub get
dart run flutter_launcher_icons
```

---

## 🌊 Splash Screen

### Step 1: Install flutter_native_splash

Add to `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.4
```

### Step 2: Add splash configuration

Add this at the bottom of `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#0A1628" # deepSapphire background
  image: "assets/splash/splash_logo.png" # centered logo
  android: true
  ios: false
  android_12:
    color: "#0A1628"
    image: "assets/splash/splash_logo.png"
```

### Step 3: Create splash assets

Create a **288×288 PNG** logo:

- White or `#4A9EFF` (glowingBlue) icon on transparent background
- Place at: `assets/splash/splash_logo.png`

### Step 4: Generate

```bash
flutter pub get
dart run flutter_native_splash:create
```

---

## 📱 Quick Checklist

| Item                                        | Status        |
| ------------------------------------------- | ------------- |
| App icon 1024×1024                          | ⬜ Create     |
| Adaptive icon background `#0A1628`          | ✅ Configured |
| Adaptive icon foreground 432×432            | ⬜ Create     |
| Splash screen background `#0A1628`          | ✅ Configured |
| Splash logo 288×288                         | ⬜ Create     |
| Run `dart run flutter_launcher_icons`       | ⬜ Run        |
| Run `dart run flutter_native_splash:create` | ⬜ Run        |

## 🔒 Portrait Lock

Already implemented in `main.dart`:

```dart
await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
]);
```
