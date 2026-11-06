import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab/app.dart';

void main() {
  testWidgets('home screen exposes the Flutter capability catalog', (tester) async {
    await tester.view.setPhysicalSize(const Size(1200, 1800));
    await tester.view.setDevicePixelRatio(1);
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
  });

  testWidgets('a capability card opens its lab', (tester) async {
    await tester.view.setPhysicalSize(const Size(1200, 1800));
    await tester.view.setDevicePixelRatio(1);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FlutterLabApp());
    await tester.tap(find.text('UI Studio'));
    await tester.pumpAndSettle();

    expect(find.text('Button styles'), findsOneWidget);
    expect(find.text('Live controls'), findsOneWidget);
  });
}
