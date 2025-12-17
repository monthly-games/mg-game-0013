import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'game/arena_game.dart';
import 'features/league/league_manager.dart';
import 'features/hero/hero_data.dart';
import 'screens/battle_result_screen.dart';
import 'screens/inventory_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();
  runApp(const MyApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LeagueManager())],
      child: MaterialApp(
        title: 'Arena Legend',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const ArenaScreen(),
      ),
    );
  }
}

class ArenaScreen extends StatelessWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<LeagueManager>(
        builder: (context, lm, child) {
          // Show battle result screen
          if (lm.showingResult && lm.lastBattleResult != null) {
            return BattleResultScreen(
              result: lm.lastBattleResult!,
              onClose: () {
                lm.closeBattleResult();
              },
            );
          }

          // Show battle
          if (lm.inBattle) {
            return Stack(
              children: [
                GameWidget(
                  game: ArenaGame(
                    allies: lm.myTeam,
                    enemies: lm.enemyTeam,
                    onBattleEnd: (win) {
                      lm.endBattle(win);
                    },
                  ),
                ),
                // Overlay for battle info
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "BATTLE IN PROGRESS",
                      style: AppTextStyles.header2.copyWith(
                        color: AppColors.textHighEmphasis,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // Show lobby
          return _buildLobby(context, lm);
        },
      ),
    );
  }

  Widget _buildLobby(BuildContext context, LeagueManager lm) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Arena Legends",
                      style: AppTextStyles.header2,
                    ),
                    Text(
                      "${lm.currentTierData.nameKr} (${lm.leaguePoints} LP)",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Win Rate: ${(lm.winRate * 100).toStringAsFixed(1)}% (${lm.wins}W ${lm.losses}L)",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMediumEmphasis,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "💰 ${lm.gold}",
                      style: AppTextStyles.body.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "💎 ${lm.crystal}",
                      style: AppTextStyles.body.copyWith(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "🎫 ${lm.battleTickets}",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMediumEmphasis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.textDisabled),

          // My Team
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text("My Team (Max 5)", style: AppTextStyles.subHeader),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InventoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.inventory_2, size: 18),
                  label: const Text('INVENTORY'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lm.myTeam.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final hero = lm.myTeam[index];
                return _buildHeroCard(hero);
              },
            ),
          ),

          const Divider(color: AppColors.textDisabled),

          // Shop
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Mercenary Shop", style: AppTextStyles.subHeader),
                const Spacer(),
                ElevatedButton(
                  onPressed: lm.gold >= 10 ? lm.refreshShop : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lm.gold >= 10 ? AppColors.surface : AppColors.textDisabled,
                    foregroundColor: AppColors.textHighEmphasis,
                  ),
                  child: const Text("Refresh (10 💰)"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lm.shopList.length,
              itemBuilder: (_, index) {
                final hero = lm.shopList[index];
                final rarityStars = '⭐' * (hero.rarity.index + 1);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: AppColors.panel,
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getJobIcon(hero.job),
                          color: _getRarityColor(hero.rarity),
                          size: 32,
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(
                          hero.name,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRarityColor(hero.rarity),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rarityStars,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${hero.job.name.toUpperCase()} • ${hero.skill.name}",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMediumEmphasis,
                          ),
                        ),
                        Text(
                          "HP:${hero.maxHp.toInt()} ATK:${hero.attack.toInt()} DEF:${hero.defense.toInt()} SPD:${hero.speed.toInt()}",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textLowEmphasis,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lm.gold >= hero.cost
                            ? AppColors.secondary
                            : AppColors.textDisabled,
                        foregroundColor: AppColors.background,
                      ),
                      onPressed: lm.gold >= hero.cost
                          ? () => lm.recruit(hero)
                          : null,
                      child: Text("${hero.cost} 💰"),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: lm.myTeam.isNotEmpty ? lm.startBattle : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textHighEmphasis,
                ),
                child: const Text(
                  "ENTER LEAGUE MATCH",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(dynamic hero) {
    final rarityStars = '⭐' * (hero.rarity.index + 1);

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getRarityColor(hero.rarity), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getJobIcon(hero.job),
            size: 32,
            color: _getRarityColor(hero.rarity),
          ),
          const SizedBox(height: 4),
          Text(
            hero.name,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: _getRarityColor(hero.rarity),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rarityStars,
            style: const TextStyle(fontSize: 8),
          ),
          Text(
            hero.job.name,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMediumEmphasis,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getJobIcon(dynamic job) {
    switch (job.toString().split('.').last) {
      case 'warrior': return Icons.shield;
      case 'archer': return Icons.sports_baseball;
      case 'mage': return Icons.auto_fix_high;
      case 'tank': return Icons.security;
      case 'assassin': return Icons.flash_on;
      case 'healer': return Icons.favorite;
      default: return Icons.person;
    }
  }

  Color _getRarityColor(dynamic rarity) {
    switch (rarity.toString().split('.').last) {
      case 'common': return Colors.grey;
      case 'uncommon': return Colors.green;
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.amber;
      default: return Colors.white;
    }
  }
}
