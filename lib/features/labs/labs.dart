import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'advanced_labs.dart';
import 'flame_lab.dart';
import 'platform_labs.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabDefinition {
  const LabDefinition({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

final labCatalog = <LabDefinition>[
  LabDefinition(title: 'UI Studio', description: 'Material 3, controls, themes and component states.', category: 'UI', icon: Icons.widgets_rounded, color: const Color(0xFF9B8CFF), builder: (_) => const UiLab()),
  LabDefinition(title: 'Animation Studio', description: 'Implicit motion, controllers, curves and transitions.', category: 'Animation', icon: Icons.animation_rounded, color: const Color(0xFFFF9C70), builder: (_) => const AnimationLab()),
  LabDefinition(title: 'Gesture Lab', description: 'Tap, drag, long-press, scale and pointer input.', category: 'Interaction', icon: Icons.touch_app_rounded, color: const Color(0xFF75E0C1), builder: (_) => const GestureLab()),
  LabDefinition(title: 'Graphics Lab', description: 'Canvas, CustomPainter, paths and gradients.', category: 'Graphics', icon: Icons.palette_rounded, color: const Color(0xFFFF82AD), builder: (_) => const GraphicsLab()),
  LabDefinition(title: 'Adaptive Layout', description: 'Responsive grids, constraints and breakpoints.', category: 'Layout', icon: Icons.devices_rounded, color: const Color(0xFF73B7FF), builder: (_) => const LayoutLab()),
  LabDefinition(title: 'Navigation Lab', description: 'Routes, dialogs, sheets and nested navigation.', category: 'Navigation', icon: Icons.account_tree_rounded, color: const Color(0xFFFFC66D), builder: (_) => const NavigationLab()),
  LabDefinition(title: 'State Lab', description: 'setState, ValueNotifier and streams in action.', category: 'State', icon: Icons.hub_rounded, color: const Color(0xFF7ED6E8), builder: (_) => const StateLab()),
  LabDefinition(title: 'Storage Lab', description: 'Persist preferences and export a JSON file.', category: 'Storage', icon: Icons.save_rounded, color: const Color(0xFFB9A1FF), builder: (_) => const StorageLab()),
  LabDefinition(title: 'Device Lab', description: 'Read device details and live motion sensors.', category: 'Platform', icon: Icons.sensors_rounded, color: const Color(0xFF80D6A8), builder: (_) => const DeviceLab()),
  LabDefinition(title: 'Network Lab', description: 'Make an HTTP request and inspect decoded JSON.', category: 'Networking', icon: Icons.wifi_rounded, color: const Color(0xFF7EB8FF), builder: (_) => const NetworkLab()),
  LabDefinition(title: 'Accessibility Lab', description: 'Semantics, scalable text and accessible controls.', category: 'Accessibility', icon: Icons.accessibility_new_rounded, color: const Color(0xFFFFA7C8), builder: (_) => const AccessibilityLab()),
  LabDefinition(title: 'Performance Lab', description: 'Rebuild counters, repaint boundaries and frame budgets.', category: 'Performance', icon: Icons.speed_rounded, color: const Color(0xFFFFD166), builder: (_) => const PerformanceLab()),
  LabDefinition(title: 'Platform Tools', description: 'Camera, gallery, files, sharing, clipboard and haptics.', category: 'Platform', icon: Icons.phone_android_rounded, color: const Color(0xFF8ED7B2), builder: (_) => const PlatformExtrasLab()),
  LabDefinition(title: 'Audio Lab', description: 'Play and control audio using a Flutter plugin.', category: 'Media', icon: Icons.graphic_eq_rounded, color: const Color(0xFFFFA875), builder: (_) => const AudioLab()),
  LabDefinition(title: 'Notifications Lab', description: 'Request permission and send local Android notifications.', category: 'Platform', icon: Icons.notifications_active_rounded, color: const Color(0xFFFFD166), builder: (_) => const NotificationsLab()),
  LabDefinition(title: 'Concurrency Lab', description: 'Run CPU-heavy work on a background Dart isolate.', category: 'Performance', icon: Icons.memory_rounded, color: const Color(0xFF7EB8FF), builder: (_) => const IsolateLab()),
  LabDefinition(title: 'App Lifecycle Lab', description: 'Observe app pause, resume and lifecycle events.', category: 'Platform', icon: Icons.sync_rounded, color: const Color(0xFF80D6A8), builder: (_) => const LifecycleLab()),
  LabDefinition(title: 'Keyboard & Shortcuts Lab', description: 'Handle hardware keyboard input and custom shortcuts.', category: 'Desktop', icon: Icons.keyboard_rounded, color: const Color(0xFFFFC66D), builder: (_) => const KeyboardLab()),
  LabDefinition(title: 'Localization & Formatting Lab', description: 'Switch languages and format dates and Philippine peso values.', category: 'Internationalization', icon: Icons.translate_rounded, color: const Color(0xFFFFA7C8), builder: (_) => const LocalizationLab()),
  LabDefinition(title: 'Forms & Validation Lab', description: 'Build forms with input types, validation and focus handling.', category: 'Input', icon: Icons.assignment_rounded, color: const Color(0xFF9B8CFF), builder: (_) => const FormsLab()),
  LabDefinition(title: 'Drag & Drop Lab', description: 'Reorder lists and move draggable widgets into drop targets.', category: 'Interaction', icon: Icons.open_with_rounded, color: const Color(0xFF75E0C1), builder: (_) => const DragDropLab()),
  LabDefinition(title: 'Streams & Async Lab', description: 'Receive asynchronous events and render them with StreamBuilder.', category: 'State', icon: Icons.stream_rounded, color: const Color(0xFF7EB8FF), builder: (_) => const StreamsLab()),
  LabDefinition(title: 'Flame Game Lab', description: 'A complete 2D platformer with physics, camera, collisions, enemies and touch controls.', category: 'Game Development', icon: Icons.sports_esports_rounded, color: const Color(0xFFFFD166), builder: (_) => const FlamePlatformerLab()),
];

class LabPage extends StatelessWidget {
  const LabPage({required this.title, required this.description, required this.child, super.key});
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      );
}

class LabCardPanel extends StatelessWidget {
  const LabCardPanel({required this.title, required this.child, super.key});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            child,
          ]),
        ),
      );
}

