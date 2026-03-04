import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'features/league/league_manager.dart';
import 'features/league/league_screen.dart';
import 'core/audio/audio_manager_impl.dart';
import 'game/pvp_manager.dart';
import 'game/ranking_manager.dart';
import 'game/character_manager.dart';

// ============================================================
// Arena Legend — MG-0013
// Genre: RPG (PvP Arena Fighter) · Region: Africa
// Phase 1 Week 3: Mechanic Enhancement
//
// Core loop: Recruit Heroes → Build Team → PvP Arena → Rank Up
// Subsystems: PvP rewards, Win streaks, Tier progression,
//             Season rewards, Character stat growth, Skill power
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeSystems();
  runApp(const ArenaLegendApp());
}

/// Initialize all DI-registered systems in correct dependency order.
/// mg_common_game systems first, then game-specific managers.
Future<void> _initializeSystems() async {
  final di = GetIt.I;

  // ── Core services ─────────────────────────────────────────
  if (!di.isRegistered<AudioManager>()) {
    di.registerSingleton<AudioManager>(AudioManagerImpl());
  }
  await di<AudioManager>().initialize();

  // ── mg_common_game: UpgradeManager ────────────────────────
  if (!di.isRegistered<UpgradeManager>()) {
    final upgrades = UpgradeManager();
    di.registerSingleton<UpgradeManager>(upgrades);
    _registerUpgrades(upgrades);
    await upgrades.loadUpgrades();
  }

  // ── Game-specific managers ────────────────────────────────
  if (!di.isRegistered<PvPManager>()) {
    di.registerSingleton<PvPManager>(PvPManager());
  }

  if (!di.isRegistered<RankingManager>()) {
    di.registerSingleton<RankingManager>(RankingManager());
  }

  if (!di.isRegistered<CharacterManager>()) {
    di.registerSingleton<CharacterManager>(CharacterManager());
  }

  // ── Existing league manager ───────────────────────────────
  final leagueManager = LeagueManager();
  await leagueManager.initialize();

  // Apply upgrade effects to managers after loading
  _applyUpgradeEffects(di<UpgradeManager>());
}

// ============================================================
// Upgrade Registration — 8 Arena Legend upgrades
// Categories: pvp (4), ranking (2), character (2)
// ============================================================

void _registerUpgrades(UpgradeManager manager) {
  // ── PvP upgrades (4) ──────────────────────────────────────

  // 1. Match Rewards — increases gold from PvP matches
  manager.registerUpgrade(Upgrade(
    id: 'match_rewards',
    name: 'War Spoils',
    description: 'Increase gold earned from arena matches by 10% per level.',
    maxLevel: 15,
    baseCost: 80,
    costMultiplier: 1.4,
    valuePerLevel: 0.10,
  ));

  // 2. Win Streak — amplifies consecutive win bonuses
  manager.registerUpgrade(Upgrade(
    id: 'win_streak',
    name: 'Momentum',
    description: 'Boost win streak bonus rewards by 15% per level.',
    maxLevel: 10,
    baseCost: 120,
    costMultiplier: 1.5,
    valuePerLevel: 0.15,
  ));

  // 3. Ranking Points — increases LP gained per victory
  manager.registerUpgrade(Upgrade(
    id: 'ranking_points',
    name: 'Glory Seeker',
    description: 'Increase league points earned per win by 12% per level.',
    maxLevel: 12,
    baseCost: 100,
    costMultiplier: 1.45,
    valuePerLevel: 0.12,
  ));

  // 4. Damage Boost — flat damage multiplier in PvP
  manager.registerUpgrade(Upgrade(
    id: 'damage_boost',
    name: 'Battle Fury',
    description: 'Increase team damage output by 5% per level.',
    maxLevel: 20,
    baseCost: 60,
    costMultiplier: 1.35,
    valuePerLevel: 0.05,
  ));

  // ── Ranking upgrades (2) ──────────────────────────────────

  // 5. Tier Bonus — boosts gold reward for tier promotions
  manager.registerUpgrade(Upgrade(
    id: 'tier_bonus',
    name: 'Prestige Reward',
    description: 'Increase tier promotion gold bonus by 10% per level.',
    maxLevel: 10,
    baseCost: 200,
    costMultiplier: 1.6,
    valuePerLevel: 0.10,
  ));

  // 6. Season Multiplier — boosts end-of-season rewards
  manager.registerUpgrade(Upgrade(
    id: 'season_multiplier',
    name: 'Season Veteran',
    description: 'Increase end-of-season rewards by 8% per level.',
    maxLevel: 8,
    baseCost: 300,
    costMultiplier: 1.7,
    valuePerLevel: 0.08,
  ));

  // ── Character upgrades (2) ────────────────────────────────

  // 7. Stat Growth — improves stat scaling on level-up
  manager.registerUpgrade(Upgrade(
    id: 'stat_growth',
    name: 'Hero Training',
    description: 'Increase hero stat growth per level-up by 5% per level.',
    maxLevel: 15,
    baseCost: 150,
    costMultiplier: 1.5,
    valuePerLevel: 0.05,
  ));

  // 8. Skill Power — amplifies skill damage/healing
  manager.registerUpgrade(Upgrade(
    id: 'skill_power',
    name: 'Skill Mastery',
    description: 'Increase skill effectiveness by 6% per level.',
    maxLevel: 12,
    baseCost: 180,
    costMultiplier: 1.55,
    valuePerLevel: 0.06,
  ));
}

