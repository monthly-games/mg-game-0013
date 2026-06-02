import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Special visual effect for combo tier milestones
/// Creates a burst of particles and a tier announcement
class ComboMilestoneEffect extends PositionComponent {
  final String tierName;
  final int comboCount;
  final Color tierColor;

  ComboMilestoneEffect({
    required this.tierName,
    required this.comboCount,
    required this.tierColor,
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  double _lifeTime = 0.0;
  final double _maxLifeTime = 2.0;
  final List<Particle> _particles = [];
  final Random _rand = Random();

  @override
  Future<void> onLoad() async {
    // Create burst particles
    for (int i = 0; i < 30; i++) {
      final angle = (i / 30) * 2 * pi;
      final speed = 100 + _rand.nextDouble() * 150;
      _particles.add(Particle(
        angle: angle,
        speed: speed,
        size: 5 + _rand.nextDouble() * 10,
        lifeTime: 0.5 + _rand.nextDouble() * 0.5,
      ));
    }

    // Create rising text effect particles
    for (int i = 0; i < 5; i++) {
      _particles.add(Particle(
        angle: -pi / 2 + (_rand.nextDouble() - 0.5) * 0.5,
        speed: 80 + _rand.nextDouble() * 40,
        size: 3,
        lifeTime: 1.0 + _rand.nextDouble() * 0.5,
        isText: true,
      ));
    }
  }

  @override
  void update(double dt) {
    _lifeTime += dt;

    // Update particles
    for (var particle in _particles) {
      particle.update(dt);
    }

    // Remove dead particles
    _particles.removeWhere((p) => p.isDead);

    // Remove component when all particles are dead
    if (_lifeTime > _maxLifeTime && _particles.isEmpty) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (1.0 - (_lifeTime / _maxLifeTime)).clamp(0.0, 1.0);

    // Render particles
    for (var particle in _particles) {
      particle.render(canvas, tierColor, alpha);
    }

    // Render tier announcement text
    if (_lifeTime < 1.0) {
      final textAlpha = (1.0 - _lifeTime).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$tierName COMBO!',
          style: TextStyle(
            color: tierColor.withOpacity(textAlpha),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(textAlpha),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2 - 50),
      );

      // Render combo count
      final countPainter = TextPainter(
        text: TextSpan(
          text: 'x$comboCount',
          style: TextStyle(
            color: Colors.white.withOpacity(textAlpha),
            fontSize: 48,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: tierColor.withOpacity(textAlpha),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      countPainter.layout();
      countPainter.paint(
        canvas,
        Offset(-countPainter.width / 2, -countPainter.height / 2 + 20),
      );
    }
  }
}

class Particle {
  double angle;
  final double speed;
  final double size;
  double lifeTime;
  final double maxLifeTime;
  final bool isText;

  double _distance = 0.0;
  bool get isDead => lifeTime >= maxLifeTime;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.lifeTime,
    this.isText = false,
  }) : maxLifeTime = lifeTime;

  void update(double dt) {
    lifeTime += dt;
    _distance += speed * dt;
  }

  void render(Canvas canvas, Color color, double alpha) {
    final particleAlpha = (1.0 - (lifeTime / maxLifeTime)).clamp(0.0, 1.0) * alpha;

    if (isText) {
      // Rising sparkle effect
      final x = cos(angle) * _distance;
      final y = sin(angle) * _distance - _distance * 0.5;

      final paint = Paint()
        ..color = color.withOpacity(particleAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), size * particleAlpha, paint);
    } else {
      // Burst particle
      final x = cos(angle) * _distance;
      final y = sin(angle) * _distance;

      final paint = Paint()
        ..color = color.withOpacity(particleAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), size * particleAlpha, paint);
    }
  }
}