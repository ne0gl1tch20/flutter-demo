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
        title: 'Audio Lab',
        description:
            'Download a short sound over HTTPS with live transfer progress, then play it locally. Internet access is required.',
        child: PlatformLabCardPanel(
          title: 'Audio playback',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.graphic_eq_rounded, size: 54),
              const SizedBox(height: 12),
              Text(_status),
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
