import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AdvancedLabPage extends StatelessWidget {
  const AdvancedLabPage({required this.title, required this.description, required this.child, super.key});
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text(description),
          const SizedBox(height: 20),
          child,
        ]),
      );
}

class AdvancedLabPanel extends StatelessWidget {
  const AdvancedLabPanel({required this.title, required this.child, super.key});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            child,
          ]),
        ),
      );
}

int _countPrimes(int limit) {
  if (limit < 2) return 0;
  final sieve = List<bool>.filled(limit + 1, true);
  sieve[0] = false;
  sieve[1] = false;
  for (var candidate = 2; candidate * candidate <= limit; candidate++) {
    if (!sieve[candidate]) continue;
    for (var multiple = candidate * candidate; multiple <= limit; multiple += candidate) {
      sieve[multiple] = false;
    }
  }
  return sieve.where((value) => value).length;
}

class IsolateLab extends StatefulWidget {
  const IsolateLab({super.key});
  @override
  State<IsolateLab> createState() => _IsolateLabState();
}

class _IsolateLabState extends State<IsolateLab> {
  int _limit = 500000;
  int? _primeCount;
  Duration? _elapsed;
  bool _running = false;

  Future<void> _run() async {
    setState(() { _running = true; _primeCount = null; _elapsed = null; });
    final stopwatch = Stopwatch()..start();
    try {
      final count = await compute(_countPrimes, _limit);
      stopwatch.stop();
      if (!mounted) return;
      setState(() { _primeCount = count; _elapsed = stopwatch.elapsed; });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isolate task failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) => AdvancedLabPage(
        title: 'Concurrency Lab',
        description: 'Dart isolates run CPU-heavy work away from the UI isolate. Count prime numbers while the interface stays responsive.',
        child: AdvancedLabPanel(
          title: 'Prime number workload',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Search limit: ${NumberFormat.decimalPattern().format(_limit)}'),
            Slider(
              value: _limit.toDouble(), min: 100000, max: 1500000, divisions: 14,
              onChanged: _running ? null : (value) => setState(() => _limit = value.round()),
            ),
            FilledButton.icon(
              onPressed: _running ? null : _run,
              icon: _running
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_running ? 'Working on background isolate…' : 'Run isolate task'),
            ),
            const SizedBox(height: 14),
            if (_primeCount != null) ...[
              Text(NumberFormat.decimalPattern().format(_primeCount), style: Theme.of(context).textTheme.headlineMedium),
              const Text('Prime numbers found'),
              const SizedBox(height: 4),
              Text('Round trip: ${_elapsed!.inMilliseconds} ms'),
            ] else
              const Text('Run the task to see its result and elapsed time.'),
          ]),
        ),
      );
}

class LifecycleLab extends StatefulWidget {
  const LifecycleLab({super.key});
  @override
  State<LifecycleLab> createState() => _LifecycleLabState();
}

class _LifecycleLabState extends State<LifecycleLab> with WidgetsBindingObserver {
  AppLifecycleState? _state;
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _state = WidgetsBinding.instance.lifecycleState;
    _record('Lab opened');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() { _state = state; _record(state.name); });
  }

  void _record(String event) {
    _events.insert(0, '${DateTime.now().toLocal().toString().substring(11, 19)}  $event');
    if (_events.length > 8) _events.removeLast();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AdvancedLabPage(
        title: 'App Lifecycle Lab',
        description: 'Flutter reports when an app is resumed, inactive, hidden, paused or detached. Try leaving this screen and returning.',
        child: AdvancedLabPanel(
          title: 'Lifecycle observer',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Current state'),
              const Spacer(),
              Chip(avatar: const Icon(Icons.circle, size: 10), label: Text(_state?.name ?? 'Unknown')),
            ]),
            const SizedBox(height: 8),
            const Text('Recent events'),
            const SizedBox(height: 8),
            for (final event in _events)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(event, style: Theme.of(context).textTheme.bodySmall),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() { _events.clear(); _record('History cleared'); }),
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Clear history'),
            ),
          ]),
        ),
      );
}

class _CounterIntent extends Intent {
  const _CounterIntent(this.delta);
  final int delta;
}

class _ResetCounterIntent extends Intent {
  const _ResetCounterIntent();
}

class KeyboardLab extends StatefulWidget {
  const KeyboardLab({super.key});
  @override
  State<KeyboardLab> createState() => _KeyboardLabState();
}

