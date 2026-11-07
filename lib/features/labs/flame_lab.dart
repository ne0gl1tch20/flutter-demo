import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum RunnerStatus { ready, playing, paused, gameOver, won }

class FlamePlatformerLab extends StatefulWidget {
  const FlamePlatformerLab({super.key});

  @override
  State<FlamePlatformerLab> createState() => _FlamePlatformerLabState();
}

class _FlamePlatformerLabState extends State<FlamePlatformerLab> {
  late RunnerGame _game;

  @override
  void initState() {
    super.initState();
    _game = RunnerGame();
  }

  @override
  void dispose() {
    _game.pauseEngine();
    _game.disposeNotifiers();
    super.dispose();
  }

  void _restart() {
    _game.pauseEngine();
    _game.disposeNotifiers();
    setState(() => _game = RunnerGame()..start());
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final down = event is KeyDownEvent;
    final up = event is KeyUpEvent;
    if (!down && !up) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      _game.setDirection(down ? -1 : 0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      _game.setDirection(down ? 1 : 0);
      return KeyEventResult.handled;
    }
    if (down && (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.keyW)) {
      _game.jump();
      return KeyEventResult.handled;
    }
    if (down && key == LogicalKeyboardKey.escape) {
      _game.togglePause();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flame Platformer'),
        actions: [
          IconButton(
            tooltip: 'Restart game',
            onPressed: _restart,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GameWidget<RunnerGame>(game: _game),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: ValueListenableBuilder<int>(
                valueListenable: _game.score,
                builder: (context, score, _) => ValueListenableBuilder<int>(
                  valueListenable: _game.health,
                  builder: (context, health, _) => Row(
                    children: [
                      _HudChip(icon: Icons.stars_rounded, label: '$score'),
                      const SizedBox(width: 8),
                      _HudChip(
                        icon: Icons.favorite_rounded,
                        label: '$health',
                        color: const Color(0xFFFF6B86),
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        tooltip: 'Pause',
                        onPressed: _game.togglePause,
                        icon: const Icon(Icons.pause_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _ControlButton(
                        icon: Icons.arrow_left_rounded,
                        onDown: () => _game.setDirection(-1),
                        onUp: () => _game.setDirection(0),
                      ),
                      const SizedBox(width: 10),
                      _ControlButton(
                        icon: Icons.arrow_right_rounded,
                        onDown: () => _game.setDirection(1),
                        onUp: () => _game.setDirection(0),
                      ),
                    ],
                  ),
                  _ControlButton(
                    icon: Icons.arrow_upward_rounded,
                    label: 'JUMP',
                    onDown: _game.jump,
                    onUp: () {},
                    large: true,
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<RunnerStatus>(
              valueListenable: _game.status,
              builder: (context, status, _) {
                if (status == RunnerStatus.playing) return const SizedBox.shrink();
                final title = switch (status) {
                  RunnerStatus.ready => 'READY, RUNNER?',
                  RunnerStatus.paused => 'PAUSED',
                  RunnerStatus.gameOver => 'RUN OVER',
                  RunnerStatus.won => 'LEVEL CLEAR!',
                  RunnerStatus.playing => '',
                };
                final subtitle = switch (status) {
                  RunnerStatus.ready => 'Collect coins. Dodge the slimes. Reach the flag.',
                  RunnerStatus.paused => 'Take a breather. Your run is frozen.',
                  RunnerStatus.gameOver => 'You ran out of hearts. Give it another shot.',
                  RunnerStatus.won => 'You made it to the end. Nice run!',
                  RunnerStatus.playing => '',
                };
                return ColoredBox(
                  color: const Color(0x99070D1B),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Card(
                        color: const Color(0xFF17243A),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sports_esports_rounded,
                                  color: Color(0xFF9B8CFF), size: 42),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFB8C5D8)),
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: status == RunnerStatus.paused
                                    ? _game.resume
                                    : status == RunnerStatus.ready
                                        ? _game.start
                                        : _restart,
                                icon: Icon(status == RunnerStatus.paused
                                    ? Icons.play_arrow_rounded
                                    : Icons.rocket_launch_rounded),
                                label: Text(status == RunnerStatus.paused
                                    ? 'RESUME'
                                    : status == RunnerStatus.ready
                                        ? 'START RUN'
                                        : 'PLAY AGAIN'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xDD101B2D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color ?? const Color(0xFFFFD166), size: 18),
              const SizedBox(width: 7),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.onDown,
    required this.onUp,
    this.label,
    this.large = false,
  });

  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final String? label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: large ? 76 : 58,
        height: large ? 76 : 58,
        decoration: BoxDecoration(
          color: const Color(0xDD17243A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: large ? 30 : 28),
            if (label != null)
              Text(label!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class RunnerGame extends FlameGame with HasCollisionDetection {
  RunnerGame() : this._(World());

  RunnerGame._(World gameWorld) : super(
    world: gameWorld,
    camera: CameraComponent.withFixedResolution(
      width: 800,
      height: 450,
      world: gameWorld,
    ),
  );

  final score = ValueNotifier<int>(0);
  final health = ValueNotifier<int>(3);
  final status = ValueNotifier<RunnerStatus>(RunnerStatus.ready);

  late final _RunnerPlayer player;
  final List<_Coin> _coins = [];
  final List<_Slime> _slimes = [];
  final List<Rect> _platforms = [];
  double direction = 0;
  double _damageCooldown = 0;
  bool _loaded = false;

  static const double groundY = 382;
  static const double levelEnd = 2900;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await images.loadAll([
      'flame/player.png',
      'flame/player_walk_1.png',
      'flame/player_walk_2.png',
      'flame/player_jump.png',
      'flame/coin.png',
      'flame/slime.png',
      'flame/ground.png',
    ]);

    final sky = _Sky();
    world.add(sky);

    for (var x = 0.0; x < levelEnd; x += 70) {
      world.add(SpriteComponent(
        sprite: Sprite(images.fromCache('flame/ground.png')),
        position: Vector2(x, groundY),
        size: Vector2(70, 70),
        anchor: Anchor.topLeft,
        priority: 1,
      ));
    }

    const platforms = [
      (430.0, 305.0, 4),
      (760.0, 265.0, 3),
      (1110.0, 315.0, 4),
      (1500.0, 275.0, 4),
      (1910.0, 300.0, 4),
      (2280.0, 255.0, 5),
    ];
    for (final platform in platforms) {
      for (var i = 0; i < platform.$3; i++) {
        final x = platform.$1 + i * 56;
        world.add(SpriteComponent(
          sprite: Sprite(images.fromCache('flame/ground.png')),
          position: Vector2(x, platform.$2),
          size: Vector2(56, 42),
          anchor: Anchor.topLeft,
          priority: 1,
        ));
        _platforms.add(Rect.fromLTWH(x, platform.$2, 56, 20));
      }
    }

    player = _RunnerPlayer(this)
      ..position = Vector2(100, groundY - 76)
      ..size = Vector2(52, 76);
    world.add(player);
    camera.follow(player, horizontalOnly: true);

    for (final point in <Vector2>[
      Vector2(270, 320), Vector2(470, 245), Vector2(540, 245),
      Vector2(820, 205), Vector2(880, 205), Vector2(1160, 255),
      Vector2(1230, 255), Vector2(1560, 215), Vector2(1630, 215),
      Vector2(1970, 240), Vector2(2040, 240), Vector2(2350, 195),
      Vector2(2430, 195), Vector2(2630, 320),
    ]) {
      final coin = _Coin()
        ..sprite = Sprite(images.fromCache('flame/coin.png'))
        ..position = point
        ..size = Vector2.all(30);
      _coins.add(coin);
      world.add(coin);
    }

    for (final x in [650.0, 1020.0, 1390.0, 1810.0, 2190.0, 2530.0]) {
      final slime = _Slime(this, x)
        ..sprite = Sprite(images.fromCache('flame/slime.png'))
        ..position = Vector2(x, groundY - 34)
        ..size = Vector2(48, 34);
      _slimes.add(slime);
      world.add(slime);
    }

    _loaded = true;
  }

  void start() {
    if (!_loaded) return;
    status.value = RunnerStatus.playing;
    resumeEngine();
  }

  void resume() {
    status.value = RunnerStatus.playing;
    resumeEngine();
  }

  void togglePause() {
    if (status.value == RunnerStatus.playing) {
      status.value = RunnerStatus.paused;
      pauseEngine();
    } else if (status.value == RunnerStatus.paused) {
      resume();
    }
  }

  void setDirection(double value) => direction = value;

  void jump() {
    if (status.value == RunnerStatus.playing && player.onGround) {
      player.velocityY = -510;
      player.onGround = false;
    }
  }

  void collectCoin(_Coin coin) {
    if (!coin.collected) {
      coin.collected = true;
      coin.removeFromParent();
      score.value += 10;
    }
  }

  void hitPlayer() {
    if (_damageCooldown > 0 || status.value != RunnerStatus.playing) return;
    _damageCooldown = 1.15;
    health.value = math.max(0, health.value - 1);
    player.velocityY = -260;
    player.position.x = math.max(0.0, player.position.x - 38).toDouble();
    if (health.value == 0) {
      status.value = RunnerStatus.gameOver;
      pauseEngine();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (status.value != RunnerStatus.playing) return;
    _damageCooldown = math.max(0.0, _damageCooldown - dt);

    for (final coin in _coins) {
      if (!coin.collected && _overlaps(player, coin, inset: 9)) {
        collectCoin(coin);
      }
    }
    for (final slime in _slimes) {
      if (!slime.dead && _overlaps(player, slime, inset: 10)) {
        hitPlayer();
      }
    }
    if (player.position.y > 520) {
      hitPlayer();
      player.position
        ..x = math.max(0.0, player.position.x - 100).toDouble()
        ..y = groundY - player.height;
      player.velocityY = 0;
    }
    if (player.position.x >= levelEnd - 120) {
      status.value = RunnerStatus.won;
      pauseEngine();
    }
  }

  bool _overlaps(PositionComponent a, PositionComponent b, {double inset = 0}) {
    final ar = Rect.fromLTWH(a.x + inset, a.y + inset,
        math.max(0.0, a.width - inset * 2).toDouble(), math.max(0.0, a.height - inset * 2).toDouble());
    final br = Rect.fromLTWH(b.x + inset, b.y + inset,
        math.max(0.0, b.width - inset * 2).toDouble(), math.max(0.0, b.height - inset * 2).toDouble());
    return ar.overlaps(br);
  }

  void disposeNotifiers() {
    score.dispose();
    health.dispose();
    status.dispose();
  }
}

class _RunnerPlayer extends SpriteComponent with HasGameReference<RunnerGame> {
  _RunnerPlayer(this.owner) : super(anchor: Anchor.topLeft, priority: 5);
  final RunnerGame owner;
  double velocityY = 0;
  bool onGround = false;
  double _walkClock = 0;
  bool _facingLeft = false;

  @override
  void onMount() {
    super.onMount();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (owner.status.value != RunnerStatus.playing) return;

    x = (x + owner.direction * 245 * dt).clamp(0.0, RunnerGame.levelEnd - width).toDouble();
    velocityY += 1150 * dt;
    final previousBottom = y + height;
    y += velocityY * dt;

    var landed = false;
    if (velocityY >= 0 && previousBottom <= RunnerGame.groundY &&
        y + height >= RunnerGame.groundY) {
      y = RunnerGame.groundY - height;
      landed = true;
    } else if (velocityY >= 0) {
      for (final platform in owner._platforms) {
        if (previousBottom <= platform.top &&
            y + height >= platform.top &&
            x + width > platform.left &&
            x < platform.right) {
          y = platform.top - height;
          landed = true;
          break;
        }
      }
    }
    if (landed) {
      velocityY = 0;
      onGround = true;
    } else {
      onGround = false;
    }

    _walkClock += dt;
    if (!onGround) {
      sprite = Sprite(game.images.fromCache('flame/player_jump.png'));
    } else if (owner.direction != 0) {
      final frame = (_walkClock * 9).floor().isEven
          ? 'flame/player_walk_1.png'
          : 'flame/player_walk_2.png';
      sprite = Sprite(game.images.fromCache(frame));
    } else {
      sprite = Sprite(game.images.fromCache('flame/player.png'));
    }
    if (owner.direction != 0 && (owner.direction < 0) != _facingLeft) {
      _facingLeft = owner.direction < 0;
      flipHorizontally();
    }
  }
}

class _Coin extends SpriteComponent with HasGameReference<RunnerGame> {
  _Coin() : super(anchor: Anchor.topLeft, priority: 4);
  bool collected = false;
  double _time = 0;
  double _baseY = 0;

  @override
  void onMount() {
    super.onMount();
    _baseY = y;
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (collected) return;
    _time += dt;
    angle = math.sin(_time * 4) * .12;
    y = _baseY + math.sin(_time * 3) * 4;
  }
}

class _Slime extends SpriteComponent with HasGameReference<RunnerGame> {
  _Slime(this.owner, this.originX)
      : super(anchor: Anchor.topLeft, priority: 4);
  final RunnerGame owner;
  final double originX;
  bool dead = false;
  double _time = 0;

  @override
  void onMount() {
    super.onMount();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (owner.status.value != RunnerStatus.playing) return;
    _time += dt;
    x = originX + math.sin(_time * 1.4) * 48;
    sprite = Sprite(game.images.fromCache('flame/slime.png'));
  }
}

class _Sky extends PositionComponent {
  _Sky() {
    size = Vector2(2900, 450);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, RunnerGame.levelEnd, 450);
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(
      colors: [Color(0xFF72C8F5), Color(0xFFB9E7F8), Color(0xFFE5F5D7)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect));

    final sun = Paint()..color = const Color(0xFFFFE59B);
    canvas.drawCircle(const Offset(680, 85), 38, sun);
    final hillPaint = Paint()..color = const Color(0xFF8CCB9D);
    final farHill = Path()
      ..moveTo(0, 360)
      ..lineTo(0, 290)
      ..quadraticBezierTo(280, 170, 560, 290)
      ..quadraticBezierTo(850, 390, 1150, 270)
      ..quadraticBezierTo(1500, 150, 1810, 290)
      ..quadraticBezierTo(2200, 390, 2900, 240)
      ..lineTo(2900, 450)
      ..lineTo(0, 450)
      ..close();
    canvas.drawPath(farHill, hillPaint);

    final nearPaint = Paint()..color = const Color(0xFF62AE83);
    final nearHill = Path()
      ..moveTo(0, 385)
      ..quadraticBezierTo(360, 280, 720, 380)
      ..quadraticBezierTo(1120, 450, 1500, 350)
      ..quadraticBezierTo(1960, 250, 2400, 380)
      ..quadraticBezierTo(2670, 430, 2900, 340)
      ..lineTo(2900, 450)
      ..lineTo(0, 450)
      ..close();
    canvas.drawPath(nearHill, nearPaint);
  }
}
