# Device Calendar Plugin

A cross platform plugin for modifying calendars on the user's device.

## Features
* Check if permissions to modify the calendars on the user's device have been granted
* Add or retrieve calendars on the user's device
* Retrieve events associated with a calendar
* Add, update or delete events from a calendar

## Timezone support with TZDateTime

Due to feedback we received, starting from `4.0.0` we will be using the `timezone` package to better handle all timezone data.

This is already included in this package. However, you need to add this line whenever the package is needed.

```dart
import 'package:timezone/timezone.dart';
```

If you don't need any timezone specific features in your app, you may use `flutter_native_timezone` to get your devices' current timezone, then convert your previous `DateTime` with it.

```dart
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

// As an example, our default timezone is UTC.
Location _currentLocation = getLocation('Etc/UTC');

Future setCurentLocation() async {
  String timezone = 'Etc/UTC';
  try {
    timezone = await FlutterNativeTimezone.getLocalTimezone();
  } catch (e) {
    print('Could not get the local timezone');
  }
  _currentLocation = getLocation(timezone);
  setLocalLocation(_currentLocation);
}

...

event.start = TZDateTime.from(oldDateTime, _currentLocation);
```

## Android Integration

The following will need to be added to the `AndroidManifest.xml` file for your application to indicate permissions to modify calendars are needed

```xml
<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />
```

### Proguard / R8 exceptions

By default, all android apps go through R8 for file shrinking when building a release version. Currently, it interferes with some functions such as `retrieveCalendars()`.

You may add the following setting to the ProGuard rules file `proguard-rules.pro` (thanks to [Britannio Jarrett](https://github.com/britannio)). Read more about the issue [here](https://github.com/builttoroam/device_calendar/issues/99)

```
-keep class com.builttoroam.devicecalendar.** { *; }
```

See [here](https://github.com/builttoroam/device_calendar/issues/99#issuecomment-612449677) for an example setup.

For more information, refer to the guide at [Android Developer](https://developer.android.com/studio/build/shrink-code#keep-code)

## iOS Integration

For iOS 10+ support, you'll need to modify the `Info.plist` to add the following key/value pair

```xml
<key>NSCalendarsUsageDescription</key>
<string>Access most functions for calendar viewing and editing.</string>

<key>NSContactsUsageDescription</key>
<string>Access contacts for event attendee editing.</string>
```

For iOS 17+ support, add the following key/value pair as well.

```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>Access most functions for calendar viewing and editing.</string>
```

Note that on iOS, this is a Swift plugin. There is a known issue being tracked [here](https://github.com/flutter/flutter/issues/16049) by the Flutter team, where adding a plugin developed in Swift to an Objective-C project causes problems. If you run into such issues, please look at the suggested workarounds there.

## Installation

To add the `device_calendar` package to your project, include it in the `pubspec.yaml` file:

```yaml
dependencies:
  device_calendar: ^4.0.0
```
After updating the `pubspec.yaml` file, run the following command to install the package:

```bash
flutter pub get
```
