import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'labs.dart';

class WidgetStudioLab extends StatefulWidget {
  const WidgetStudioLab({super.key});
  @override
  State<WidgetStudioLab> createState() => _WidgetStudioLabState();
}

class _WidgetStudioLabState extends State<WidgetStudioLab> {
  String kind = 'Button';
  String label = 'Hello Flutter';
  double radius = 16;
  double padding = 18;
  double slider = .6;
  bool selected = true;
  Color accent = const Color(0xFF806BFF);

  String get code {
    final safe = label.replaceAll("'", "\\'");
    if (kind == 'Button') return "FilledButton(onPressed: () {}, child: const Text('$safe'))";
    if (kind == 'Card') return "Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(" + radius.round().toString() + ")), child: Padding(padding: const EdgeInsets.all(" + padding.round().toString() + "), child: const Text('$safe')))";
    if (kind == 'Chip') return "FilterChip(label: const Text('$safe'), selected: true, onSelected: (value) {})";
    if (kind == 'Switch') return "Switch(value: true, onChanged: (value) {})";
    if (kind == 'Slider') return "Slider(value: 0.6, onChanged: (value) {})";
    return "Text('$safe')";
  }

  Widget get preview {
    if (kind == 'Button') return FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: accent), child: Text(label));
    if (kind == 'Card') return Card(color: accent.withValues(alpha: .12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)), child: Padding(padding: EdgeInsets.all(padding), child: Text(label)));
    if (kind == 'Chip') return FilterChip(label: Text(label), selected: selected, onSelected: (v) => setState(() => selected = v));
    if (kind == 'Switch') return Switch(value: selected, onChanged: (v) => setState(() => selected = v));
    if (kind == 'Slider') return Slider(value: slider, onChanged: (v) => setState(() => slider = v));
    return Text(label, style: Theme.of(context).textTheme.headlineSmall);
  }

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Widget Studio',
    description: 'Configure a real Flutter widget, preview its state and copy the generated Dart snippet.',
    child: Column(children: [
      LabCardPanel(title: 'Live preview', child: Container(width: double.infinity, height: 150, alignment: Alignment.center, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)), child: preview)),
      const SizedBox(height: 12),
      LabCardPanel(title: 'Properties', child: Column(children: [
        DropdownButtonFormField<String>(initialValue: kind, decoration: const InputDecoration(labelText: 'Widget type'), items: ['Button', 'Card', 'Chip', 'Switch', 'Slider', 'Text'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => kind = v ?? kind)),
        const SizedBox(height: 10),
        TextFormField(initialValue: label, decoration: const InputDecoration(labelText: 'Label'), onChanged: (v) => setState(() => label = v)),
        if (kind == 'Card') _StudioSlider(label: 'Corner radius', value: radius, min: 0, max: 32, onChanged: (v) => setState(() => radius = v)),
        if (kind == 'Card') _StudioSlider(label: 'Padding', value: padding, min: 8, max: 32, onChanged: (v) => setState(() => padding = v)),
        if (kind == 'Chip' || kind == 'Switch') SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Selected'), value: selected, onChanged: (v) => setState(() => selected = v)),
        if (kind == 'Slider') _StudioSlider(label: 'Value', value: slider, min: 0, max: 1, onChanged: (v) => setState(() => slider = v)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, children: [
          for (final c in const [Color(0xFF806BFF), Color(0xFF21B891), Color(0xFF3498DB), Color(0xFFFF8A50), Color(0xFFE85D9E)])
            InkWell(onTap: () => setState(() => accent = c), child: CircleAvatar(radius: 16, backgroundColor: c, child: accent == c ? const Icon(Icons.check, color: Colors.white, size: 17) : null)),
        ]),
      ])),
      const SizedBox(height: 12),
      _StudioCode(code: code),
    ]),
  );
}

class VisualBuilderLab extends StatefulWidget {
  const VisualBuilderLab({super.key});
  @override
  State<VisualBuilderLab> createState() => _VisualBuilderLabState();
}

class _VisualBuilderLabState extends State<VisualBuilderLab> {
  final List<_BuilderNode> nodes = [
    _BuilderNode('Text', 'Welcome to my app'),
    _BuilderNode('Button', 'Get started'),
    _BuilderNode('Card', 'A card component'),
  ];

