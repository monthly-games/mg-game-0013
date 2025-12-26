import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Arena Legends: Mercenary League (MG-0013)
/// Auto-Battler + League PVP 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Battle Effects
  void showAttackHit(Vector2 position, {Color color = Colors.white, bool isCritical = false}) {
    gameRef.add(_createHitEffect(position: position, color: color, isCritical: isCritical));
    if (isCritical) gameRef.add(_createSparkleEffect(position: position, color: Colors.yellow, count: 12));
  }

  void showDamageNumber(Vector2 position, int damage, {bool isCritical = false}) {
    gameRef.add(_DamageNumber(position: position, damage: damage, isCritical: isCritical));
  }

  void showSkillActivation(Vector2 position, Color skillColor) {
    gameRef.add(_createConvergeEffect(position: position, color: skillColor));
    gameRef.add(_createGroundCircle(position: position, color: skillColor));
  }

  void showUnitDeath(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.red, count: 20, radius: 50));
    gameRef.add(_createSmokeEffect(position: position, count: 6));
  }

  // League/Ranking Effects
  void showLeagueRankUp(Vector2 position, String newRank) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 40, radius: 80));
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;
        gameRef.add(_createSparkleEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 80, (_random.nextDouble() - 0.5) * 60), color: Colors.yellow, count: 8));
      });
    }
    gameRef.add(_RankUpText(position: position, rank: newRank));
    _triggerScreenShake(intensity: 5, duration: 0.4);
  }

  void showSeasonReward(Vector2 position) {
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!isMounted) return;
        gameRef.add(_createCoinEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 100, -20), count: 5));
      });
    }
    gameRef.add(_createSparkleEffect(position: position, color: Colors.amber, count: 25));
  }

  void showBattleResult(Vector2 position, {required bool isVictory}) {
    if (isVictory) {
      gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 35, radius: 70));
      gameRef.add(_VictoryText(position: position));
    } else {
      gameRef.add(_createSmokeEffect(position: position, count: 15));
      gameRef.add(_DefeatText(position: position));
    }
  }

  void showTeamFormation(Vector2 position) {
    gameRef.add(_createSparkleEffect(position: position, color: Colors.cyan, count: 15));
    gameRef.add(_createGroundCircle(position: position, color: Colors.blue));
  }

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  void _triggerScreenShake({double intensity = 5, double duration = 0.3}) {
    if (gameRef.camera.viewfinder.children.isNotEmpty) {
      gameRef.camera.viewfinder.add(MoveByEffect(Vector2(intensity, 0), EffectController(duration: duration / 10, repeatCount: (duration * 10).toInt(), alternate: true)));
    }
  }

  // Private generators
  ParticleSystemComponent _createHitEffect({required Vector2 position, required Color color, required bool isCritical}) {
    final count = isCritical ? 20 : 12; final speed = isCritical ? 140.0 : 100.0;
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.4, generator: (i) {
      final angle = (i / count) * 2 * pi;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5)), acceleration: Vector2(0, 200), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, (isCritical ? 5 : 3) * (1.0 - particle.progress * 0.5), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 100), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 12, lifespan: 0.5, generator: (i) {
      final startAngle = (i / 12) * 2 * pi; final startPos = Vector2(cos(startAngle), sin(startAngle)) * 50;
      return MovingParticle(from: position + startPos, to: position.clone(), child: ComputedParticle(renderer: (canvas, particle) {
        canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity((1.0 - particle.progress * 0.5).clamp(0.0, 1.0)));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.5, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = 50 + _random.nextDouble() * 40;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 40), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path(); for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) {
          path.moveTo(cos(a) * size, sin(a) * size);
        } else {
          path.lineTo(cos(a) * size, sin(a) * size);
        } } path.close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createSmokeEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.8, generator: (i) {
      return AcceleratedParticle(position: position.clone() + Vector2((_random.nextDouble() - 0.5) * 25, 0), speed: Vector2((_random.nextDouble() - 0.5) * 15, -30 - _random.nextDouble() * 20), acceleration: Vector2(0, -10), child: ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (0.5 - progress * 0.5).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 6 + progress * 10, Paint()..color = Colors.grey.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 1, lifespan: 0.6, generator: (i) {
      return ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (1.0 - progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(position.x, position.y), 15 + progress * 35, Paint()..color = color.withOpacity(opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
      });
    }));
  }

  ParticleSystemComponent _createCoinEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 4; final speed = 130 + _random.nextDouble() * 80;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 350), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress * 0.2).clamp(0.0, 1.0);
        canvas.save(); canvas.rotate(particle.progress * 3 * pi);
        canvas.drawOval(const Rect.fromLTWH(-3, -2, 6, 4), Paint()..color = Colors.amber.withOpacity(opacity));
        canvas.restore();
      }));
    }));
  }
}

class _DamageNumber extends TextComponent {
  _DamageNumber({required Vector2 position, required int damage, required bool isCritical}) : super(text: '$damage', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: isCritical ? 26 : 18, fontWeight: FontWeight.bold, color: isCritical ? Colors.yellow : Colors.white, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -45), EffectController(duration: 0.7, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.7, startDelay: 0.2))); add(RemoveEffect(delay: 0.9)); }
}

class _VictoryText extends TextComponent {
  _VictoryText({required Vector2 position}) : super(text: 'VICTORY!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 3, shadows: [Shadow(color: Colors.orange, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.elasticOut))); add(RemoveEffect(delay: 3.0)); }
}

class _DefeatText extends TextComponent {
  _DefeatText({required Vector2 position}) : super(text: 'DEFEAT', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2)));
  @override Future<void> onLoad() async { await super.onLoad(); add(OpacityEffect.fadeIn(EffectController(duration: 1.0))); add(RemoveEffect(delay: 3.0)); }
}

class _RankUpText extends TextComponent {
  _RankUpText({required Vector2 position, required String rank}) : super(text: 'RANK UP!\n$rank', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [Shadow(color: Colors.orange, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.4, curve: Curves.elasticOut))); add(RemoveEffect(delay: 2.5)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}