class UiLab extends StatefulWidget {
  const UiLab({super.key});
  @override
  State<UiLab> createState() => _UiLabState();
}

class _UiLabState extends State<UiLab> {
  bool switchValue = true;
  double sliderValue = .45;
  String selected = 'Filled';

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'UI Studio',
        description: 'Explore Material 3 components and see how they respond to state.',
        child: Column(children: [
          LabCardPanel(title: 'Button styles', child: Wrap(spacing: 10, runSpacing: 10, children: [
            FilledButton(onPressed: () => _message('Filled button tapped'), child: const Text('Filled')),
            OutlinedButton(onPressed: () => _message('Outlined button tapped'), child: const Text('Outlined')),
            TextButton(onPressed: () => _message('Text button tapped'), child: const Text('Text')),
            IconButton.filledTonal(onPressed: () => _message('Icon button tapped'), icon: const Icon(Icons.favorite)),
          ])),
          const SizedBox(height: 12),
          LabCardPanel(title: 'Live controls', child: Column(children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Enable controls'), value: switchValue, onChanged: (value) => setState(() => switchValue = value)),
            Slider(value: sliderValue, onChanged: switchValue ? (value) => setState(() => sliderValue = value) : null),
            Align(alignment: Alignment.centerLeft, child: Text('Value: ${(sliderValue * 100).round()}%')),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Filled', label: Text('Filled')),
                ButtonSegment(value: 'Tonal', label: Text('Tonal')),
                ButtonSegment(value: 'Outlined', label: Text('Outlined')),
              ],
              selected: {selected},
              onSelectionChanged: (value) => setState(() => selected = value.first),
            ),
          ])),
        ]),
      );

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class AnimationLab extends StatefulWidget {
  const AnimationLab({super.key});
  @override
  State<AnimationLab> createState() => _AnimationLabState();
}