  void add(String type) => setState(() => nodes.add(_BuilderNode(type, 'New ' + type.toLowerCase())));

  String get code {
    final lines = <String>['Column(', '  crossAxisAlignment: CrossAxisAlignment.stretch,', '  children: ['];
    for (final node in nodes) {
      final text = node.label.replaceAll("'", "\\'");
      if (node.type == 'Text') lines.add("    Text('$text'),");
      if (node.type == 'Button') lines.add("    FilledButton(onPressed: () {}, child: Text('$text')),");
      if (node.type == 'Card') lines.add("    Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('$text'))),");
      if (node.type == 'Divider') lines.add('    const Divider(),');
    }
    lines.addAll(['  ],', ')']);
    return lines.join('\n');
  }

  Widget nodePreview(_BuilderNode node) {
    if (node.type == 'Text') return Padding(padding: const EdgeInsets.all(8), child: Text(node.label, style: Theme.of(context).textTheme.titleLarge));
    if (node.type == 'Button') return Padding(padding: const EdgeInsets.all(6), child: FilledButton(onPressed: () {}, child: Text(node.label)));
    if (node.type == 'Card') return Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(node.label)));
    return const Divider(height: 24);
  }

  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Visual UI Builder',
    description: 'Arrange a widget tree, edit labels, reorder elements and export the equivalent Flutter layout code.',
    child: Column(children: [
      LabCardPanel(title: 'Add components', child: Wrap(spacing: 8, children: [
        for (final type in ['Text', 'Button', 'Card', 'Divider']) ActionChip(avatar: const Icon(Icons.add, size: 16), label: Text(type), onPressed: () => add(type)),
      ])),
      const SizedBox(height: 12),
      LabCardPanel(title: 'Canvas · ' + nodes.length.toString() + ' components', child: nodes.isEmpty
        ? const Text('Add a component to start building.')
        : ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) => setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = nodes.removeAt(oldIndex);
              nodes.insert(newIndex, item);
            }),
            children: [
              for (var i = 0; i < nodes.length; i++)
                Container(
                  key: ValueKey(nodes[i].id),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outlineVariant), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.drag_indicator),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(nodes[i].type, style: Theme.of(context).textTheme.labelSmall),
                      if (nodes[i].type != 'Divider') TextFormField(initialValue: nodes[i].label, decoration: const InputDecoration(isDense: true, border: InputBorder.none), onChanged: (v) => setState(() => nodes[i].label = v)),
                      nodePreview(nodes[i]),
                    ])),
                    IconButton(onPressed: () => setState(() => nodes.removeAt(i)), icon: const Icon(Icons.delete_outline)),
                  ]),
                ),
            ],
          )),
      const SizedBox(height: 12),
      _StudioCode(code: code),
    ]),
  );
}

class _BuilderNode {
  _BuilderNode(this.type, this.label) : id = DateTime.now().microsecondsSinceEpoch.toString() + (_counter++).toString();
  static int _counter = 0;
  final String id;
  final String type;
  String label;
}

class JsonWorkbenchLab extends StatefulWidget {
  const JsonWorkbenchLab({super.key});
  @override
  State<JsonWorkbenchLab> createState() => _JsonWorkbenchLabState();
}

class _JsonWorkbenchLabState extends State<JsonWorkbenchLab> {
  final input = TextEditingController(text: '{\n  "name": "Flutter Lab",\n  "version": 1,\n  "features": ["format", "validate", "minify"]\n}');
  String output = '';
  String status = 'Paste or edit JSON, then validate or transform it.';
  bool valid = true;
  @override
  void dispose() { input.dispose(); super.dispose(); }
  void transform(bool pretty) {
    try {
      final value = jsonDecode(input.text);
      output = pretty ? const JsonEncoder.withIndent('  ').convert(value) : jsonEncode(value);
      setState(() { valid = true; status = 'Valid JSON · ' + output.length.toString() + ' characters'; });
    } on FormatException catch (e) {
      setState(() { valid = false; status = 'Invalid JSON: ' + e.message; output = ''; });
    }
  }
  @override
  Widget build(BuildContext context) => LabPage(
    title: 'JSON Workbench',
    description: 'Format, minify and validate JSON locally. Your content never leaves this device.',
    child: Column(children: [
      LabCardPanel(title: 'Input', child: Column(children: [
        TextField(controller: input, minLines: 8, maxLines: 16, style: const TextStyle(fontFamily: 'monospace', fontSize: 13), decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Paste JSON here')),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          FilledButton.icon(onPressed: () => transform(true), icon: const Icon(Icons.format_align_left), label: const Text('Format')),
          OutlinedButton.icon(onPressed: () => transform(false), icon: const Icon(Icons.compress), label: const Text('Minify')),
          TextButton(onPressed: () => setState(() { input.clear(); output = ''; status = 'Input cleared.'; }), child: const Text('Clear')),
        ]),
      ])),
      const SizedBox(height: 12),
      LabCardPanel(title: 'Validation', child: Row(children: [
        Icon(valid ? Icons.check_circle : Icons.error, color: valid ? Colors.green : Theme.of(context).colorScheme.error),
        const SizedBox(width: 8),
        Expanded(child: Text(status)),
      ])),
      if (output.isNotEmpty) ...[const SizedBox(height: 12), _StudioCode(code: output, title: 'Output')],
    ]),
  );
}

