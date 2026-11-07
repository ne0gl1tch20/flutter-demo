import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_lab/app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('home screen exposes the Flutter capability catalog', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());

    expect(find.text('Flutter Lab'), findsOneWidget);
    expect(find.text('Build. Explore. Experiment.'), findsOneWidget);
    expect(find.text('UI Studio'), findsOneWidget);
    expect(find.text('Animation Studio'), findsOneWidget);
    expect(find.text('Gesture Lab'), findsOneWidget);
    expect(find.text('Graphics Lab'), findsOneWidget);
    expect(find.text('Adaptive Layout'), findsOneWidget);
    expect(find.text('Navigation Lab'), findsOneWidget);
    expect(find.text('State Lab'), findsOneWidget);
    expect(find.text('Storage Lab'), findsOneWidget);
    expect(find.text('Device Lab'), findsOneWidget);
    expect(find.text('Network Lab'), findsOneWidget);
    expect(find.text('Accessibility Lab'), findsOneWidget);
    expect(find.text('Performance Lab'), findsOneWidget);
    expect(find.text('Platform Tools'), findsOneWidget);
    expect(find.text('Audio Lab'), findsOneWidget);
    expect(find.text('Notifications Lab'), findsOneWidget);
    expect(find.text('Concurrency Lab'), findsOneWidget);
    expect(find.text('App Lifecycle Lab'), findsOneWidget);
    expect(find.text('Keyboard & Shortcuts Lab'), findsOneWidget);
    expect(find.text('Localization & Formatting Lab'), findsOneWidget);
    expect(find.text('Forms & Validation Lab'), findsOneWidget);
    expect(find.text('Drag & Drop Lab'), findsOneWidget);
    expect(find.text('Streams & Async Lab'), findsOneWidget);
    expect(find.text('Canvas Lab'), findsOneWidget);\n    expect(find.text('Charts Lab'), findsOneWidget);\n    expect(find.text('Developer Tools'), findsOneWidget);\n    expect(find.text('Flame Game Lab'), findsOneWidget);
  });

  testWidgets('a capability card opens its lab', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.tap(find.text('UI Studio'));
    await tester.pumpAndSettle();

    expect(find.text('Button styles'), findsOneWidget);
    expect(find.text('Live controls'), findsOneWidget);
  });
}

  testWidgets('settings screen exposes persistent appearance and behavior controls', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Accent color'), findsOneWidget);
    expect(find.text('Text size'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
  });
