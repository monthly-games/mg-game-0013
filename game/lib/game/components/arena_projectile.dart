import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'unit_component.dart';

class ArenaProjectile extends PositionComponent {
  final UnitComponent target;
  final double damage;
  final double speed = 400;
  final Color color;

  ArenaProjectile({
    required Vector2 position,
    required this.target,
    required this.damage,
    required this.color,
  }) : super(position: position, size: Vector2(10, 10), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (target.hp <= 0 || target.parent == null) {
      removeFromParent(); // Target dead/gone
      return;
    }

    final dir = (target.position - position).normalized();
    position += dir * speed * dt;

    if (position.distanceTo(target.position) < 15) {
      target.takeDamage(damage);
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(width / 2, height / 2), 4, Paint()..color = color);
  }
}
