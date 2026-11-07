import 'package:flame/components.dart';
import 'package:flame/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab/features/labs/flame_lab.dart';

void main() {
  test('game camera fills portrait and desktop window heights', () {
    final game = RunnerGame();

    expect(game.camera.viewport, isA<MaxViewport>());

    game.onGameResize(Vector2(390, 844));
    expect(game.camera.viewfinder.zoom, closeTo(844 / 450, 0.001));

    game.onGameResize(Vector2(1280, 720));
    expect(game.camera.viewfinder.zoom, closeTo(720 / 450, 0.001));

    game.disposeNotifiers();
  });
}
