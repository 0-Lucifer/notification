# Medication Reminder App

A beautiful and fully functional **Medication Reminder App** built with Flutter.

This app helps you never miss a dose by sending daily local notifications at your chosen times — even when the app is closed. It supports multiple medications, custom reminder times, dosage instructions, frequency settings, and limited-duration reminders with automatic cleanup.

Perfect for patients, caregivers, or anyone managing daily medication schedules.

## Features

- **Add/Edit Medications:** Enter name, dosage/instructions, and multiple reminder times.
- **Reminder Settings:** Set frequency (e.g., every 6 hours, daily) and duration (ongoing or with stop date).
- **Swipe to Delete:** Easy removal of medications.
- **Tap to Edit:** Quick updates to existing reminders.
- **Persistent Storage:** Data saved using `shared_preferences` — survives app restarts/closes.
- **Local Notifications:** Daily repeating alerts via `flutter_local_notifications` (works in background).
- **Permission Handling:** Requests notification and exact alarm permissions (via `permission_handler`).
- **Auto Cleanup:** Removes expired reminders on app open.
- **Clean UI:** Material 3 design with teal theme.
- **Cross-Platform:** Fully tested on Android and iOS.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- **Lab:** Write your first Flutter app  
- **Cookbook:** Useful Flutter samples  
- **Online documentation:** Tutorials, samples, and full API reference

## Prerequisites

- Flutter SDK (v3.22+ recommended)  
- Dart SDK (included with Flutter)  
- Android Studio / Xcode  
- Physical device or emulator for notification testing

## Installation

### Clone the repo

```bash
git clone <your-repo-url>
cd medication-reminder-app
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Configuration

### AndroidManifest.xml (Exact alarms)

```xml
<manifest ...>
  <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
</manifest>
```

### build.gradle.kts (Desugaring & setup)

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.notifiations"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.example.notifiations"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.4
  shared_preferences: ^2.3.2
  permission_handler: ^11.3.1
```

## Usage

1. Launch the app → Tap **Reminders** on the home screen.  
2. Add a medication via **+** button.  
3. Customize settings via gear icon.  
4. Close the app — notifications still fire.  
5. Reopen to load saved reminders; expired ones are auto-removed.

## Troubleshooting

### No Notifications?

- Ensure permissions are granted.  
- Use a physical device (iOS simulators often don't show notifications).  
- On Android 12+: enable **Exact Alarms**.  
- Schedule a reminder 1–2 minutes ahead and background the app.  

### Build Errors?

```bash
flutter clean
flutter pub get
```

### iOS Notes

- Add required background modes to **Info.plist** if necessary.

### Logs

```bash
flutter run -v
```

## Project Structure

```
lib/
├── main.dart              # Entry point & home screen
└── screens/
    ├── addmed.dart        # Add/Edit medication screen
    ├── reminders.dart     # Main reminders list screen
    └── remindersettings.dart # Settings screen per medication
```

## Dependencies

- **flutter_local_notifications:** Scheduling alerts  
- **timezone:** Time zone management  
- **shared_preferences:** Persistent storage  
- **permission_handler:** Permission requests  

## License

MIT License. Feel free to use, modify, or distribute.

Built on **November 30, 2025**.  
For issues, open a GitHub issue or PR.