class _AnimationLabState extends State<AnimationLab> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  late final Animation<double> scale = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
  bool expanded = false;

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Animation Studio',
        description: 'Flutter supports implicit animations for simple changes and explicit controllers for fully controlled motion.',
        child: Column(children: [
          LabCardPanel(title: 'Explicit animation controller', child: Column(children: [
            SizedBox(height: 190, child: Center(child: AnimatedBuilder(animation: scale, builder: (_, child) => Transform.scale(scale: .65 + scale.value * .65, child: child), child: const Icon(Icons.flutter_dash, size: 100, color: Color(0xFF9B8CFF))))),
            Row(children: [
              Expanded(child: FilledButton.tonal(onPressed: controller.forward, child: const Text('Forward'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: controller.reverse, child: const Text('Reverse'))),
              const SizedBox(width: 8),
              IconButton(onPressed: () => controller.repeat(reverse: true), icon: const Icon(Icons.repeat)),
            ]),
          ])),
          const SizedBox(height: 12),
          LabCardPanel(title: 'Implicit animation', child: Column(children: [
            Center(child: AnimatedContainer(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutBack, width: expanded ? 190 : 90, height: expanded ? 120 : 90, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9B8CFF), Color(0xFF75E0C1)]), borderRadius: BorderRadius.circular(expanded ? 28 : 60)))),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => setState(() => expanded = !expanded), child: const Text('Animate size and shape')),
          ])),
        ]),
      );
}

class GestureLab extends StatefulWidget {
  const GestureLab({super.key});
  @override
  State<GestureLab> createState() => _GestureLabState();
}

class _GestureLabState extends State<GestureLab> {
  Offset offset = Offset.zero;
  double scale = 1;
  int taps = 0;
  int longPresses = 0;

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Gesture Lab',
        description: 'Try dragging the tile, tapping it, long-pressing it and pinching to scale.',
        child: LabCardPanel(title: 'Gesture detector playground', child: Column(children: [
          SizedBox(
            height: 300,
            child: LayoutBuilder(builder: (context, constraints) => Stack(children: [
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)))),
              Positioned(
                left: (constraints.maxWidth - 76) / 2 + offset.dx,
                top: 112 + offset.dy,
                child: GestureDetector(
                  onTap: () => setState(() => taps++),
                  onLongPress: () => setState(() => longPresses++),
                  onScaleUpdate: (details) => setState(() {
                    scale = details.scale.clamp(.65, 1.8).toDouble();
                    offset = Offset(
                      (offset.dx + details.focalPointDelta.dx).clamp(-constraints.maxWidth / 2 + 38, constraints.maxWidth / 2 - 38).toDouble(),
                      (offset.dy + details.focalPointDelta.dy).clamp(-105, 105).toDouble(),
                    );
                  }),
                  child: Transform.scale(scale: scale, child: Container(width: 76, height: 76, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9B8CFF), Color(0xFF75E0C1)]), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.open_with, color: Color(0xFF101426)))),
                ),
              ),
            ])),
          ),
          const SizedBox(height: 12),
          Text('Taps: $taps  •  Long presses: $longPresses  •  Scale: ${scale.toStringAsFixed(2)}×'),
          TextButton(onPressed: () => setState(() { offset = Offset.zero; scale = 1; taps = 0; longPresses = 0; }), child: const Text('Reset')),
        ])),
      );
}

class GraphicsLab extends StatefulWidget {
  const GraphicsLab({super.key});
  @override
  State<GraphicsLab> createState() => _GraphicsLabState();
}

