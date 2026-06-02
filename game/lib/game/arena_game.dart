import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'components/unit_component.dart';
import 'components/combo_display_component.dart';
import '../features/hero/hero_data.dart';
import 'combo_system.dart';

class ArenaGame extends FlameGame {
  final List<HeroData> allies;
  final List<HeroData> enemies;
  final Function(bool) onBattleEnd;

  ArenaGame({
    required this.allies,
    required this.enemies,
    required this.onBattleEnd,
  });

  @override
  Color backgroundColor() => Colors.green.shade900;

  bool _isGameOver = false;
  double _endTimer = 0.0;
  late final ComboSystem comboSystem;

  @override
  Future<void> onLoad() async {
    // Initialize combo system
    comboSystem = ComboSystem();

    try {
      GetIt.I<AudioManager>().playBgm('bgm_battle.mp3');
    } catch (_) {}

    // Spawn Allies (Left side)
    for (int i = 0; i < allies.length; i++) {
      add(
        UnitComponent(
          team: UnitTeam.ally,
          data: allies[i],
          position: Vector2(100, 100.0 + i * 50),
        ),
      );
    }

    // Spawn Enemies (Right side)
    for (int i = 0; i < enemies.length; i++) {
      add(
        UnitComponent(
          team: UnitTeam.enemy,
          data: enemies[i],
          position: Vector2(600, 100.0 + i * 50),
        ),
      );
    }

    // Add combo display
    add(ComboDisplayComponent());
  }

  @override
  void onRemove() {
    try {
      GetIt.I<AudioManager>().stopBgm();
    } catch (_) {}
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update combo system
    comboSystem.update(dt);

    if (_isGameOver) {
      _endTimer += dt;
      if (_endTimer > 1.5) {
        // 1.5s delay
        final hasAllies = children.query<UnitComponent>().any(
          (u) => u.team == UnitTeam.ally,
        );
        onBattleEnd(hasAllies);
      }
      return;
    }

    // Check conditions
    final units = children.query<UnitComponent>();
    final hasAllies = units.any((u) => u.team == UnitTeam.ally);
    final hasEnemies = units.any((u) => u.team == UnitTeam.enemy);

    if (!hasAllies || !hasEnemies) {
      _isGameOver = true;
    }
  }
}