class TypographyLab extends StatefulWidget {
  const TypographyLab({super.key});
  @override
  State<TypographyLab> createState() => _TypographyLabState();
}

class _TypographyLabState extends State<TypographyLab> {
  double size = 28;
  double lineHeight = 1.35;
  double spacing = 0;
  FontWeight weight = FontWeight.w600;
  String sample = 'Design with confidence.';
  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Typography Studio',
    description: 'Tune text size, weight, line height and letter spacing with a live preview and copyable TextStyle.',
    child: Column(children: [
      LabCardPanel(title: 'Preview', child: Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: Text(sample, style: TextStyle(fontSize: size, height: lineHeight, letterSpacing: spacing, fontWeight: weight)))),
      const SizedBox(height: 12),
      LabCardPanel(title: 'Controls', child: Column(children: [
        TextField(decoration: const InputDecoration(labelText: 'Sample text'), onChanged: (v) => setState(() => sample = v)),
        _StudioSlider(label: 'Font size', value: size, min: 12, max: 48, onChanged: (v) => setState(() => size = v)),
        _StudioSlider(label: 'Line height', value: lineHeight, min: .8, max: 2, onChanged: (v) => setState(() => lineHeight = v)),
        _StudioSlider(label: 'Letter spacing', value: spacing, min: -1, max: 4, onChanged: (v) => setState(() => spacing = v)),
        DropdownButtonFormField<FontWeight>(initialValue: weight, decoration: const InputDecoration(labelText: 'Font weight'), items: const [
          DropdownMenuItem(value: FontWeight.w300, child: Text('Light')),
          DropdownMenuItem(value: FontWeight.w400, child: Text('Regular')),
          DropdownMenuItem(value: FontWeight.w500, child: Text('Medium')),
          DropdownMenuItem(value: FontWeight.w600, child: Text('Semi bold')),
          DropdownMenuItem(value: FontWeight.w700, child: Text('Bold')),
          DropdownMenuItem(value: FontWeight.w900, child: Text('Black')),
        ], onChanged: (v) => setState(() => weight = v ?? weight)),
      ])),
      const SizedBox(height: 12),
      _StudioCode(code: 'TextStyle(fontSize: ' + size.toStringAsFixed(1) + ', height: ' + lineHeight.toStringAsFixed(2) + ', letterSpacing: ' + spacing.toStringAsFixed(1) + ', fontWeight: FontWeight.' + _weight(weight) + ')'),
    ]),
  );
}

String _weight(FontWeight value) {
  if (value == FontWeight.w300) return 'w300';
  if (value == FontWeight.w400) return 'w400';
  if (value == FontWeight.w500) return 'w500';
  if (value == FontWeight.w600) return 'w600';
  if (value == FontWeight.w700) return 'w700';
  if (value == FontWeight.w900) return 'w900';
  return 'normal';
}

class CodeSnippetLab extends StatefulWidget {
  const CodeSnippetLab({super.key});
  @override
  State<CodeSnippetLab> createState() => _CodeSnippetLabState();
}