class _GraphicsLabState extends State<GraphicsLab> {
  double hue = 265;
  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Graphics Lab',
        description: 'CustomPainter gives direct access to Flutter’s canvas, paths, shaders and drawing primitives.',
        child: LabCardPanel(title: 'CustomPainter canvas', child: Column(children: [
          SizedBox(height: 270, width: double.infinity, child: ClipRRect(borderRadius: BorderRadius.circular(18), child: CustomPaint(painter: _OrbPainter(hue)))),
          const SizedBox(height: 12),
          Slider(value: hue, min: 0, max: 360, onChanged: (value) => setState(() => hue = value)),
          Text('Hue: ${hue.round()}°'),
        ])),
      );
}

class _OrbPainter extends CustomPainter {
  _OrbPainter(this.hue);
  final double hue;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(colors: [Color(0xFF211C43), Color(0xFF102E38)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(rect));
    final center = Offset(size.width / 2, size.height / 2);
    final color = HSVColor.fromAHSV(1, hue, .62, 1).toColor();
    for (var i = 4; i >= 0; i--) {
      final radius = 28.0 + i * 19;
      canvas.drawCircle(center + Offset(math.cos(i * .8) * 25, math.sin(i * .8) * 17), radius, Paint()..color = color.withValues(alpha: .07 + i * .025)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
    canvas.drawCircle(center, 55, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: .95), color, const Color(0xFF28204F)]).createShader(Rect.fromCircle(center: center, radius: 55)));
    canvas.drawCircle(center.translate(-17, -19), 9, Paint()..color = Colors.white.withValues(alpha: .65));
  }
  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => oldDelegate.hue != hue;
}

class LayoutLab extends StatefulWidget {
  const LayoutLab({super.key});
  @override
  State<LayoutLab> createState() => _LayoutLabState();
}

class _LayoutLabState extends State<LayoutLab> {
  int columns = 2;
  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Adaptive Layout',
        description: 'Flutter layouts respond to available constraints. Resize the window or change the grid below.',
        child: Column(children: [
          LabCardPanel(title: 'LayoutBuilder', child: LayoutBuilder(builder: (context, constraints) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Available width: ${constraints.maxWidth.toStringAsFixed(0)} logical pixels'),
            Text('Screen width: ${MediaQuery.sizeOf(context).width.toStringAsFixed(0)} logical pixels'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: List.generate(6, (index) => Container(width: (constraints.maxWidth - 16) / 3, height: 66, alignment: Alignment.center, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Text('Tile ${index + 1}')))),
          ]))),
          const SizedBox(height: 12),
          LabCardPanel(title: 'Grid configuration', child: Column(children: [
            SegmentedButton<int>(segments: const [ButtonSegment(value: 1, label: Text('1 col')), ButtonSegment(value: 2, label: Text('2 col')), ButtonSegment(value: 3, label: Text('3 col'))], selected: {columns}, onSelectionChanged: (value) => setState(() => columns = value.first)),
            const SizedBox(height: 12),
            GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: columns, crossAxisSpacing: 8, mainAxisSpacing: 8, children: List.generate(6, (i) => Container(alignment: Alignment.center, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)), child: Text('Card ${i + 1}')))),
          ])),
        ]),
      );
}

class NavigationLab extends StatefulWidget {
  const NavigationLab({super.key});
  @override
  State<NavigationLab> createState() => _NavigationLabState();
}

class _NavigationLabState extends State<NavigationLab> {
  int page = 0;
  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Navigation Lab',
        description: 'Flutter navigation can use routes, page transitions, dialogs, bottom sheets and nested flows.',
        child: LabCardPanel(title: 'Nested page navigator', child: Column(children: [
          SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('One')), ButtonSegment(value: 1, label: Text('Two')), ButtonSegment(value: 2, label: Text('Three'))], selected: {page}, onSelectionChanged: (value) => setState(() => page = value.first)),
          const SizedBox(height: 18),
          Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: Column(children: [Icon([Icons.looks_one, Icons.looks_two, Icons.looks_3][page], size: 48), const SizedBox(height: 8), Text('Page ${page + 1}', style: Theme.of(context).textTheme.headlineSmall)])),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            OutlinedButton(onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Dialog route'), content: const Text('Dialogs are routes too.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), child: const Text('Show dialog')),
            FilledButton.tonal(onPressed: () => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => const Padding(padding: EdgeInsets.all(28), child: Text('A modal bottom sheet.'))), child: const Text('Bottom sheet')),
          ]),
        ])),
      );
}

