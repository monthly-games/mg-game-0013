import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

enum UnitType { warrior, archer, mage }

class UnitComponent extends SpriteComponent with HasGameRef {
  final UnitType type;
  bool isPlayer;
  double hp = 100;
  final double maxHp = 100;

  // State
  UnitComponent? target;
  bool isDead = false;

  UnitComponent({required this.type, required this.isPlayer})
    : super(size: Vector2(48, 48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    String spriteName = 'unit_warrior.png';
    switch (type) {
      case UnitType.warrior:
        spriteName = 'unit_warrior.png';
        break;
      case UnitType.archer:
        spriteName = 'unit_archer.png';
        break;
      case UnitType.mage:
        spriteName = 'unit_mage.png';
        break; // Fallback to warrior if missing?
    }
    // Check if mage exists, if not use warrior as placeholder logic embedded in load could be complex,
    // relying on 'mage' file existing for now or will fail safely if I add fallback logic.
    // Let's use warrior as fallback for mage if not generated yet.
    try {
      sprite = await gameRef.loadSprite(spriteName);
    } catch (_) {
      sprite = await gameRef.loadSprite('unit_warrior.png');
    }

    if (!isPlayer) {
      // Flip enemy
      scale.x = -1;
    }
  }

  @override
  void update(double dt) {
    if (isDead) return;
    super.update(dt);

    if (target != null && !target!.isDead) {
      final dist = position.distanceTo(target!.position);
      final range = type == UnitType.warrior ? 60.0 : 200.0;

      if (dist <= range) {
        // Attack
        // Simple timer based attack can be added, for now just visualize "engaged"
      } else {
        // Move
        final dir = (target!.position - position).normalized();
        position += dir * 50 * dt;
      }
    }
  }

  void takeDamage(double amount) {
    if (isDead) return;
    hp -= amount;

    // Hit Flash
    add(
      ColorEffect(
        Colors.white,
        EffectController(duration: 0.1, alternate: true),
        opacityTo: 0.8,
      ),
    );

    if (hp <= 0) {
      isDead = true;
      hp = 0;
      add(OpacityEffect.fadeOut(EffectController(duration: 0.5)));
    }
  }
}