class _CodeSnippetLabState extends State<CodeSnippetLab> {
  final code = TextEditingController(text: "import 'package:flutter/material.dart';\n\nWidget buildGreeting() {\n  return const Text('Hello Flutter!');\n}");
  final name = TextEditingController(text: 'My snippet');
  List<String> snippets = [];
  String status = 'Saved snippets stay on this device.';
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) { if (mounted) setState(() => snippets = p.getStringList('snippets.saved') ?? []); });
  }
  @override
  void dispose() { code.dispose(); name.dispose(); super.dispose(); }
  Future<void> save() async {
    final entry = jsonEncode({'name': name.text.trim().isEmpty ? 'Untitled' : name.text.trim(), 'code': code.text});
    snippets.insert(0, entry);
    if (snippets.length > 30) snippets = snippets.take(30).toList();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('snippets.saved', snippets);
    if (mounted) setState(() => status = 'Snippet saved.');
  }
  Future<void> copy() async {
    await Clipboard.setData(ClipboardData(text: code.text));
    if (mounted) setState(() => status = 'Code copied.');
  }
  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Code Snippet Studio',
    description: 'Edit and organize reusable Dart examples. This is a snippet editor, not an arbitrary Dart execution environment.',
    child: Column(children: [
      LabCardPanel(title: 'Editor', child: Column(children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Snippet name')),
        const SizedBox(height: 10),
        TextField(controller: code, minLines: 10, maxLines: 18, style: const TextStyle(fontFamily: 'monospace', fontSize: 13), decoration: const InputDecoration(labelText: 'Dart source', alignLabelWithHint: true, border: OutlineInputBorder())),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: [
          FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: const Text('Save snippet')),
          OutlinedButton.icon(onPressed: copy, icon: const Icon(Icons.copy), label: const Text('Copy code')),
        ]),
        Text(status),
      ])),
      const SizedBox(height: 12),
      LabCardPanel(title: 'Saved snippets · ' + snippets.length.toString(), child: snippets.isEmpty ? const Text('No snippets saved yet.') : Column(children: [
        for (var i = 0; i < snippets.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.code),
            title: Text((jsonDecode(snippets[i]) as Map)['name'].toString()),
            subtitle: Text((jsonDecode(snippets[i]) as Map)['code'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              final data = jsonDecode(snippets[i]) as Map<String, dynamic>;
              setState(() { name.text = data['name'] as String; code.text = data['code'] as String; });
            },
            trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
              snippets.removeAt(i);
              final p = await SharedPreferences.getInstance();
              await p.setStringList('snippets.saved', snippets);
              if (mounted) setState(() => status = 'Snippet deleted.');
            }),
          ),
      ])),
    ]),
  );
}

class AssetInspectorLab extends StatefulWidget {
  const AssetInspectorLab({super.key});
  @override
  State<AssetInspectorLab> createState() => _AssetInspectorLabState();
}

class _AssetInspectorLabState extends State<AssetInspectorLab> {
  Uint8List? bytes;
  String name = 'No image selected';
  String details = 'Choose an image to inspect its dimensions and file size.';
  bool loading = false;
  Future<void> pick() async {
    setState(() => loading = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) {
        setState(() => details = 'This provider did not return image bytes. Try another image.');
        return;
      }
      final codec = await ui.instantiateImageCodec(file.bytes!);
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) return;
      setState(() {
        bytes = file.bytes;
        name = file.name;
        details = frame.image.width.toString() + ' × ' + frame.image.height.toString() + ' pixels · ' + (file.size / 1024).toStringAsFixed(1) + ' KB';
      });
    } catch (error) {
      if (mounted) setState(() => details = 'Could not inspect image: ' + error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Asset Inspector',
    description: 'Pick a local image and inspect its dimensions, encoded size and preview. The file stays on your device.',
    child: LabCardPanel(title: 'Image details', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (bytes != null) ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(bytes!, width: double.infinity, height: 240, fit: BoxFit.contain))
      else Container(height: 180, width: double.infinity, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.image_outlined, size: 54)),
      const SizedBox(height: 12),
      Text(name, style: Theme.of(context).textTheme.titleMedium),
      Text(details),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: loading ? null : pick, icon: const Icon(Icons.folder_open), label: Text(loading ? 'Inspecting…' : 'Choose image')),
    ])),
  );
}

class WorkspaceLab extends StatefulWidget {
  const WorkspaceLab({super.key});
  @override
  State<WorkspaceLab> createState() => _WorkspaceLabState();
}

