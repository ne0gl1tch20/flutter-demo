import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'features/labs/labs.dart';

String? get _platformFontFamily => switch (defaultTargetPlatform) {
  TargetPlatform.android => 'sans-serif',
  TargetPlatform.windows => 'Segoe UI',
  _ => null,
};

const _accentColors = <Color>[
  Color(0xFF806BFF), Color(0xFF21B891), Color(0xFF3498DB),
  Color(0xFFFF8A50), Color(0xFFE85D9E), Color(0xFFDAA520),
];

class FlutterLabApp extends StatefulWidget {
  const FlutterLabApp({super.key});
  @override
  State<FlutterLabApp> createState() => _FlutterLabAppState();
}

class _FlutterLabAppState extends State<FlutterLabApp> {
  ThemeMode _themeMode = ThemeMode.system;
  int _accentIndex = 0;
  double _textScale = 1;
  bool _animations = true;
  bool _haptics = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _themeMode = ThemeMode.values[(prefs.getInt('settings.theme') ?? 0).clamp(0, 2).toInt()];
      _accentIndex = (prefs.getInt('settings.accent') ?? 0).clamp(0, _accentColors.length - 1).toInt();
      _textScale = (prefs.getDouble('settings.textScale') ?? 1).clamp(.85, 1.3).toDouble();
      _animations = prefs.getBool('settings.animations') ?? true;
      _haptics = prefs.getBool('settings.haptics') ?? true;
    });
  }

  Future<void> _save(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) await prefs.setInt(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  void _setTheme(ThemeMode value) {
    setState(() => _themeMode = value);
    _save('settings.theme', value.index);
  }

  void _setAccent(int value) {
    setState(() => _accentIndex = value);
    _save('settings.accent', value);
  }

  void _setTextScale(double value) {
    setState(() => _textScale = value);
    _save('settings.textScale', value);
  }

  void _setAnimations(bool value) {
    setState(() => _animations = value);
    _save('settings.animations', value);
  }

  void _setHaptics(bool value) {
    setState(() => _haptics = value);
    _save('settings.haptics', value);
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SettingsPage(
        themeMode: _themeMode,
        accentIndex: _accentIndex,
        textScale: _textScale,
        animationsEnabled: _animations,
        hapticsEnabled: _haptics,
        onThemeChanged: _setTheme,
        onAccentChanged: _setAccent,
        onTextScaleChanged: _setTextScale,
        onAnimationsChanged: _setAnimations,
        onHapticsChanged: _setHaptics,
        onReset: _resetSettings,
      ),
    ));
  }

  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('settings.theme');
    await prefs.remove('settings.accent');
    await prefs.remove('settings.textScale');
    await prefs.remove('settings.animations');
    await prefs.remove('settings.haptics');
    if (!mounted) return;
    setState(() {
      _themeMode = ThemeMode.system;
      _accentIndex = 0;
      _textScale = 1;
      _animations = true;
      _haptics = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seed = _accentColors[_accentIndex];
    return MaterialApp(
      title: 'Flutter Lab',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        fontFamily: _platformFontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        fontFamily: _platformFontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark, surface: const Color(0xFF111827)),
        scaffoldBackgroundColor: const Color(0xFF090D18),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_textScale)),
        child: child ?? const SizedBox.shrink(),
      ),
      home: HomeShell(
        themeMode: _themeMode,
        animationsEnabled: _animations,
        hapticsEnabled: _haptics,
        onThemePressed: () => _setTheme(switch (_themeMode) {
          ThemeMode.system => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.light,
          ThemeMode.light => ThemeMode.system,
        }),
        onSettingsPressed: _openSettings,
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.themeMode, required this.accentIndex, required this.textScale,
    required this.animationsEnabled, required this.hapticsEnabled,
    required this.onThemeChanged, required this.onAccentChanged,
    required this.onTextScaleChanged, required this.onAnimationsChanged,
    required this.onHapticsChanged, required this.onReset, super.key,
  });
  final ThemeMode themeMode;
  final int accentIndex;
  final double textScale;
  final bool animationsEnabled;
  final bool hapticsEnabled;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<int> onAccentChanged;
  final ValueChanged<double> onTextScaleChanged;
  final ValueChanged<bool> onAnimationsChanged;
  final ValueChanged<bool> onHapticsChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('PERSONALIZATION', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.3, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
            ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
          ],
          selected: {themeMode},
          onSelectionChanged: (value) => onThemeChanged(value.first),
        ),
        const SizedBox(height: 18),
        const Text('Accent color', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (var i = 0; i < _accentColors.length; i++)
            InkWell(
              onTap: () => onAccentChanged(i),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: _accentColors[i], shape: BoxShape.circle,
                  border: Border.all(color: accentIndex == i ? Theme.of(context).colorScheme.onSurface : Colors.transparent, width: 3)),
                child: accentIndex == i ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              ),
            ),
        ]),
        const SizedBox(height: 16),
        Row(children: [const Expanded(child: Text('Text size')), Text('${(textScale * 100).round()}%')]),
        Slider(value: textScale, min: .85, max: 1.3, divisions: 9, onChanged: onTextScaleChanged),
      ]))),
      const SizedBox(height: 22),
      Text('BEHAVIOR', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.3, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Card(child: Column(children: [
        SwitchListTile(title: const Text('Animations'), subtitle: const Text('Enable animated page transitions and motion effects.'), value: animationsEnabled, onChanged: onAnimationsChanged),
        const Divider(height: 1),
        SwitchListTile(title: const Text('Haptic feedback'), subtitle: const Text('Use vibration for supported interactions.'), value: hapticsEnabled, onChanged: onHapticsChanged),
      ])),
      const SizedBox(height: 22),
      Text('STORAGE & ABOUT', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.3, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      Card(child: Column(children: [
        const ListTile(leading: Icon(Icons.save_outlined), title: Text('Preferences'), subtitle: Text('Settings are saved locally on this device.')),
        const Divider(height: 1),
        const ListTile(leading: Icon(Icons.language), title: Text('Language'), subtitle: Text('The app currently uses English. Filipino and Spanish examples are available in Localization Lab.')),
        const Divider(height: 1),
        const ListTile(leading: Icon(Icons.info_outline), title: Text('Flutter Lab'), subtitle: Text('Interactive Flutter capability playground.')),
      ])),
      const SizedBox(height: 18),
      OutlinedButton.icon(onPressed: onReset, icon: const Icon(Icons.restart_alt), label: const Text('Reset settings')),
    ]),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({required this.themeMode, required this.onThemePressed, required this.onSettingsPressed, required this.animationsEnabled, required this.hapticsEnabled, super.key});
  final ThemeMode themeMode;
  final VoidCallback onThemePressed;
  final ValueChanged<BuildContext> onSettingsPressed;
  final bool animationsEnabled;
  final bool hapticsEnabled;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _destination = 0;
  String _query = '';
  bool _favoritesOnly = false;
  Set<String> _favorites = {};
  List<String> _recent = [];

  @override
  void initState() { super.initState(); _loadLibrary(); }

  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favorites = (prefs.getStringList('library.favorites') ?? []).toSet();
      _recent = prefs.getStringList('library.recent') ?? [];
    });
  }

  Future<void> _toggleFavorite(String title) async {
    setState(() {
      if (!_favorites.add(title)) _favorites.remove(title);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('library.favorites', _favorites.toList());
  }

  Future<void> _recordRecent(String title) async {
    setState(() {
      _recent.remove(title);
      _recent.insert(0, title);
      if (_recent.length > 8) _recent = _recent.take(8).toList();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('library.recent', _recent);
  }

  void _openLab(LabDefinition lab) {
    if (widget.hapticsEnabled) HapticFeedback.selectionClick();
    _recordRecent(lab.title);
    Navigator.of(context).push(widget.animationsEnabled
      ? PageRouteBuilder<void>(
          pageBuilder: (_, animation, secondaryAnimation) => lab.builder(context),
          transitionsBuilder: (_, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(.025, 0), end: Offset.zero).animate(animation), child: child)),
        )
      : MaterialPageRoute<void>(builder: (_) => lab.builder(context)));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 850;
    final destinations = const [
      NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
      NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'About'),
    ];
    final content = _destination == 0 ? _buildExplore(context) : _buildAbout(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bolt_rounded, color: Color(0xFF9B8CFF)), SizedBox(width: 9),
          Text('Flutter Lab', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(tooltip: 'Cycle theme', onPressed: widget.onThemePressed, icon: Icon(switch(widget.themeMode) {ThemeMode.system=>Icons.brightness_auto,ThemeMode.dark=>Icons.dark_mode,ThemeMode.light=>Icons.light_mode})),
          IconButton(tooltip: 'Settings', onPressed: () => widget.onSettingsPressed(context), icon: const Icon(Icons.settings_outlined)),
          const SizedBox(width: 8),
        ],
      ),
      body: wide ? Row(children: [
        NavigationRail(selectedIndex: _destination, onDestinationSelected: (v)=>setState(()=>_destination=v), labelType: NavigationRailLabelType.all, destinations: const [
          NavigationRailDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: Text('Explore')),
          NavigationRailDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: Text('About')),
        ]),
        const VerticalDivider(width: 1), Expanded(child: content),
      ]) : content,
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: _destination, onDestinationSelected: (v)=>setState(()=>_destination=v), destinations: destinations),
    );
  }

  Widget _buildExplore(BuildContext context) {
    final labs = labCatalog.where((lab) {
      final matches = lab.title.toLowerCase().contains(_query.toLowerCase()) || lab.description.toLowerCase().contains(_query.toLowerCase()) || lab.category.toLowerCase().contains(_query.toLowerCase());
      return matches && (!_favoritesOnly || _favorites.contains(lab.title));
    }).toList();
    final recentLabs = _recent.map((title) { for (final lab in labCatalog) { if (lab.title == title) return lab; } return null; }).whereType<LabDefinition>().toList();
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(22,24,22,8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Build. Explore. Experiment.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.1)),
        const SizedBox(height: 8),
        Text('A hands-on playground for Flutter UI, animation, graphics, state, storage and real platform integrations.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
        const SizedBox(height: 20),
        TextField(onChanged:(v)=>setState(()=>_query=v), decoration:InputDecoration(hintText:'Search labs and capabilities',prefixIcon:const Icon(Icons.search),suffixIcon:_query.isEmpty?null:IconButton(tooltip:'Clear search',onPressed:()=>setState(()=>_query=''),icon:const Icon(Icons.close)),border:OutlineInputBorder(borderRadius:BorderRadius.circular(18)))),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          FilterChip(label: const Text('All labs'), selected: !_favoritesOnly, onSelected: (_) => setState(() => _favoritesOnly = false)),
          FilterChip(avatar: const Icon(Icons.star, size: 17), label: Text('Favorites (${_favorites.length})'), selected: _favoritesOnly, onSelected: (_) => setState(() => _favoritesOnly = true)),
        ]),
        if (recentLabs.isNotEmpty && _query.isEmpty && !_favoritesOnly) ...[
          const SizedBox(height: 20),
          Text('RECENTLY OPENED', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.4,fontWeight:FontWeight.w800)),
          const SizedBox(height: 8),
          SizedBox(height: 42, child: ListView(scrollDirection:Axis.horizontal, children: recentLabs.map((lab)=>Padding(padding:const EdgeInsets.only(right:8),child:ActionChip(avatar:Icon(lab.icon,size:17),label:Text(lab.title),onPressed:()=>_openLab(lab)))).toList())),
        ],
        const SizedBox(height: 18),
        Row(children: [
          Text(_favoritesOnly ? 'FAVORITE LABS' : 'CAPABILITY LABS', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.6,fontWeight:FontWeight.w800)),
          const Spacer(), Text('${labs.length} labs',style:Theme.of(context).textTheme.labelMedium),
        ]),
        const SizedBox(height: 12),
      ]))),
      if(labs.isEmpty) const SliverFillRemaining(hasScrollBody:false,child:Center(child:Text('No labs match that search.')))
      else SliverPadding(padding:const EdgeInsets.fromLTRB(18,0,18,28),sliver:SliverGrid(
        gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent:420,mainAxisExtent:174,crossAxisSpacing:12,mainAxisSpacing:12),
        delegate:SliverChildBuilderDelegate((context,index)=>LabCard(lab:labs[index],isFavorite:_favorites.contains(labs[index].title),onFavorite:()=>_toggleFavorite(labs[index].title),onTap:()=>_openLab(labs[index])),childCount:labs.length),
      )),
    ]);
  }

  Widget _buildAbout(BuildContext context) => ListView(padding:const EdgeInsets.all(24),children:[
    Icon(Icons.flutter_dash,size:72,color:Theme.of(context).colorScheme.primary),
    const SizedBox(height:18),
    Text('Flutter, hands-on.',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w900)),
    const SizedBox(height:12),
    const Text('Flutter Lab is an interactive collection of experiments built to explore what Flutter can do across Android and Windows. Each lab is designed to be touched, changed and tested.'),
    const SizedBox(height:24),
    const ListTile(leading:Icon(Icons.phone_android),title:Text('Android'),subtitle:Text('Device information, sensors, camera, files, haptics and notifications.')),
    const ListTile(leading:Icon(Icons.desktop_windows),title:Text('Windows'),subtitle:Text('Adaptive layouts, desktop navigation, file picking, sharing and window sizing.')),
    const ListTile(leading:Icon(Icons.code),title:Text('Built with Flutter'),subtitle:Text('Material 3, Dart plugins, audio, storage, networking and custom rendering.')),
    const SizedBox(height:12),
    FilledButton.icon(onPressed:()=>launchUrl(Uri.https('docs.flutter.dev','')),icon:const Icon(Icons.open_in_new),label:const Text('Explore Flutter documentation')),
  ]);
}

class LabCard extends StatelessWidget {
  const LabCard({required this.lab, required this.isFavorite, required this.onFavorite, required this.onTap, super.key});
  final LabDefinition lab;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color=lab.color;
    return Card(clipBehavior:Clip.antiAlias,child:InkWell(onTap:onTap,child:Padding(padding:const EdgeInsets.all(17),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[
        Container(width:44,height:44,decoration:BoxDecoration(color:color.withValues(alpha:.14),borderRadius:BorderRadius.circular(14)),child:Icon(lab.icon,color:color)),
        const Spacer(),
        IconButton(tooltip:isFavorite?'Remove favorite':'Add favorite',visualDensity:VisualDensity.compact,onPressed:onFavorite,icon:Icon(isFavorite?Icons.star_rounded:Icons.star_outline_rounded,color:isFavorite?const Color(0xFFFFC247):Theme.of(context).colorScheme.onSurfaceVariant)),
      ]),
      const Spacer(),
      Text(lab.title,maxLines:1,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:5),
      Text(lab.description,maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.bodySmall?.copyWith(color:Theme.of(context).colorScheme.onSurfaceVariant)),
    ]))));
  }
}
