import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/game/character_manager.dart';
import 'package:game/game/ranking_manager.dart';
import 'package:game/main.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AudioManager>(
      AudioManager(
        playBgmDirect: (_, {double volume = 1.0}) {},
        stopBgmDirect: () {},
        pauseBgmDirect: () {},
        resumeBgmDirect: () {},
      ),
    );
    GetIt.I.registerSingleton<UpgradeManager>(UpgradeManager());
    GetIt.I.registerSingleton<RankingManager>(RankingManager());
    GetIt.I.registerSingleton<CharacterManager>(CharacterManager());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('ArenaLegendApp builds the league home screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));

    await tester.pumpWidget(const ArenaLegendApp());
    await tester.pump();

    expect(find.text('ARENA LEGEND'), findsOneWidget);
    expect(find.text('ENTER ARENA'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
