import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class PlatformExtrasLab extends StatefulWidget {
  const PlatformExtrasLab({super.key});

  @override
  State<PlatformExtrasLab> createState() => _PlatformExtrasLabState();
}

class _PlatformExtrasLabState extends State<PlatformExtrasLab> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _image;
  String _fileMessage = 'No file selected.';
  bool _busy = false;

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
  Widget build(BuildContext context) => LabPage(
        title: 'Platform Tools',
        description:
            'Try native image capture, system file picking, sharing and clipboard access. Some actions are platform-specific.',
        child: Column(
          children: [
            LabCardPanel(
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
            LabCardPanel(
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
            LabCardPanel(
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
            LabCardPanel(
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
  final AudioPlayer _player = AudioPlayer();
  bool _loading = false;
  bool _playing = false;
  String _status = 'Ready to play a short online audio sample.';

  Future<void> _play() async {
    setState(() {
      _loading = true;
      _status = 'Loading audio…';
    });
    try {
      await _player.play(
        UrlSource('https://actions.google.com/sounds/v1/cartoon/pop.ogg'),
      );
      if (mounted) {
        setState(() {
          _playing = true;
          _status = 'Playing sample audio.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _status = 'Audio failed: $error');
    } finally {
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
  Widget build(BuildContext context) => LabPage(
        title: 'Audio Lab',
        description:
            'Play and stop a short sound over HTTPS using an audio plugin. Internet access is required.',
        child: LabCardPanel(
          title: 'Audio playback',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.graphic_eq_rounded, size: 54),
              const SizedBox(height: 12),
              Text(_status),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _loading ? null : _play,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_loading ? 'Loading…' : 'Play sample'),
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
  Widget build(BuildContext context) => LabPage(
        title: 'Notifications Lab',
        description:
            'Initialize the Android notification plugin, request permission and send a local notification.',
        child: LabCardPanel(
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
