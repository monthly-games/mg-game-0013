import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageTextComponent extends TextComponent {
  final double damage;
  final bool isCrit;
  double _lifeTime = 0.8;
  final double _speed = 50.0;

  DamageTextComponent({
    required this.damage,
    required Vector2 position,
    this.isCrit = false,
  }) : super(
         text: damage.toInt().toString(),
         position: position,
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             color: isCrit ? Colors.red : Colors.white,
             fontSize: isCrit ? 24 : 16,
             fontWeight: FontWeight.bold,
             shadows: const [
               Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
             ],
           ),
         ),
       );

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime -= dt;
    position.y -= _speed * dt; // Float up

    // Fade out
    if (_lifeTime < 0.3) {
      textRenderer = TextPaint(
        style: (textRenderer as TextPaint).style.copyWith(
          color: (textRenderer as TextPaint).style.color!.withOpacity(
            _lifeTime / 0.3,
          ),
        ),
      );
    }

    if (_lifeTime <= 0) {
      removeFromParent();
    }
  }
}