class StateLab extends StatefulWidget {
  const StateLab({super.key});
  @override
  State<StateLab> createState() => _StateLabState();
}

class _StateLabState extends State<StateLab> {
  final ValueNotifier<int> counter = ValueNotifier<int>(0);
  final StreamController<int> stream = StreamController<int>.broadcast();
  int streamValue = 0;
  StreamSubscription<int>? subscription;

  @override
  void initState() {
    super.initState();
    subscription = stream.stream.listen((value) => setState(() => streamValue = value));
  }

  @override
  void dispose() {
    subscription?.cancel();
    stream.close();
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'State Lab',
        description: 'Compare widget-local setState, ValueNotifier and StreamController updates.',
        child: Column(children: [
          LabCardPanel(title: 'ValueNotifier', child: ValueListenableBuilder<int>(valueListenable: counter, builder: (_, value, __) => Row(children: [
            Expanded(child: Text('Counter: $value', style: Theme.of(context).textTheme.titleLarge)),
            IconButton.filledTonal(onPressed: () => counter.value--, icon: const Icon(Icons.remove)),
            IconButton.filled(onPressed: () => counter.value++, icon: const Icon(Icons.add)),
          ]))),
          const SizedBox(height: 12),
          LabCardPanel(title: 'StreamController', child: Row(children: [
            Expanded(child: Text('Latest event: $streamValue')),
            FilledButton.tonal(onPressed: () => stream.add(streamValue + 1), child: const Text('Emit event')),
          ])),
        ]),
      );
}

class StorageLab extends StatefulWidget {
  const StorageLab({super.key});
  @override
  State<StorageLab> createState() => _StorageLabState();
}

class _StorageLabState extends State<StorageLab> {
  final TextEditingController noteController = TextEditingController();
  String savedNote = 'Nothing saved yet';
  String? exportedPath;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('showcase_note') ?? '';
    if (!mounted) return;
    setState(() { savedNote = value.isEmpty ? 'Nothing saved yet' : value; noteController.text = value; });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('showcase_note', noteController.text);
    if (!mounted) return;
    setState(() => savedNote = noteController.text.isEmpty ? 'Nothing saved yet' : noteController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved on this device.')));
  }

  Future<void> _export() async {
    setState(() => loading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/flutter_lab_export.json');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert({'app': 'Flutter Lab', 'note': noteController.text, 'exportedAt': DateTime.now().toIso8601String()}));
      if (!mounted) return;
      setState(() => exportedPath = file.path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Storage Lab',
        description: 'This lab writes a preference to persistent app storage and exports a JSON file to the app documents directory.',
        child: LabCardPanel(title: 'Local data', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: noteController, decoration: const InputDecoration(labelText: 'A note to remember', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            FilledButton(onPressed: _save, child: const Text('Save preference')),
            OutlinedButton(onPressed: _load, child: const Text('Reload')),
            OutlinedButton(onPressed: loading ? null : _export, child: Text(loading ? 'Exporting…' : 'Export JSON')),
          ]),
          const SizedBox(height: 12),
          Text('Saved value: $savedNote'),
          if (exportedPath != null) ...[
            const SizedBox(height: 8),
            SelectableText('Exported to: $exportedPath'),
            TextButton.icon(onPressed: () => Clipboard.setData(ClipboardData(text: exportedPath!)), icon: const Icon(Icons.copy), label: const Text('Copy file path')),
          ],
        ])),
      );
}