class _KeyboardLabState extends State<KeyboardLab> {
  int _count = 0;
  String _lastAction = 'Click the panel, then use your keyboard.';

  @override
  Widget build(BuildContext context) => AdvancedLabPage(
        title: 'Keyboard & Shortcuts Lab',
        description: 'Shortcuts and Actions make Flutter interfaces work with hardware keyboards on desktop and supported mobile devices.',
        child: AdvancedLabPanel(
          title: 'Keyboard-controlled counter',
          child: Shortcuts(
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.arrowUp): _CounterIntent(1),
              SingleActivator(LogicalKeyboardKey.arrowDown): _CounterIntent(-1),
              SingleActivator(LogicalKeyboardKey.keyK, control: true): _ResetCounterIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _CounterIntent: CallbackAction<_CounterIntent>(onInvoke: (intent) {
                  setState(() { _count += intent.delta; _lastAction = intent.delta > 0 ? 'Arrow Up' : 'Arrow Down'; });
                  return null;
                }),
                _ResetCounterIntent: CallbackAction<_ResetCounterIntent>(onInvoke: (_) {
                  setState(() { _count = 0; _lastAction = 'Ctrl + K'; });
                  return null;
                }),
              },
              child: Focus(
                autofocus: true,
                child: Builder(builder: (context) => GestureDetector(
                  onTap: () => Focus.of(context).requestFocus(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(children: [
                      Text('$_count', style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 8),
                      Text(_lastAction),
                      const SizedBox(height: 14),
                      const Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
                        _ShortcutHint(label: '↑', detail: 'Increase'),
                        _ShortcutHint(label: '↓', detail: 'Decrease'),
                        _ShortcutHint(label: 'Ctrl + K', detail: 'Reset'),
                      ]),
                      const SizedBox(height: 10),
                      const Text('Tap this panel to focus it.'),
                    ]),
                  ),
                )),
              ),
            ),
          ),
        ),
      );
}

class _ShortcutHint extends StatelessWidget {
  const _ShortcutHint({required this.label, required this.detail});
  final String label;
  final String detail;
  @override
  Widget build(BuildContext context) => Chip(
        label: Text('$label  $detail'),
        visualDensity: VisualDensity.compact,
      );
}

class LocalizationLab extends StatefulWidget {
  const LocalizationLab({super.key});
  @override
  State<LocalizationLab> createState() => _LocalizationLabState();
}

class _LocalizationLabState extends State<LocalizationLab> {
  String _locale = 'en_US';
  static const _copy = {
    'en_US': {'title': 'Welcome to Flutter Lab', 'message': 'One interface, many languages.', 'today': 'Today', 'price': 'Sample price'},
    'fil_PH': {'title': 'Maligayang pagdating sa Flutter Lab', 'message': 'Isang interface, maraming wika.', 'today': 'Ngayon', 'price': 'Halimbawang presyo'},
    'es_ES': {'title': 'Te damos la bienvenida a Flutter Lab', 'message': 'Una interfaz, muchos idiomas.', 'today': 'Hoy', 'price': 'Precio de ejemplo'},
  };

  @override
  Widget build(BuildContext context) {
    final copy = _copy[_locale]!;
    final date = DateFormat.yMMMMEEEEd(_locale).format(DateTime.now());
    final price = NumberFormat.currency(locale: _locale, name: 'PHP', symbol: '₱').format(1299.50);
    return AdvancedLabPage(
      title: 'Localization & Formatting Lab',
      description: 'Localization is more than translating labels. Date, number and currency formats also change with the selected locale.',
      child: AdvancedLabPanel(
        title: 'Locale preview',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en_US', label: Text('English')),
              ButtonSegment(value: 'fil_PH', label: Text('Filipino')),
              ButtonSegment(value: 'es_ES', label: Text('Español')),
            ],
            selected: {_locale},
            onSelectionChanged: (value) => setState(() => _locale = value.first),
          ),
          const SizedBox(height: 18),
          Text(copy['title']!, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(copy['message']!),
          const Divider(height: 28),
          Text('${copy['today']}: $date'),
          const SizedBox(height: 6),
          Text('${copy['price']}: $price'),
          const SizedBox(height: 10),
          Text('Locale: $_locale', style: Theme.of(context).textTheme.labelMedium),
        ]),
      ),
    );
  }
}
