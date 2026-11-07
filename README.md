# Flutter Lab

An interactive playground for exploring Flutter capabilities on Android and Windows.

## Capability labs

- **UI Studio** — Material 3 controls, component states and themes.
- **Animation Studio** — implicit animations, animation controllers and curves.
- **Gesture Lab** — taps, long presses, dragging and scaling.
- **Graphics Lab** — Canvas, gradients and CustomPainter.
- **Canvas Lab** — freehand drawing with brush colors, undo, redo and clear.
- **Charts Lab** — interactive bar, line and pie charts.
- **Developer Tools** — runtime information and a copyable diagnostic console.
- **Adaptive Layout** — LayoutBuilder, MediaQuery and responsive grids.
- **Navigation Lab** — page transitions, dialogs, bottom sheets and nested page state.
- **State Lab** — setState, ValueNotifier and streams.
- **Storage Lab** — persistent preferences and JSON export.
- **Device Lab** — Android/Windows device information and accelerometer events where supported.
- **Network Lab** — HTTPS requests and JSON decoding.
- **Accessibility Lab** — Semantics, scalable text and high-contrast previews.
- **Performance Lab** — rebuild counters, RepaintBoundary and custom-painted particles.
- **Platform Tools** — camera/gallery capture, file picking, sharing, clipboard and haptics.
- **Audio Lab 2.0** — streamed download progress, waveform-style playback visualization, playback speed and looping.
- **Download Queue** — add HTTP(S) files, process sequentially and monitor progress, completion and retry states.
- **Notifications Lab** — Android notification permission and local notifications.
- **Concurrency Lab** — CPU-heavy prime counting on a background Dart isolate.
- **App Lifecycle Lab** — observe pause, resume and other lifecycle transitions.
- **Keyboard & Shortcuts Lab** — hardware keyboard input, Shortcuts and Actions.
- **Localization & Formatting Lab** — English, Filipino and Spanish copy with locale-aware dates and PHP currency.
- **Forms & Validation Lab** — form state, input types, validation and focus handling.
- **Drag & Drop Lab** — draggable widgets, drop targets and reorderable lists.
- **Streams & Async Lab** — asynchronous event streams and StreamBuilder.

## App settings and quality of life

- First-run onboarding introduces the main labs and personalization controls.
- Reorder the capability dashboard and keep your preferred layout between launches.

- Persistent system/light/dark theme, accent color and text scaling.
- Animation and haptic feedback toggles.
- Favorites and recently opened labs saved locally.
- Search across the capability catalog and filter favorite labs.

## Flame game lab

The **Flame Game Lab** is a playable side-scrolling platformer built with the Flame engine. It includes a fixed-resolution game camera, player movement and jumping, platform landing, coin collection, patrolling enemies, health, pause/restart states and mobile touch controls plus keyboard input on desktop. Kenney Platformer Art Deluxe sprites are included under `assets/images/flame/` (CC0).

## Platforms

The project targets Android and Windows. Platform projects are generated in CI from the Flutter SDK so the repository stays focused on the shared Dart application.


## Platform support

| Capability | Android | Windows |
|---|---|---|
| Material UI, animation, graphics and adaptive layouts | Yes | Yes |
| Keyboard shortcuts and drag-and-drop | Touch + hardware keyboard | Yes |
| Device information | Yes | Yes |
| Accelerometer | Device-dependent | Hardware-dependent |
| Camera and gallery picker | Yes | Not included |
| File picker, clipboard and share sheet | Yes | Yes |
| Haptic feedback | Device-dependent | Platform-dependent |
| Local notifications | Yes | Not included in this demo |
| Audio and HTTP examples | Internet required | Internet required |
| Isolates, streams, forms and localization | Yes | Yes |

Some capabilities depend on the operating system, hardware, permissions or an internet connection. The labs show the API integration and handle unsupported platform actions with a message where applicable.

## CI artifacts

Pushes to `main` run formatting, static analysis and widget tests before building:
- Android release APK (`flutter-lab-android`)
- Windows release bundle (`flutter-lab-windows`)

GitHub Actions artifacts are retained for 7 days.

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