class DeviceLab extends StatefulWidget {
  const DeviceLab({super.key});
  @override
  State<DeviceLab> createState() => _DeviceLabState();
}

class _DeviceLabState extends State<DeviceLab> {
  String deviceDetails = 'Tap below to inspect this device.';
  String sensorStatus = 'Sensor stream is idle.';
  StreamSubscription<AccelerometerEvent>? sensorSubscription;
  AccelerometerEvent? latest;

  @override
  void dispose() {
    sensorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _readDevice() async {
    final plugin = DeviceInfoPlugin();
    String details;
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      details = 'Android ${info.version.release} (SDK ${info.version.sdkInt})\n${info.manufacturer} ${info.model}\nDevice: ${info.device}';
    } else if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      details = '${info.productName}\nVersion: ${info.displayVersion}\nBuild: ${info.buildNumber}\nComputer: ${info.computerName}';
    } else if (Platform.isLinux) {
      final info = await plugin.linuxInfo;
      details = '${info.prettyName}\nVersion: ${info.version ?? 'unknown'}';
    } else if (Platform.isMacOS) {
      final info = await plugin.macOsInfo;
      details = '${info.computerName}\nVersion: ${info.osRelease}';
    } else {
      details = 'Platform: ${Platform.operatingSystem}';
    }
    if (mounted) setState(() => deviceDetails = details);
  }

  void _toggleSensor() {
    if (sensorSubscription != null) {
      sensorSubscription?.cancel();
      sensorSubscription = null;
      setState(() => sensorStatus = 'Sensor stream stopped.');
      return;
    }
    sensorSubscription = accelerometerEventStream().listen(
      (event) {
        if (mounted) setState(() { latest = event; sensorStatus = 'Receiving accelerometer events.'; });
      },
      onError: (Object error) {
        if (mounted) setState(() => sensorStatus = 'Sensor unavailable: $error');
      },
    );
    setState(() => sensorStatus = 'Waiting for sensor data…');
  }

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Device Lab',
        description: 'Plugins can bridge Flutter to native Android and Windows APIs. This lab reads platform information and listens to accelerometer events where supported.',
        child: Column(children: [
          LabCardPanel(title: 'Platform information', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SelectableText(deviceDetails),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: _readDevice, child: const Text('Read device information')),
          ])),
          const SizedBox(height: 12),
          LabCardPanel(title: 'Accelerometer', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sensorStatus),
            const SizedBox(height: 8),
            Text(latest == null ? 'X: —    Y: —    Z: —' : 'X: ${latest!.x.toStringAsFixed(2)}    Y: ${latest!.y.toStringAsFixed(2)}    Z: ${latest!.z.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _toggleSensor, child: Text(sensorSubscription == null ? 'Start sensor' : 'Stop sensor')),
          ])),
        ]),
      );
}

class NetworkLab extends StatefulWidget {
  const NetworkLab({super.key});
  @override
  State<NetworkLab> createState() => _NetworkLabState();
}

class _NetworkLabState extends State<NetworkLab> {
  bool loading = false;
  String result = 'No request yet.';
  int? statusCode;

  Future<void> _request() async {
    setState(() { loading = true; result = 'Connecting…'; statusCode = null; });
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final request = await client.getUrl(Uri.https('jsonplaceholder.typicode.com', '/todos/1'));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (!mounted) return;
      setState(() { statusCode = response.statusCode; result = const JsonEncoder.withIndent('  ').convert(decoded); });
    } catch (error) {
      if (mounted) setState(() => result = 'Request failed: $error');
    } finally {
      client?.close(force: true);
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Network Lab',
        description: 'A real HTTPS request using Dart HttpClient, followed by JSON decoding. Internet access is required.',
        child: LabCardPanel(title: 'GET /todos/1', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            FilledButton(onPressed: loading ? null : _request, child: Text(loading ? 'Loading…' : 'Send request')),
            if (statusCode != null) Chip(label: Text('HTTP $statusCode')),
          ]),
          const SizedBox(height: 12),
          SelectableText(result, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ])),
      );
}

