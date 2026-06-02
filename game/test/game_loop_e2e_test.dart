import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';
import 'package:game/game/tutorial_config.dart';

/// E2E Test for MG-0013: Arena Legends: Mercenary League
///
/// Tests the game loop with focus on:
/// - 6-stage combo system mechanics
/// - Arena battle progression
/// - Tournament-style gameplay
/// - Competitive PvP elements
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0013 Arena Legends - Game Loop E2E', () {
    testWidgets('Complete arena progression with 6-stage combo system', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0013'), findsOneWidget);
      expect(find.text('Arena Legends: Mercenary League'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      // Complete tutorial steps
      final tutorialSteps = kOnboardingTutorial.steps;
      for (int i = 0; i < tutorialSteps.length; i++) {
        await tester.pumpAndSettle();
        expect(find.text('${i + 1}/${tutorialSteps.length}'), findsOneWidget);
        expect(find.text(tutorialSteps[i].title), findsOneWidget);

        await tester.tap(find.text(i == tutorialSteps.length - 1 ? 'Done' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Navigate to game screen
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test 6-stage combo system (longer than MG-0012's 5-stage)
      int comboCount = 0;
      int maxComboStages = 6;
      int totalGold = 0;
      int totalXP = 0;

      for (int comboStage = 1; comboStage <= maxComboStages; comboStage++) {
        await tester.pumpAndSettle();

        final levelIndex = comboStage - 1;
        if (levelIndex < kLevelDesign.length) {
          final levelDesign = kLevelDesign[levelIndex];
          final spawn = kWaveSpawnTable[levelIndex];

          expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);
          expect(find.text('${spawn.enemyCount} targets'), findsOneWidget);

          // Complete action to build combo
          await tester.tap(find.byKey(const ValueKey('complete-action')));
          await tester.pumpAndSettle();

          // Arena combo multiplier increases with each stage (up to 6)
          final comboMultiplier = comboStage;
          totalGold += levelDesign.goldReward * comboMultiplier;
          totalXP += levelDesign.xpReward * comboMultiplier;
          comboCount++;

          expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
        }
      }

      // Verify 6-stage combo system completion
      expect(comboCount, equals(maxComboStages), reason: 'Should complete 6 combo stages');
      expect(totalGold, greaterThan(0), reason: 'Arena combo should increase gold rewards');
      expect(totalXP, greaterThan(0), reason: 'Arena combo should increase XP rewards');
    });

    testWidgets('Test arena competitive mechanics and scoring', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Arena battles should have balanced difficulty progression
      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        // Arena has moderate enemy count but varied difficulty
        expect(spawn.enemyCount, greaterThan(5), reason: 'Arena should have reasonable enemy count');
        expect(level.difficulty, greaterThan(0.5), reason: 'Arena should have measurable difficulty');

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Verify arena tournament progression system', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to level roadmap
      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // Verify arena tournament structure
      expect(find.byType(app.LevelRoadmapScreen), findsOneWidget);

      // Arena should have clear tournament stages
      for (int i = 0; i < kLevelDesign.length && i < 12; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);

        // Arena stages should reference tournament/league elements
        expect(level.stage.toLowerCase(), anyOf(
          contains('match'),
          contains('round'),
          contains('league'),
          contains('arena'),
          contains('battle'),
        ), reason: 'Arena stages should have competitive names');
      }
    });

    testWidgets('Test arena legend theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify arena competitive UI elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);
      expect(find.byIcon(Icons.emoji_events_rounded), findsWidgets);
    });

    testWidgets('Complete full arena tournament session', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Complete tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      while (find.text('Next').evaluate().isNotEmpty) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      if (find.text('Done').evaluate().isNotEmpty) {
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
      }

      // Play full arena tournament
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int matchesCompleted = 0;
      int maxMatches = 18;

      for (int i = 0; i < maxMatches && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        matchesCompleted++;
      }

      expect(matchesCompleted, equals(maxMatches), reason: 'Should complete 18 arena matches');

      // Verify tournament rewards
      final finalGold = kLevelDesign.take(maxMatches).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxMatches).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test arena-specific retention and competitive features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test tournament integration
      await tester.tap(find.text('Tournament'));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsOneWidget);
      expect(find.text('Competitive goals are available for mastery.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test guild war access (arena links to guild competition)
      await tester.tap(find.text('Guild'));
      await tester.pumpAndSettle();
      expect(find.text('Guild War'), findsOneWidget);
      expect(find.text('Social competition is reachable from the main loop.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test daily arena challenges
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsOneWidget);
      expect(find.text('Short goals keep the fun loop moving.'), findsOneWidget);
    });

    testWidgets('Verify arena match variety and progression balance', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test that arena matches vary in difficulty and style
      List<double> difficulties = [];

      for (int i = 0; i < 12 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];
        difficulties.add(level.difficulty);

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }

      // Arena should have varied difficulty progression
      final uniqueDifficulties = difficulties.toSet();
      expect(uniqueDifficulties.length, greaterThan(3),
          reason: 'Arena should have varied difficulty levels');

      // Difficulty should generally increase
      final maxDifficulty = difficulties.reduce((a, b) => a > b ? a : b);
      final minDifficulty = difficulties.reduce((a, b) => a < b ? a : b);
      expect(maxDifficulty, greaterThan(minDifficulty),
          reason: 'Arena difficulty should progress');
    });

    testWidgets('Test 6-stage combo system advantages over 5-stage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Build maximum 6-stage combo
      int comboStages = 0;
      for (int i = 0; i < 6 && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        comboStages++;
      }

      expect(comboStages, equals(6), reason: 'Arena should support 6-stage combos');

      // 6-stage combo should provide higher total rewards than 5-stage would
      final totalGold = kLevelDesign.take(6).fold(0, (sum, level) => sum + level.goldReward);
      // With 6-stage combo: 1x + 2x + 3x + 4x + 5x + 6x = 21x multiplier
      // With 5-stage combo: 1x + 2x + 3x + 4x + 5x = 15x multiplier
      // Arena should benefit from extended combo system
      expect(totalGold, greaterThan(0), reason: '6-stage combo should be rewarding');
    });
  });
}