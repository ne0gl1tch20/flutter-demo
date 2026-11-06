# Flutter Lab

An interactive playground for exploring Flutter capabilities on Android and Windows.

## Capability labs

- **UI Studio** — Material 3 controls, component states and themes.
- **Animation Studio** — implicit animations, animation controllers and curves.
- **Gesture Lab** — taps, long presses, dragging and scaling.
- **Graphics Lab** — Canvas, gradients and CustomPainter.
- **Adaptive Layout** — LayoutBuilder, MediaQuery and responsive grids.
- **Navigation Lab** — page transitions, dialogs, bottom sheets and nested page state.
- **State Lab** — setState, ValueNotifier and streams.
- **Storage Lab** — persistent preferences and JSON export.
- **Device Lab** — Android/Windows device information and accelerometer events where supported.
- **Network Lab** — HTTPS requests and JSON decoding.
- **Accessibility Lab** — Semantics, scalable text and high-contrast previews.
- **Performance Lab** — rebuild counters, RepaintBoundary and custom-painted particles.
- **Platform Tools** — camera/gallery capture, file picking, sharing, clipboard and haptics.
- **Audio Lab** — online audio playback and stop controls.
- **Notifications Lab** — Android notification permission and local notifications.

## Platforms

The project targets Android and Windows. Platform projects are generated in CI from the Flutter SDK so the repository stays focused on the shared Dart application.

## Run locally

Install the Flutter stable SDK, then:

```sh
flutter pub get
flutter run
```

For Android:

```sh
flutter run -d <android-device>
flutter build apk --release
```

For Windows (on Windows):

```sh
flutter config --enable-windows-desktop
flutter create --platforms=windows --project-name=flutterlab --org=com.jarrlyyy .
flutter run -d windows
flutter build windows --release
```

## Quality checks

```sh
dart format --output=none .
flutter analyze --fatal-infos
flutter test
```

## Package identity

- Dart project: `flutter_lab`
- Android application ID: `com.jarrlyyy.flutterlab`
- Windows runner name: `flutterlab`

Some labs use plugins and native platform APIs. Device features depend on hardware, operating-system support and permissions. The network and audio labs require an internet connection. Camera/gallery capture is mobile-only. Local notifications are currently demonstrated on Android.