class AccessibilityLab extends StatefulWidget {
  const AccessibilityLab({super.key});
  @override
  State<AccessibilityLab> createState() => _AccessibilityLabState();
}

class _AccessibilityLabState extends State<AccessibilityLab> {
  double textScale = 1;
  bool highContrast = false;
  @override
  Widget build(BuildContext context) => LabPage(
        title: 'Accessibility Lab',
        description: 'Flutter provides Semantics for assistive technology and supports text scaling, keyboard focus and accessible hit targets.',
        child: LabCardPanel(title: 'Accessible controls', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Semantics(label: 'Decorative Flutter logo', image: true, child: const Icon(Icons.flutter_dash, size: 54)),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: Text('Preview text size')),
            Text('${textScale.toStringAsFixed(1)}×'),
          ]),
          Slider(value: textScale, min: 1, max: 2, divisions: 10, onChanged: (value) => setState(() => textScale = value)),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: highContrast ? Colors.black : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: highContrast ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
              child: Text('Readable text should remain comfortable at larger sizes.', style: TextStyle(color: highContrast ? Colors.white : null)),
            ),
          ),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('High contrast preview'), value: highContrast, onChanged: (value) => setState(() => highContrast = value)),
          Semantics(
            button: true,
            label: 'Accessible sample action',
            hint: 'Activates a sample feedback message',
            child: FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accessible action activated'))), icon: const Icon(Icons.check), label: const Text('Accessible action')),
          ),
        ])),
      );
}

class PerformanceLab extends StatefulWidget {
  const PerformanceLab({super.key});
  @override
  State<PerformanceLab> createState() => _PerformanceLabState();
}

class _PerformanceLabState extends State<PerformanceLab> {
  int rebuilds = 0;
  int count = 120;
  bool animate = true;
  @override
  Widget build(BuildContext context) {
    rebuilds++;
    return LabPage(
      title: 'Performance Lab',
      description: 'This lab demonstrates rebuilds and RepaintBoundary. Use Flutter DevTools on a debug build for frame charts, memory, CPU profiling and widget inspection.',
      child: Column(children: [
        LabCardPanel(title: 'Widget rebuild counter', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('This page has rebuilt $rebuilds times.'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            FilledButton.tonal(onPressed: () => setState(() => count += 20), child: const Text('Add items')),
            OutlinedButton(onPressed: () => setState(() { count = 120; rebuilds = 0; }), child: const Text('Reset')),
          ]),
        ])),
        const SizedBox(height: 12),
        LabCardPanel(title: 'Isolated repaint area', child: Column(children: [
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Animate particles'), value: animate, onChanged: (value) => setState(() => animate = value)),
          RepaintBoundary(child: SizedBox(height: 180, child: _ParticleField(count: count, animate: animate))),
          Text('$count rendered particles'),
        ])),
      ]),
    );
  }
}

class _ParticleField extends StatefulWidget {
  const _ParticleField({required this.count, required this.animate});
  final int count;
  final bool animate;
  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<_ParticleField> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: const Duration(seconds: 8));
  @override
  void initState() { super.initState(); controller.repeat(); }
  @override
  void didUpdateWidget(covariant _ParticleField oldWidget) { super.didUpdateWidget(oldWidget); if (widget.animate && !controller.isAnimating) controller.repeat(); if (!widget.animate && controller.isAnimating) controller.stop(); }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (_, __) => CustomPaint(
          painter: _ParticlePainter(widget.count, controller.value),
          child: const SizedBox.expand(),
        ),
      );
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.count, this.phase);
  final int count;
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = const Color(0xFF9B8CFF).withValues(alpha: .75);
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + phase * 70 + i * 3) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5 + random.nextDouble() * 2.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.phase != phase || oldDelegate.count != count;
}
