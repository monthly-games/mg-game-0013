import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../../features/hero/hero_data.dart';
import '../../game/components/unit_component.dart';

class BattleScene extends FlameGame {
  final Function(bool isWin) onBattleEnd;
  final List<HeroData> myTeam;
  final List<HeroData> enemyTeam;

  BattleScene({
    required this.onBattleEnd,
    required this.myTeam,
    required this.enemyTeam,
  });

  @override
  Color backgroundColor() => const Color(0xFF554433); // Sand-ish

  @override
  Future<void> onLoad() async {
    // BG
    add(
      SpriteComponent()
        ..sprite = await loadSprite('bg_arena.png')
        ..size = size
        ..priority = 0,
    );

    // Spawn My Team (Left)
    for (int i = 0; i < myTeam.length; i++) {
      spawnUnit(
        myTeam[i],
        true,
        Vector2(100, size.y / 2 + (i - myTeam.length / 2) * 60),
      );
    }

    // Spawn Enemy Team (Right)
    for (int i = 0; i < enemyTeam.length; i++) {
      spawnUnit(
        enemyTeam[i],
        false,
        Vector2(size.x - 100, size.y / 2 + (i - enemyTeam.length / 2) * 60),
      );
    }

    // Play Battle BGM
    GetIt.I<AudioManager>().playBgm('bgm_battle.mp3');
  }

  @override
  void onRemove() {
    // Switch back to menu BGM
    GetIt.I<AudioManager>().playBgm('bgm_main.mp3');
    super.onRemove();
  }

  void spawnUnit(HeroData data, bool isPlayer, Vector2 pos) {
    add(
      UnitComponent(
        team: isPlayer ? UnitTeam.ally : UnitTeam.enemy,
        data: data,
        position: pos,
      )..priority = 10,
    );
  }

  bool _isBattleEnding = false;
  bool _paused = false;

  @override
  void updateTree(double dt) {
    if (_paused) return; // Stop updating if paused
    super.updateTree(dt);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isBattleEnding) return;

    // Check for Battle End
    final units = children.whereType<UnitComponent>();
    final playerUnits = units
        .where((u) => u.team == UnitTeam.ally && !u.isDead)
        .toList();
    final enemyUnits = units
        .where((u) => u.team == UnitTeam.enemy && !u.isDead)
        .toList();

    if (playerUnits.isEmpty || enemyUnits.isEmpty) {
      // Debounce

      // Determine winner: usage of state here is just immediate logic
      // If players are empty -> Loss, if Enemies empty -> Win
      // If both empty (draw) -> Loss for now
      final isWin = playerUnits.isNotEmpty;

      _isBattleEnding = true;

      async.Timer(const Duration(seconds: 2), () {
        _paused = true;

        // Play Result Audio
        if (isWin) {
          GetIt.I<AudioManager>().playSfx('victory.wav');
          GetIt.I<AudioManager>().playBgm('music/victory_theme.mp3');
        } else {
          GetIt.I<AudioManager>().playSfx('defeat.wav');
          // Maybe play lobby theme or silence? Keep as is (battle bgm stops/continues?)
          // Battle BGM is playing. Defeat SFX is long?
        }

        if (buildContext != null) {
          showDialog(
            context: buildContext!,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: isWin ? Colors.blue[900] : Colors.red[900],
              title: Text(
                isWin ? "VICTORY" : "DEFEAT",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isWin ? "Rewards: 100 Gold, 25 LP" : "Lost 10 LP",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onBattleEnd(isWin);
                    },
                    child: const Text("Continue"),
                  ),
                ],
              ),
            ),
          );
        } else {
          onBattleEnd(isWin);
        }
      });
    }
  }
}
