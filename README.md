# Flutter Calendar Demo App

A modern Flutter application demonstrating how to view, create, and manage device calendars and calendar events using `device_calendar` with Flutter Version Management (FVM).

---

## 🚀 Features

- **Device Calendars Overview**: View all available calendars on the device (read-only and writable).
- **Create Local Calendars**: Easily add new local calendars (especially helpful on emulators without a linked account).
- **Calendar Events**: View, create, edit, and delete calendar events.
- **Event Customization**:
  - Event title, description, and location.
  - Start and end date/time selection.
  - All-day events.
  - Recurrence rules (daily, weekly, monthly, yearly with frequency and interval).
  - Reminders / alerts with custom minutes before the event.
  - Attendees / guests management.
  - URL attachments and event availability (busy, free, tentative).
- **Timezone Awareness**: Accurate local timezone handling via `flutter_timezone` and `timezone`.
- **Friendly UX**: Empty states, permission request prompts, and pull-to-refresh.

---

## 🛠️ Requirements & Environment

- **Flutter Version**: `3.38.7` (managed via [FVM](https://fvm.app/))
- **Dart SDK**: `^3.10.7`
- **Android**: API 21+
- **iOS**: iOS 10+ (iOS 17+ permissions configured)

---

## 📦 Getting Started

### 1. Install FVM (if not installed)

```bash
dart pub global activate fvm
```

### 2. Set Up the Flutter SDK

Use FVM to activate the configured Flutter version (`3.38.7`):

```bash
fvm use 3.38.7
```

### 3. Install Dependencies

```bash
fvm flutter pub get
```

### 4. Run the Application

```bash
# Run on connected device or emulator
fvm flutter run
```

---

## 🧪 Testing & Code Quality

Run tests:
```bash
fvm flutter test
```

Analyze code:
```bash
fvm flutter analyze
```

---

## ⚙️ Platform Permissions Configuration

### Android Setup (`android/app/src/main/AndroidManifest.xml`)

The following permissions are required in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

> **Note on Android Emulators**: If you are testing on an Android emulator without a logged-in Google Account, the list of calendars may initially be empty. Use the **"New Calendar"** button in the app to create a local calendar for testing.

### iOS Setup (`ios/Runner/Info.plist`)

The following keys are configured in `Info.plist`:

```xml
<key>NSCalendarsUsageDescription</key>
<string>Access calendar for viewing and editing events.</string>

<key>NSContactsUsageDescription</key>
<string>Access contacts for event attendee selection.</string>

<!-- For iOS 17+ -->
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Access calendar for viewing and editing events.</string>
```
