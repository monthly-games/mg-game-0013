import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../../features/hero/hero_data.dart';
import '../../features/recruit/recruit_screen.dart';
import '../../features/hero/inventory_screen.dart';
import 'league_manager.dart';
import '../battle/battle_scene.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  bool _inBattle = false;
  // No local instantiation, use Provider

  void _startBattle() {
    setState(() {
      _inBattle = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // Play Menu BGM
    GetIt.I<AudioManager>().playBgm('bgm_main.mp3');
  }

  void _onBattleEnd(bool isWin) {
    setState(() {
      _inBattle = false;
      final leagueManager = Provider.of<LeagueManager>(context, listen: false);

      if (isWin) {
        GetIt.I<AudioManager>().playSfx('coin.wav');
        leagueManager.addReward(100, 25); // 100 Gold, 25 LP
      } else {
        leagueManager.addLp(-10);
      }

      // Spend ticket
      leagueManager.spendTicket();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access provider
    final leagueManager = Provider.of<LeagueManager>(context);

    if (_inBattle) {
      // Generate random enemy team for now
      final enemyTeam = List.generate(
        5,
        (_) => HeroData.random().copyWith(level: 1),
      );

      return GameWidget(
        game: BattleScene(
          onBattleEnd: _onBattleEnd,
          myTeam: leagueManager.myTeam,
          enemyTeam: enemyTeam,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Consumer<LeagueManager>(
        builder: (context, leagueManager, child) {
          final div = leagueManager.currentDivision;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ARENA LEGEND",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Division Icon
                Image.asset(
                  _getDivAssetPath(div),
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  div.label,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${leagueManager.currentLp} LP",
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),

                const SizedBox(height: 20),
                // Inventory / Team Summary
                Text(
                  "Gold: ${leagueManager.gold} | Tickets: ${leagueManager.tickets}",
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 10),
                Text(
                  "Team Size: ${leagueManager.myTeam.length}/5",
                  style: const TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 40),

                // Battle Button
                ElevatedButton(
                  onPressed: () {
                    if (leagueManager.tickets > 0) {
                      _startBattle();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: leagueManager.tickets > 0
                        ? Colors.redAccent
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    "ENTER ARENA",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Management Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: const Text("Manage Team"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecruitScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text("Recruit"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDivAssetPath(LeagueDivision div) {
    switch (div) {
      case LeagueDivision.bronze:
        return 'assets/images/ui/tier_bronze.png';
      case LeagueDivision.silver:
        return 'assets/images/ui/tier_silver.png';
      case LeagueDivision.gold:
        return 'assets/images/ui/tier_gold.png';
      case LeagueDivision.platinum:
        return 'assets/images/ui/tier_platinum.png';
      case LeagueDivision.diamond:
        return 'assets/images/ui/tier_diamond.png';
      case LeagueDivision.master:
        return 'assets/images/ui/tier_master.png';
    }
  }
}
