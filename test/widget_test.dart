import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/main.dart';

void main() {
  testWidgets('home screen shows all five showcase labs', (tester) async {
    await tester.pumpWidget(const FlutterDemoApp());

    expect(find.text('Explore the details.'), findsOneWidget);
    expect(find.text('Animation Studio'), findsOneWidget);
    expect(find.text('Gesture Playground'), findsOneWidget);
    expect(find.text('UI Showcase'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Physics Lab'), 300);
    expect(find.text('Physics Lab'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Custom Graphics'), 300);
    expect(find.text('Custom Graphics'), findsOneWidget);
  });
}