class _WorkspaceLabState extends State<WorkspaceLab> {
  final name = TextEditingController();
  final notes = TextEditingController();
  List<Map<String, dynamic>> workspaces = [];
  int active = 0;
  String status = 'Create separate project workspaces. Backups can be copied between devices.';
  @override
  void initState() { super.initState(); load(); }
  @override
  void dispose() { name.dispose(); notes.dispose(); super.dispose(); }
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    try { workspaces = (jsonDecode(p.getString('workspaces.data') ?? '[]') as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(); } catch (_) { workspaces = []; }
    active = (p.getInt('workspaces.active') ?? 0).clamp(0, workspaces.isEmpty ? 0 : workspaces.length - 1).toInt();
    if (mounted) setState(() { if (workspaces.isNotEmpty) notes.text = workspaces[active]['notes'] as String? ?? ''; });
  }
  Future<void> persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('workspaces.data', jsonEncode(workspaces));
    await p.setInt('workspaces.active', active);
  }
  Future<void> saveNotes() async {
    if (workspaces.isEmpty) return;
    workspaces[active]['notes'] = notes.text;
    await persist();
    if (mounted) setState(() => status = 'Workspace saved.');
  }
  Future<void> create() async {
    if (name.text.trim().isEmpty) { setState(() => status = 'Enter a workspace name.'); return; }
    workspaces.add({'name': name.text.trim(), 'notes': ''});
    active = workspaces.length - 1;
    notes.clear();
    name.clear();
    await persist();
    if (mounted) setState(() => status = 'Workspace created.');
  }
  Future<void> backup() async {
    await saveNotes();
    final data = {'format': 'flutter-lab-workspaces-v1', 'active': active, 'workspaces': workspaces};
    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
    if (mounted) setState(() => status = 'Backup JSON copied. Save it as a file or paste it on another device.');
  }
  Future<void> restore() async {
    final text = await showDialog<String>(context: context, builder: (context) {
      final input = TextEditingController();
      return AlertDialog(
        title: const Text('Import workspace backup'),
        content: SizedBox(width: 480, child: TextField(controller: input, minLines: 6, maxLines: 12, decoration: const InputDecoration(hintText: 'Paste workspace JSON', border: OutlineInputBorder()))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, input.text), child: const Text('Import')),
        ],
      );
    });
    if (text == null || text.trim().isEmpty) return;
    try {
      final data = jsonDecode(text) as Map<String, dynamic>;
      if (data['format'] != 'flutter-lab-workspaces-v1') throw const FormatException('Unknown backup format');
      final imported = (data['workspaces'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (imported.any((e) => e['name'] is! String || e['notes'] is! String)) throw const FormatException('Invalid workspace entry');
      workspaces = imported;
      active = (data['active'] as int? ?? 0).clamp(0, workspaces.isEmpty ? 0 : workspaces.length - 1).toInt();
      notes.text = workspaces.isEmpty ? '' : workspaces[active]['notes'] as String;
      await persist();
      if (mounted) setState(() => status = 'Imported ' + workspaces.length.toString() + ' workspace(s).');
    } catch (error) {
      if (mounted) setState(() => status = 'Import failed: ' + error.toString());
    }
  }
  @override
  Widget build(BuildContext context) => LabPage(
    title: 'Workspace Manager',
    description: 'Keep project notes in separate local workspaces. Export and import JSON backups to move them between Android and Windows.',
    child: Column(children: [
      LabCardPanel(title: 'Create workspace', child: Column(children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Workspace name', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: create, icon: const Icon(Icons.add), label: const Text('Create workspace')),
      ])),
      if (workspaces.isNotEmpty) ...[
        const SizedBox(height: 12),
        LabCardPanel(title: 'Active workspace', child: Column(children: [
          DropdownButtonFormField<int>(initialValue: active, decoration: const InputDecoration(labelText: 'Select workspace'), items: [for (var i = 0; i < workspaces.length; i++) DropdownMenuItem(value: i, child: Text(workspaces[i]['name'] as String))], onChanged: (v) async {
            if (v == null) return;
            await saveNotes();
            setState(() { active = v; notes.text = workspaces[active]['notes'] as String; });
            await persist();
          }),
          const SizedBox(height: 10),
          TextField(controller: notes, minLines: 5, maxLines: 10, decoration: const InputDecoration(labelText: 'Project notes', alignLabelWithHint: true, border: OutlineInputBorder())),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            FilledButton.icon(onPressed: saveNotes, icon: const Icon(Icons.save), label: const Text('Save notes')),
            OutlinedButton.icon(onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete workspace?'), content: Text('Delete ' + (workspaces[active]['name'] as String) + '?'), actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
              ]));
              if (ok != true) return;
              setState(() { workspaces.removeAt(active); active = active.clamp(0, workspaces.isEmpty ? 0 : workspaces.length - 1).toInt(); notes.text = workspaces.isEmpty ? '' : workspaces[active]['notes'] as String; });
              await persist();
            }, icon: const Icon(Icons.delete_outline), label: const Text('Delete')),
          ]),
        ])),
      ],
      const SizedBox(height: 12),
      LabCardPanel(title: 'Backup & transfer', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(status),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          OutlinedButton.icon(onPressed: backup, icon: const Icon(Icons.copy), label: const Text('Copy backup JSON')),
          OutlinedButton.icon(onPressed: restore, icon: const Icon(Icons.restore), label: const Text('Import backup')),
        ]),
      ])),
    ]),
  );
}

