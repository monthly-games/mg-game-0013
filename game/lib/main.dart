import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'features/league/league_manager.dart';
import 'features/league/league_screen.dart';
import 'core/audio/audio_manager_impl.dart';
import 'game/pvp_manager.dart';
import 'game/ranking_manager.dart';
import 'game/character_manager.dart';
import 'screens/gacha_screen.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/battlepass_screen.dart';
import 'screens/collection_screen.dart';

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
  // Gacha 시스템
  GetIt.I.registerSingleton(GachaManager());
  // Achievement 시스템
  GetIt.I.registerSingleton(AchievementManager());
  // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
    _registerCollections();
  }
  _registerAchievements();
  _setupGacha();

  // ── DailyQuest system ──────────────────────────────────────
  if (!GetIt.I.isRegistered<DailyQuestManager>()) {
    final questManager = DailyQuestManager();
    GetIt.I.registerSingleton(questManager);
    // Register arena-specific daily quests
    questManager.registerQuest(DailyQuest(
      id: 'arena_3_matches',
      title: 'Arena Warrior',
      description: 'Complete 3 arena matches',
      targetValue: 3,
      goldReward: 150,
      xpReward: 75,
    ));
    questManager.registerQuest(DailyQuest(
      id: 'arena_win_streak_3',
      title: 'Winning Streak',
      description: 'Win 3 matches in a row',
      targetValue: 3,
      goldReward: 250,
      xpReward: 125,
    ));
  }

  // ── Retention Systems for DailyHub ────────────────────────
  if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
    GetIt.I.registerSingleton(LoginRewardsManager());
  }
  if (!GetIt.I.isRegistered<StreakManager>()) {
    GetIt.I.registerSingleton(StreakManager());
  }
  if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
    GetIt.I.registerSingleton(DailyChallengeManager());
}
  // ── P3 Engine Systems ─────────────────────────────────────
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton(SeasonalContentManager());
  }

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
        routes: {
          '/gacha': (_) => const GachaScreen(),
          '/daily_quest': (_) => const DailyQuestScreen(),
          '/achievement': (_) => const AchievementScreen(),
          '/battlepass': (_) => const BattlePassScreen(),
          '/daily-hub': (context) => DailyHubScreen(
            questManager: GetIt.I<DailyQuestManager>(),
            loginRewardsManager: GetIt.I<LoginRewardsManager>(),
            streakManager: GetIt.I<StreakManager>(),
            challengeManager: GetIt.I<DailyChallengeManager>(),
            accentColor: MGColors.gold,
            onClose: () => Navigator.pop(context),
          ),
        
          '/collection': (context) => CollectionScreen(
            collectionManager: GetIt.I<CollectionManager>(),
          ),
          '/guild-war': (context) => GuildWarScreen(
            guildWarManager: GetIt.I<GuildWarManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
          '/tournament': (context) => TournamentScreen(
            tournamentManager: GetIt.I<TournamentManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
          '/seasonal-event': (context) => SeasonalEventScreen(
            seasonalContentManager: GetIt.I<SeasonalContentManager>(),
            accentColor: MGColors.primaryAction,
            onClose: () => Navigator.pop(context),
            ),
},
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
        selectedItemColor: MGColors.gold,
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
          const Icon(Icons.monetization_on, color: MGColors.gold),
          const SizedBox(width: 8),
          Text(
            '$gold Gold',
            style: const TextStyle(
              color: MGColors.gold,
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
        Icon(icon, color: MGColors.gold, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: MGColors.textHighEmphasis,
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
                      color: MGColors.textHighEmphasis,
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
                          color: MGColors.gold,
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
                              MGColors.gold,
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
                      ? MGColors.gold
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


void _setupGacha() {
  final gacha = GetIt.I<GachaManager>();

  gacha.registerPool(GachaPool(
    id: 'standard_pool',
    nameKr: '스탠다드 뽑기',
    items: [
      // N (50%)
      ...List.generate(20, (i) => GachaItem(
        id: 'n_item_$i',
        nameKr: '일반 아이템 $i',
        rarity: GachaRarity.normal,
      )),

      // R (35%)
      ...List.generate(10, (i) => GachaItem(
        id: 'r_item_$i',
        nameKr: '레어 아이템 $i',
        rarity: GachaRarity.rare,
      )),

      // SR (12%)
      ...List.generate(5, (i) => GachaItem(
        id: 'sr_item_$i',
        nameKr: '슈퍼레어 아이템 $i',
        rarity: GachaRarity.superRare,
      )),

      // SSR (2.7%)
      const GachaItem(
        id: 'ssr_item_1',
        nameKr: '울트라레어 아이템 1',
        rarity: GachaRarity.ultraRare,
      ),

      // UR (0.3%)
      const GachaItem(
        id: 'ur_item_1',
        nameKr: '레전더리 아이템 1',
        rarity: GachaRarity.legendary,
      ),
    ],
  ));
}


void _registerAchievements() {
  final achievement = GetIt.I<AchievementManager>();
  
  achievement.registerAchievement(Achievement(
    id: 'gold_1000',
    title: '골드 1000 달성',
    description: '총 골드 1000을 모으세요',
    iconAsset: 'assets/achievements/gold_1000.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'level_10',
    title: '레벨 10 달성',
    description: '레벨 10에 도달하세요',
    iconAsset: 'assets/achievements/level_10.png',
  ));
  
  achievement.registerAchievement(Achievement(
    id: 'play_100',
    title: '100판 플레이',
    description: '게임을 100판 플레이하세요',
    iconAsset: 'assets/achievements/play_100.png',
  ));
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters 컬렉션
  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      const CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      const CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      const CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: const CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: const CollectionReward(type: RewardType.gold, amount: 1000),
      50: const CollectionReward(type: RewardType.gold, amount: 3000),
      75: const CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}
