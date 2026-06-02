import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
import 'dart:math';
import '../../arena_game.dart';
import '../../combo_system.dart';
import 'combo_milestone_effect.dart';

/// Visual display component for combo system
/// Shows current combo count, tier, and multiplier
class ComboDisplayComponent extends PositionComponent with HasGameReference<ArenaGame> {
  ComboDisplayComponent()
      : super(
          position: Vector2(20, 20),
          size: Vector2(200, 80),
          anchor: Anchor.topLeft,
        );

  TextPainter _comboTextPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
  );

  TextPainter _tierTextPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
  );

  TextPainter _multiplierTextPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.left,
  );

  double _scale = 1.0;
  int _lastCombo = 0;
  String _lastTier = '';

  @override
  void update(double dt) {
    super.update(dt);

    final comboSystem = game.comboSystem;
    final currentCombo = comboSystem.currentCombo;
    final currentTier = comboSystem.getComboTierName();

    // Trigger animation on combo milestone
    if (currentCombo != _lastCombo || currentTier != _lastTier) {
      if (comboSystem.isTierMilestone() && currentCombo > 0) {
        _triggerTierMilestoneEffect();
      } else if (currentCombo > _lastCombo && currentCombo % 5 == 0) {
        _triggerComboGrowthEffect();
      }

      _lastCombo = currentCombo;
      _lastTier = currentTier;
    }

    // Update scale animation
    if (_scale > 1.0) {
      _scale -= dt * 2.0;
      if (_scale < 1.0) _scale = 1.0;
    }
  }

  void _triggerTierMilestoneEffect() {
    _scale = 1.5;
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.3,
          startDelay: 0.2,
        ),
      ),
    );

    // Spawn milestone effect
    final comboSystem = game.comboSystem;
    final tierColor = Color(comboSystem.getComboTierColor());
    final tierName = comboSystem.getComboTierName();

    game.add(
      ComboMilestoneEffect(
        tierName: tierName,
        comboCount: comboSystem.currentCombo,
        tierColor: tierColor,
        position: Vector2(game.size.x / 2, game.size.y / 2),
      ),
    );
  }

  void _triggerComboGrowthEffect() {
    _scale = 1.2;
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.2,
          startDelay: 0.1,
        ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    final comboSystem = game.comboSystem;
    final currentCombo = comboSystem.currentCombo;

    // Don't render if no combo
    if (currentCombo == 0) return;

    final tierColor = Color(comboSystem.getComboTierColor());
    final tierName = comboSystem.getComboTierName();
    final multiplier = comboSystem.getComboMultiplier();
    final skillsUsed = comboSystem.skillsUsedInCombo;

    // Apply scale
    canvas.save();
    canvas.scale(_scale);

    // Background panel with tier color
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
    final borderPaint = Paint()
      ..color = tierColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(8),
    );

    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, borderPaint);

    // Combo count
    _comboTextPainter.text = TextSpan(
      text: 'COMBO x$currentCombo',
      style: TextStyle(
        color: tierColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: tierColor.withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
    );
    _comboTextPainter.layout();
    _comboTextPainter.paint(canvas, const Offset(10, 10));

    // Tier name
    _tierTextPainter.text = TextSpan(
      text: tierName,
      style: TextStyle(
        color: tierColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.0,
      ),
    );
    _tierTextPainter.layout();
    _tierTextPainter.paint(canvas, Offset(10, 45));

    // Multiplier
    _multiplierTextPainter.text = TextSpan(
      text: '${multiplier.toStringAsFixed(1)}x DMG',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
    _multiplierTextPainter.layout();
    _multiplierTextPainter.paint(canvas, Offset(130, 45));

    // Skills used indicator
    if (skillsUsed > 0) {
      final skillTextPainter = TextPainter(
        text: TextSpan(
          text: 'Skills: $skillsUsed',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      skillTextPainter.layout();
      skillTextPainter.paint(canvas, Offset(10, 68));
    }

    canvas.restore();
  }

  @override
  void onRemove() {
    _comboTextPainter.dispose();
    _tierTextPainter.dispose();
    _multiplierTextPainter.dispose();
    super.onRemove();
  }
}