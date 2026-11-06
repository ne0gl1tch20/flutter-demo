import 'package:flutter/material.dart';

import 'features/labs/labs.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterLabApp extends StatefulWidget {
  const FlutterLabApp({super.key});

  @override
  State<FlutterLabApp> createState() => _FlutterLabAppState();
}

class _FlutterLabAppState extends State<FlutterLabApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _cycleTheme() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.light,
        ThemeMode.light => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF806BFF);
    return MaterialApp(
      title: 'Flutter Lab',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: const Color(0xFF111827),
        ),
        scaffoldBackgroundColor: const Color(0xFF090D18),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeShell(
        themeMode: _themeMode,
        onThemePressed: _cycleTheme,
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.themeMode,
    required this.onThemePressed,
    super.key,
  });

  final ThemeMode themeMode;
  final VoidCallback onThemePressed;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _destination = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Explore',
      ),
      const NavigationDestination(
        icon: Icon(Icons.info_outline),
        selectedIcon: Icon(Icons.info),
        label: 'About',
      ),
    ];

    final content = _destination == 0 ? _buildExplore(context) : _buildAbout();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: Color(0xFF9B8CFF)),
            SizedBox(width: 9),
            Text('Flutter Lab', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cycle theme: system, dark, light',
            onPressed: widget.onThemePressed,
            icon: Icon(switch (widget.themeMode) {
              ThemeMode.system => Icons.brightness_auto,
              ThemeMode.dark => Icons.dark_mode,
              ThemeMode.light => Icons.light_mode,
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _destination,
                  onDestinationSelected: (value) =>
                      setState(() => _destination = value),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: Text('Explore'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(Icons.info),
                      label: Text('About'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _destination,
              onDestinationSelected: (value) =>
                  setState(() => _destination = value),
              destinations: destinations,
            ),
    );
  }

  Widget _buildExplore(BuildContext context) {
    final labs = labCatalog
        .where((lab) =>
            lab.title.toLowerCase().contains(_query.toLowerCase()) ||
            lab.description.toLowerCase().contains(_query.toLowerCase()) ||
            lab.category.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build. Explore. Experiment.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.1,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A hands-on playground for Flutter UI, animation, graphics, '
                  'state, storage and real platform integrations.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search capabilities',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () => setState(() => _query = ''),
                            icon: const Icon(Icons.close),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'CAPABILITY LABS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${labs.length} labs',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (labs.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No labs match that search.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 420,
                mainAxisExtent: 174,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => LabCard(lab: labs[index]),
                childCount: labs.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAbout() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          Icons.flutter_dash,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 18),
        Text(
          'Flutter, hands-on.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Flutter Lab is an interactive collection of experiments built to '
          'explore what Flutter can do across Android and Windows. Each lab '
          'is designed to be touched, changed and tested.',
        ),
        const SizedBox(height: 24),
        const ListTile(
          leading: Icon(Icons.phone_android),
          title: Text('Android'),
          subtitle: Text('Native device information, sensors and app storage.'),
        ),
        const ListTile(
          leading: Icon(Icons.desktop_windows),
          title: Text('Windows'),
          subtitle: Text('Adaptive layouts, desktop navigation and window sizing.'),
        ),
        const ListTile(
          leading: Icon(Icons.code),
          title: Text('Built with Flutter'),
          subtitle: Text('Material 3, Dart, plugins and custom rendering.'),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => launchUrl(Uri.https('docs.flutter.dev', '')),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Explore Flutter documentation'),
        ),
      ],
    );
  }
}

class LabCard extends StatelessWidget {
  const LabCard({required this.lab, super.key});

  final LabDefinition lab;

  @override
  Widget build(BuildContext context) {
    final color = lab.color;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (_, animation, secondaryAnimation) =>
                lab.builder(context),
            transitionsBuilder: (_, animation, secondaryAnimation, child) =>
                FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.025, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(lab.icon, color: color),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 19,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                lab.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                lab.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
