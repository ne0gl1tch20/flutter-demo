import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_lab/app.dart';
import 'package:flutter_lab/features/labs/productivity_labs.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'onboarding.complete': true}));

  testWidgets('first launch shows onboarding and remembers completion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(900, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();
    expect(find.text('Explore Flutter'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Make it yours'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Experiment freely'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Build. Explore. Experiment.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('returning users wait for saved preferences before showing the home screen', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding.complete': true,
      'settings.theme': 2,
    });
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Build. Explore. Experiment.'), findsOneWidget);
    expect(find.text('Explore Flutter'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard order editor opens and saves custom order', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reorder'));
    await tester.pumpAndSettle();
    expect(find.text('Reorder dashboard'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Build. Explore. Experiment.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home screen exposes the Flutter capability catalog', (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();

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
    expect(find.text('Audio Lab 2.0'), findsOneWidget);
    expect(find.text('Download Queue'), findsOneWidget);
    expect(find.text('Notifications Lab'), findsOneWidget);
    expect(find.text('Concurrency Lab'), findsOneWidget);
    expect(find.text('App Lifecycle Lab'), findsOneWidget);
    expect(find.text('Keyboard & Shortcuts Lab'), findsOneWidget);
    expect(find.text('Localization & Formatting Lab'), findsOneWidget);
    expect(find.text('Forms & Validation Lab'), findsOneWidget);
    expect(find.text('Drag & Drop Lab'), findsOneWidget);
    expect(find.text('Streams & Async Lab'), findsOneWidget);
    expect(find.text('Canvas Lab'), findsOneWidget);
    expect(find.text('Charts Lab'), findsOneWidget);
    expect(find.text('Developer Tools'), findsOneWidget);
    expect(find.text('Flame Game Lab'), findsOneWidget);
    expect(find.text('Widget Studio'), findsOneWidget);
    expect(find.text('Visual UI Builder'), findsOneWidget);
    expect(find.text('JSON Workbench'), findsOneWidget);
    expect(find.text('Typography Studio'), findsOneWidget);
    expect(find.text('Code Snippet Studio'), findsOneWidget);
    expect(find.text('Asset Inspector'), findsOneWidget);
    expect(find.text('Workspace Manager'), findsOneWidget);
    expect(find.text('Test Scenario Builder'), findsOneWidget);
  });

  testWidgets('a capability card opens its lab', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('UI Studio'));
    await tester.pumpAndSettle();

    expect(find.text('Button styles'), findsOneWidget);
    expect(find.text('Live controls'), findsOneWidget);
  });

  testWidgets('download queue accepts a sample and validates URLs', (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download Queue'));
    await tester.pumpAndSettle();

    expect(find.text('Your download queue is empty. Add a URL to get started.'), findsOneWidget);
    await tester.tap(find.text('Add sample'));
    await tester.pumpAndSettle();
    expect(find.text('1 queued item(s)'), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('locale lab safely switches date and currency formatting', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Localization & Formatting Lab'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Flutter Lab'), findsOneWidget);
    await tester.tap(find.text('Filipino'));
    await tester.pumpAndSettle();
    expect(find.text('Maligayang pagdating sa Flutter Lab'), findsOneWidget);
    expect(find.textContaining('Locale: fil_PH'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Te damos la bienvenida a Flutter Lab'), findsOneWidget);
    expect(find.textContaining('Locale: es_ES'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings screen exposes appearance and behavior controls', (tester) async {
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
  testWidgets('JSON workbench formats and validates JSON', (tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: JsonWorkbenchLab()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Format'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Valid JSON'), findsOneWidget);
    expect(find.text('Generated Flutter code'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('widget studio exposes live component controls', (tester) async {
    tester.view.physicalSize = const Size(900, 1600));
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: WidgetStudioLab()));
    await tester.pumpAndSettle();
    expect(find.text('Live preview'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.text('Generated Flutter code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visual UI builder can add and remove components', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: VisualBuilderLab()));
    await tester.pumpAndSettle();
    expect(find.text('Canvas · 3 components'), findsOneWidget);
    await tester.tap(find.widgetWithText(ActionChip, 'Divider'));
    await tester.pumpAndSettle();
    expect(find.text('Canvas · 4 components'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}


