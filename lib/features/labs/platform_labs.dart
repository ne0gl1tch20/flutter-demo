import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class PlatformLabPage extends StatelessWidget {
  const PlatformLabPage({
    required this.title,
    required this.description,
    required this.child,
    super.key,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(description),
            const SizedBox(height: 20),
            child,
          ],
        ),
      );
}

class PlatformLabCardPanel extends StatelessWidget {
  const PlatformLabCardPanel({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      );
}

class PlatformExtrasLab extends StatefulWidget {
  const PlatformExtrasLab({super.key});

  @override
  State<PlatformExtrasLab> createState() => _PlatformExtrasLabState();
}

class _PlatformExtrasLabState extends State<PlatformExtrasLab> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  String _fileMessage = 'No file selected.';

  Future<void> _pickImage(ImageSource source) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      _show('Camera and gallery capture are available on mobile.');
      return;
    }
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (mounted && image != null) setState(() => _image = image);
    } catch (error) {
      _show('Image picker failed: $error');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || !mounted) return;
      final file = result.files.single;
      setState(() => _fileMessage =
          '${file.name}\n${(file.size / 1024).toStringAsFixed(1)} KB\n${file.path ?? 'Path unavailable'}');
    } catch (error) {
      _show('File picker failed: $error');
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => PlatformLabPage(
        title: 'Platform Tools',
        description:
            'Try native image capture, system file picking, sharing and clipboard access. Some actions are platform-specific.',
        child: Column(
          children: [
            PlatformLabCardPanel(
              title: 'Camera and gallery',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_image!.path),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 130,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, size: 42),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Take photo'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose image'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PlatformLabCardPanel(
              title: 'System file picker',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fileMessage),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: _pickFile,
                    child: const Text('Choose a file'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PlatformLabCardPanel(
              title: 'Share sheet',
              child: Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(text: 'Hello from Flutter Lab!'),
                    ),
                    child: const Text('Share text'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: 'Copied from Flutter Lab ✨'),
                      );
                      _show('Text copied to clipboard.');
                    },
                    child: const Text('Copy sample text'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      _show(data?.text ?? 'Clipboard is empty.');
                    },
                    child: const Text('Read clipboard'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PlatformLabCardPanel(
              title: 'Haptic feedback',
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => HapticFeedback.selectionClick(),
                    child: const Text('Selection click'),
                  ),
                  OutlinedButton(
                    onPressed: () => HapticFeedback.lightImpact(),
                    child: const Text('Light impact'),
                  ),
                  FilledButton.tonal(
                    onPressed: () => HapticFeedback.mediumImpact(),
                    child: const Text('Medium impact'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class AudioLab extends StatefulWidget {
  const AudioLab({super.key});

  @override
  State<AudioLab> createState() => _AudioLabState();
}

class _AudioLabState extends State<AudioLab> {
  static final Uri _sampleUri = Uri.parse(
    'https://actions.google.com/sounds/v1/cartoon/pop.ogg',
  );

  final AudioPlayer _player = AudioPlayer();
  bool _loading = false;
  bool _playing = false;
  double? _downloadProgress;
  int _downloadedBytes = 0;
  int? _totalBytes;
  double _playbackRate = 1;
  bool _loop = false;
  String _status = 'Ready to download a short online audio sample.';

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _play() async {
    setState(() {
      _loading = true;
      _playing = false;
      _downloadProgress = 0;
      _downloadedBytes = 0;
      _totalBytes = null;
      _status = 'Connecting to sample…';
    });

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    File? sampleFile;

    try {
      final request = await client.getUrl(_sampleUri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Sample server returned HTTP ${response.statusCode}.',
          uri: _sampleUri,
        );
      }

      final totalBytes = response.contentLength > 0
          ? response.contentLength
          : null;
      final directory = await getTemporaryDirectory();
      sampleFile = File('${directory.path}/flutter_lab_audio_sample.ogg');
      final sink = sampleFile.openWrite();
      var downloadedBytes = 0;

      if (mounted) {
        setState(() {
          _totalBytes = totalBytes;
          _status = totalBytes == null
              ? 'Downloading sample…'
              : 'Downloading sample… 0%';
        });
      }

      try {
        await for (final chunk in response) {
          sink.add(chunk);
          downloadedBytes += chunk.length;
          if (mounted) {
            setState(() {
              _downloadedBytes = downloadedBytes;
              _downloadProgress = totalBytes == null
                  ? null
                  : (downloadedBytes / totalBytes).clamp(0.0, 1.0);
              _status = totalBytes == null
                  ? 'Downloaded ${_formatBytes(downloadedBytes)}'
                  : 'Downloading sample… ${(_downloadProgress! * 100).round()}%';
            });
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }

      if (!mounted) return;
      setState(() {
        _downloadProgress = 1;
        _downloadedBytes = downloadedBytes;
        _status = 'Download complete. Starting playback…';
      });

      await _player.setReleaseMode(_loop ? ReleaseMode.loop : ReleaseMode.release);
      await _player.setPlaybackRate(_playbackRate);
      await _player.play(DeviceFileSource(sampleFile.path));
      if (mounted) {
        setState(() {
          _playing = true;
          _status = 'Playing downloaded sample audio.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _status = 'Audio failed: $error');
      if (sampleFile != null && await sampleFile.exists()) {
        await sampleFile.delete();
      }
    } finally {
      client.close(force: true);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    if (mounted) {
      setState(() {
        _playing = false;
        _status = 'Playback stopped.';
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlatformLabPage(
        title: 'Audio Lab 2.0',
        description:
            'Download and play a sample with transfer progress, playback speed, looping and a live visualizer. Internet access is required.',
        child: PlatformLabCardPanel(
          title: 'Audio playback',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.graphic_eq_rounded, size: 54),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(25, (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 5,
                    height: _playing ? 12 + ((index * 17 + _downloadedBytes) % 31).toDouble() : 8 + (index % 4) * 3.0,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                  ),
                )),
              ),
              const SizedBox(height: 12),
              Text(_status),
              Row(children: [
                const Text('Speed'),
                Expanded(child: Slider(value: _playbackRate, min: .5, max: 2, divisions: 6, label: '${_playbackRate.toStringAsFixed(2)}×', onChanged: (value) {
                  setState(() => _playbackRate = value);
                  if (_playing) _player.setPlaybackRate(value);
                })),
                Text('${_playbackRate.toStringAsFixed(2)}×'),
              ]),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Loop playback'),
                value: _loop,
                onChanged: (value) async {
                  setState(() => _loop = value);
                  await _player.setReleaseMode(value ? ReleaseMode.loop : ReleaseMode.release);
                },
              ),
              if (_loading || _downloadProgress != null) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _downloadProgress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(8),
                ),
                const SizedBox(height: 6),
                Text(
                  _totalBytes == null
                      ? _formatBytes(_downloadedBytes)
                      : '${_formatBytes(_downloadedBytes)} / ${_formatBytes(_totalBytes!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _loading ? null : _play,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_loading ? 'Downloading…' : 'Download & play'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _playing ? _stop : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _DownloadQueueItem {
  _DownloadQueueItem(this.url, this.id);
  final String url;
  final int id;
  String status = 'Queued';
  int downloaded = 0;
  int total = 0;
  String? error;
}

class DownloadQueueLab extends StatefulWidget {
  const DownloadQueueLab({super.key});

  @override
  State<DownloadQueueLab> createState() => _DownloadQueueLabState();
}

class _DownloadQueueLabState extends State<DownloadQueueLab> {
  final _urlController = TextEditingController();
  final List<_DownloadQueueItem> _items = [];
  bool _running = false;
  int _nextId = 0;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _addUrl() {
    final raw = _urlController.text.trim();
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasAuthority || !['http', 'https'].contains(uri.scheme)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid HTTP or HTTPS URL.')));
      return;
    }
    setState(() {
      _items.add(_DownloadQueueItem(uri.toString(), _nextId++));
      _urlController.clear();
    });
  }

  void _addSample() {
    _urlController.text = 'https://actions.google.com/sounds/v1/cartoon/pop.ogg';
    _addUrl();
  }

  Future<void> _startQueue() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      while (mounted) {
        final index = _items.indexWhere((item) => item.status == 'Queued');
        if (index < 0) break;
        await _download(_items[index]);
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  Future<void> _download(_DownloadQueueItem item) async {
    HttpClient? client;
    IOSink? sink;
    try {
      setState(() {
        item.status = 'Downloading';
        item.downloaded = 0;
        item.total = 0;
        item.error = null;
      });
      final uri = Uri.parse(item.url);
      client = HttpClient()..connectionTimeout = const Duration(seconds: 20);
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 30));
      final response = await request.close().timeout(const Duration(seconds: 60));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Server returned HTTP ${response.statusCode}.');
      }
      item.total = response.contentLength > 0 ? response.contentLength : 0;
      final directory = await getTemporaryDirectory();
      final downloadDirectory = Directory('${directory.path}/flutter_lab_downloads');
      await downloadDirectory.create(recursive: true);
      final rawName = uri.pathSegments.isEmpty ? 'download_${item.id}' : Uri.decodeComponent(uri.pathSegments.last);
      final safeName = rawName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final file = File('${downloadDirectory.path}/${item.id}_$safeName');
      sink = file.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        item.downloaded += chunk.length;
        if (mounted) setState(() {});
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (mounted) setState(() => item.status = 'Completed');
    } catch (error) {
      await sink?.close();
      if (mounted) {
        setState(() {
          item.status = 'Failed';
          item.error = error.toString();
        });
      }
    } finally {
      client?.close(force: true);
    }
  }

  void _remove(_DownloadQueueItem item) {
    if (_running && item.status == 'Downloading') return;
    setState(() => _items.removeWhere((entry) => entry.id == item.id));
  }

  void _retry(_DownloadQueueItem item) {
    setState(() {
      item.status = 'Queued';
      item.error = null;
      item.downloaded = 0;
      item.total = 0;
    });
  }

  @override
  Widget build(BuildContext context) => PlatformLabPage(
    title: 'Download Queue',
    description: 'Add HTTP or HTTPS files, process downloads one at a time and track each transfer. Files are saved in the app temporary directory.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformLabCardPanel(
          title: 'Add a download',
          child: Column(
            children: [
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'File URL',
                  hintText: 'https://example.com/file.zip',
                  prefixIcon: Icon(Icons.link_rounded),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addUrl(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _addSample, icon: const Icon(Icons.music_note_rounded), label: const Text('Add sample'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.icon(onPressed: _addUrl, icon: const Icon(Icons.add_rounded), label: const Text('Add URL'))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text('${_items.length} queued item(s)', style: Theme.of(context).textTheme.titleMedium)),
            FilledButton.icon(
              onPressed: _running || !_items.any((item) => item.status == 'Queued') ? null : _startQueue,
              icon: Icon(_running ? Icons.downloading_rounded : Icons.play_arrow_rounded),
              label: Text(_running ? 'Downloading' : 'Start queue'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Your download queue is empty. Add a URL to get started.'))))
        else
          ..._items.map((item) => Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.status == 'Completed' ? Icons.check_circle_rounded : item.status == 'Failed' ? Icons.error_outline_rounded : Icons.insert_drive_file_outlined),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.url, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      if (item.status == 'Failed')
                        IconButton(tooltip: 'Retry download', onPressed: _running ? null : () => _retry(item), icon: const Icon(Icons.refresh_rounded)),
                      IconButton(tooltip: 'Remove download', onPressed: _running && item.status == 'Downloading' ? null : () => _remove(item), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: Text(item.status, style: Theme.of(context).textTheme.labelMedium)),
                      Text(item.total > 0 ? '${(item.downloaded / item.total * 100).clamp(0, 100).round()}%' : '${item.downloaded} bytes', style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: item.status == 'Completed' ? 1 : item.total > 0 ? (item.downloaded / item.total).clamp(0, 1) : null,
                  ),
                  if (item.error != null) ...[
                    const SizedBox(height: 6),
                    Text(item.error!, style: TextStyle(color: Theme.of(context).colorScheme.error), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          )),
      ],
    ),
  );
}

class NotificationsLab extends StatefulWidget {
  const NotificationsLab({super.key});

  @override
  State<NotificationsLab> createState() => _NotificationsLabState();
}

class _NotificationsLabState extends State<NotificationsLab> {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  String _status = 'Notifications are not initialized yet.';

  Future<void> _initialize() async {
    if (!Platform.isAndroid) {
      setState(() => _status =
          'This demo currently uses Android local notifications.');
      return;
    }
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _notifications.initialize(settings);
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      if (!mounted) return;
      setState(() {
        _initialized = true;
        _status = granted == false
            ? 'Permission was not granted. Enable notifications in system settings.'
            : 'Notification plugin initialized.';
      });
    } catch (error) {
      if (mounted) setState(() => _status = 'Setup failed: $error');
    }
  }

  Future<void> _send() async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'flutter_lab_demo',
          'Flutter Lab demo',
          channelDescription: 'Test notifications from Flutter Lab',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
      await _notifications.show(
        1,
        'Flutter Lab',
        'Your local notification is working! 🎉',
        details,
      );
      if (mounted) setState(() => _status = 'Notification sent.');
    } catch (error) {
      if (mounted) setState(() => _status = 'Could not send notification: $error');
    }
  }

  @override
  Widget build(BuildContext context) => PlatformLabPage(
        title: 'Notifications Lab',
        description:
            'Initialize the Android notification plugin, request permission and send a local notification.',
        child: PlatformLabCardPanel(
          title: 'Local notifications',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_status),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: _initialize,
                    child: const Text('Initialize and request permission'),
                  ),
                  FilledButton(
                    onPressed: _initialized ? _send : null,
                    child: const Text('Send notification'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