/// Apply loaded upgrade levels to runtime managers.
void _applyUpgradeEffects(UpgradeManager upgradeManager) {
  // PvP damage multiplier is read live by PvPManager.getDamageMultiplier()
  // Ranking multipliers are read live by RankingManager methods
  // Character bonuses are read live by CharacterManager methods
  //
  // Log current upgrade state for debugging
  final upgrades = upgradeManager.allUpgrades;
  for (final upgrade in upgrades) {
    if (upgrade.currentLevel > 0) {
      debugPrint(
        'Arena Legend: ${upgrade.name} Lv.${upgrade.currentLevel} '
        '(value: ${upgrade.currentValue.toStringAsFixed(2)})',
      );
    }
  }
}

// ============================================================
// App Root — MultiProvider wraps all game state
// ============================================================

class ArenaLegendApp extends StatelessWidget {
  const ArenaLegendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeagueManager()),
        ChangeNotifierProvider.value(value: GetIt.I<UpgradeManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<PvPManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<RankingManager>()),
        ChangeNotifierProvider.value(value: GetIt.I<CharacterManager>()),
      ],
      child: MaterialApp(
        title: 'Arena Legend',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const ArenaHomeScreen(),
      ),
    );
  }

  /// Africa-region dark theme with Gold accents
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF16213E),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF0F3460),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ArenaHomeScreen — Main hub with upgrade panel integration
// Wraps LeagueScreen and provides upgrade access
// ============================================================

class ArenaHomeScreen extends StatefulWidget {
  const ArenaHomeScreen({super.key});

  @override
  State<ArenaHomeScreen> createState() => _ArenaHomeScreenState();
}

class _ArenaHomeScreenState extends State<ArenaHomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: const [
          LeagueScreen(),
          UpgradePanel(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        backgroundColor: const Color(0xFF16213E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upgrade),
            label: 'Upgrades',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UpgradePanel — Displays all 8 upgrades grouped by category
// Uses UpgradeManager from mg_common_game
// ============================================================

class UpgradePanel extends StatelessWidget {
  const UpgradePanel({super.key});

  static const _categoryLabels = {
    'pvp': 'PvP Combat',
    'ranking': 'Ranking & Seasons',
    'character': 'Character Growth',
  };

  static const _categoryIcons = {
    'pvp': Icons.local_fire_department,
    'ranking': Icons.emoji_events,
    'character': Icons.trending_up,
  };

  static const _upgradeCategories = {
    'match_rewards': 'pvp',
    'win_streak': 'pvp',
    'ranking_points': 'pvp',
    'damage_boost': 'pvp',
    'tier_bonus': 'ranking',
    'season_multiplier': 'ranking',
    'stat_growth': 'character',
    'skill_power': 'character',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrades'),
      ),
      body: Consumer<UpgradeManager>(
        builder: (context, upgradeManager, _) {
          final grouped = <String, List<Upgrade>>{};
          for (final upgrade in upgradeManager.allUpgrades) {
            final category = _upgradeCategories[upgrade.id] ?? 'other';
            grouped.putIfAbsent(category, () => []).add(upgrade);
          }

          return Consumer<LeagueManager>(
            builder: (context, leagueManager, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Currency display
                  _CurrencyHeader(gold: leagueManager.gold),
                  const SizedBox(height: 16),

                  // Grouped upgrade cards
                  for (final category in ['pvp', 'ranking', 'character'])
                    if (grouped.containsKey(category)) ...[
                      _CategoryHeader(
                        label: _categoryLabels[category] ?? category,
                        icon: _categoryIcons[category] ?? Icons.star,
                      ),
                      const SizedBox(height: 8),
                      ...grouped[category]!.map(
                        (upgrade) => _UpgradeCard(
                          upgrade: upgrade,
                          canAfford: upgradeManager.canAfford(
                            upgrade.id,
                            leagueManager.gold,
                          ),
                          onPurchase: () {
                            upgradeManager.purchaseUpgrade(
                              upgrade.id,
                              () => leagueManager.gold,
                              (cost) => leagueManager.addGold(-cost),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ── Private UI components for UpgradePanel ──────────────────

class _CurrencyHeader extends StatelessWidget {
  final int gold;
  const _CurrencyHeader({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Text(
            '$gold Gold',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _CategoryHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final Upgrade upgrade;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _UpgradeCard({
    required this.upgrade,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final isMaxed = upgrade.currentLevel >= upgrade.maxLevel;
    final cost = upgrade.costForNextLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Upgrade info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    upgrade.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    upgrade.description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Level indicator
                  Row(
                    children: [
                      Text(
                        'Lv.${upgrade.currentLevel}/${upgrade.maxLevel}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: upgrade.currentLevel / upgrade.maxLevel,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFFD700),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Purchase button
            SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: (canAfford && !isMaxed) ? onPurchase : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford && !isMaxed
                      ? const Color(0xFFFFD700)
                      : Colors.grey[700],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  isMaxed ? 'MAX' : '$cost',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