class TestScenarioLab extends StatefulWidget {
  const TestScenarioLab({super.key});
  @override
  State<TestScenarioLab> createState() => _TestScenarioLabState();
}

class _TestScenarioLabState extends State<TestScenarioLab> {
  final input = TextEditingController();
  final List<_TestStep> steps = [
    _TestStep('Open the target screen'),
    _TestStep('Check the primary action'),
    _TestStep('Verify loading and error states'),
    _TestStep('Confirm the result is persisted'),
  ];
  @override
  void dispose() { input.dispose(); super.dispose(); }
  void add() {
    if (input.text.trim().isEmpty) return;
    setState(() { steps.add(_TestStep(input.text.trim())); input.clear(); });
  }
  @override
  Widget build(BuildContext context) {
    final passed = steps.where((e) => e.done).length;
    return LabPage(
      title: 'Test Scenario Builder',
      description: 'Create repeatable manual QA checklists, mark each step and track test progress.',
      child: LabCardPanel(title: 'Test run', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(passed.toString() + ' / ' + steps.length.toString() + ' steps passed', style: Theme.of(context).textTheme.titleMedium)), Text((steps.isEmpty ? 0 : (passed / steps.length * 100).round()).toString() + '%')]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: steps.isEmpty ? 0 : passed / steps.length),
        const SizedBox(height: 8),
        for (var i = 0; i < steps.length; i++)
          CheckboxListTile(contentPadding: EdgeInsets.zero, value: steps[i].done, onChanged: (v) => setState(() => steps[i].done = v ?? false), title: Text(steps[i].title), secondary: IconButton(onPressed: () => setState(() => steps.removeAt(i)), icon: const Icon(Icons.close))),
        Row(children: [
          Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Add a test step', border: OutlineInputBorder()), onSubmitted: (_) => add())),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: add, icon: const Icon(Icons.add)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          OutlinedButton.icon(onPressed: () => setState(() { for (final step in steps) { step.done = false; } }), icon: const Icon(Icons.restart_alt), label: const Text('Reset')),
          FilledButton.icon(onPressed: () async {
            final text = steps.map((e) => (e.done ? '[x] ' : '[ ] ') + e.title).join('\n');
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checklist copied.')));
          }, icon: const Icon(Icons.copy), label: const Text('Copy checklist')),
        ]),
      ])),
    );
  }
}

class _TestStep {
  _TestStep(this.title);
  final String title;
  bool done = false;
}

class _StudioSlider extends StatelessWidget {
  const _StudioSlider({required this.label, required this.value, required this.min, required this.max, required this.onChanged});
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(label)), Text(value.toStringAsFixed(1))]),
    Slider(value: value.clamp(min, max).toDouble(), min: min, max: max, onChanged: onChanged),
  ]);
}

class _StudioCode extends StatelessWidget {
  const _StudioCode({required this.code, this.title = 'Generated Flutter code'});
  final String code;
  final String title;
  @override
  Widget build(BuildContext context) => LabCardPanel(title: title, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: SelectableText(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.5))),
    const SizedBox(height: 8),
    Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(onPressed: () async {
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied.')));
    }, icon: const Icon(Icons.copy), label: const Text('Copy code'))),
  ]));
}
