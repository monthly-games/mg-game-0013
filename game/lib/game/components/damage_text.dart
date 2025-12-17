import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageTextComponent extends TextComponent {
  final double damage;
  final Vector2 velocity = Vector2(0, -50); // Move up
  double lifeTime = 1.0;

  DamageTextComponent({required this.damage, required Vector2 position})
    : super(
        text: damage.toInt().toString(),
        position: position,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(1, 1), color: Colors.black, blurRadius: 2),
            ],
          ),
        ),
        priority: 100, // On top
      );

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }
  }
}
