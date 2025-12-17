import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../hero/hero_data.dart';
import '../skill/skill_data.dart';
import '../equipment/equipment_data.dart';
import 'league_data.dart';
import 'battle_result_data.dart';

class LeagueManager extends ChangeNotifier {
  // Resources
  int _gold = 1000;
  int _crystal = 100;
  int _battleTickets = 10;

  int get gold => _gold;
  int get crystal => _crystal;
  int get battleTickets => _battleTickets;

  // League System
  int _leaguePoints = 0;
  LeagueTier _currentTier = LeagueTier.bronze;
  int _wins = 0;
  int _losses = 0;
  final List<MatchData> _matchHistory = [];

  int get leaguePoints => _leaguePoints;
  LeagueTier get currentTier => _currentTier;
  LeagueTierData get currentTierData => LeagueTiers.getByTier(_currentTier);
  int get wins => _wins;
  int get losses => _losses;
  List<MatchData> get matchHistory => List.unmodifiable(_matchHistory);

  double get winRate {
    final total = _wins + _losses;
    return total > 0 ? _wins / total : 0.0;
  }

  // Season
  SeasonData? _currentSeason;
  SeasonData? get currentSeason => _currentSeason;

  // Team
  final List<HeroData> _myTeam = [];
  List<HeroData> get myTeam => List.unmodifiable(_myTeam);

  // Hero Inventory
  final List<HeroData> _heroInventory = [];
  List<HeroData> get heroInventory => List.unmodifiable(_heroInventory);

  // Equipment Inventory
  final List<EquipmentData> _equipmentInventory = [];
  List<EquipmentData> get equipmentInventory => List.unmodifiable(_equipmentInventory);

  // Shop
  final List<HeroData> _shopList = [];
  List<HeroData> get shopList => List.unmodifiable(_shopList);

  // Battle State
  final List<HeroData> _enemyTeam = [];
  List<HeroData> get enemyTeam => List.unmodifiable(_enemyTeam);

  bool _inBattle = false;
  bool get inBattle => _inBattle;

  // Battle Result
  BattleResultData? _lastBattleResult;
  BattleResultData? get lastBattleResult => _lastBattleResult;
  bool _showingResult = false;
  bool get showingResult => _showingResult;

  LeagueManager() {
    _initializeSeason();
    refreshShop();
  }

  /// Initialize season
  void _initializeSeason() {
    _currentSeason = SeasonData(
      seasonNumber: 1,
      name: 'Season 1',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      durationDays: 30,
    );
  }

  /// Start battle
  void startBattle() {
    if (_myTeam.isEmpty) return;
    if (_battleTickets <= 0) return;

    _battleTickets--;
    generateEnemyTeam();
    _inBattle = true;
    notifyListeners();
  }

  /// End battle and process results
  void endBattle(bool win, {int allyUnitsRemaining = 0, int enemyUnitsKilled = 0}) {
    _inBattle = false;

    // Store state before changes
    final previousPoints = _leaguePoints;
    final previousTier = _currentTier;

    // Determine opponent tier (same or ±1 tier for now)
    final rand = Random();
    final tierDiff = rand.nextInt(3) - 1; // -1, 0, or 1
    final opponentTierIndex = (_currentTier.index + tierDiff).clamp(0, LeagueTier.values.length - 1);
    final opponentTier = LeagueTier.values[opponentTierIndex];

    // Calculate points
    final tierData = currentTierData;
    int pointsChange = 0;
    int goldReward = 0;

    if (win) {
      _wins++;
      pointsChange = tierData.getWinPoints(opponentTier);
      goldReward = 100 + (_currentTier.index * 50);
      _gold += goldReward;
    } else {
      _losses++;
      pointsChange = -tierData.getLosePoints(opponentTier);
    }

    _leaguePoints = (_leaguePoints + pointsChange).clamp(0, 99999);

    // Check tier promotion/relegation
    _updateTier();

    // Record match history
    _matchHistory.add(MatchData(
      matchId: const Uuid().v4(),
      tier: _currentTier,
      timestamp: DateTime.now(),
      isWin: win,
      pointsGained: win ? pointsChange : 0,
      pointsLost: win ? 0 : pointsChange.abs(),
    ));

    // Create battle result data
    _lastBattleResult = BattleResultData(
      isVictory: win,
      goldEarned: goldReward,
      pointsChanged: pointsChange,
      previousPoints: previousPoints,
      newPoints: _leaguePoints,
      previousTier: previousTier,
      newTier: _currentTier,
      tierChanged: previousTier != _currentTier,
      totalWins: _wins,
      totalLosses: _losses,
      winRate: winRate,
      allyUnitsRemaining: allyUnitsRemaining,
      enemyUnitsKilled: enemyUnitsKilled,
    );

    _showingResult = true;
    notifyListeners();
  }

  /// Close battle result screen
  void closeBattleResult() {
    _showingResult = false;
    notifyListeners();
  }

  /// Update tier based on points
  void _updateTier() {
    final newTierData = LeagueTiers.getByPoints(_leaguePoints);
    if (newTierData.tier != _currentTier) {
      _currentTier = newTierData.tier;
      // Could trigger promotion/relegation rewards here
    }
  }

  /// Add resources
  void addGold(int amount) {
    _gold = (_gold + amount).clamp(0, 999999999);
    notifyListeners();
  }

  void addCrystal(int amount) {
    _crystal = (_crystal + amount).clamp(0, 999999999);
    notifyListeners();
  }

  void addBattleTickets(int amount) {
    _battleTickets = (_battleTickets + amount).clamp(0, 999);
    notifyListeners();
  }

  /// Shop Logic
  void refreshShop() {
    const rerollCost = 10;
    if (_gold < rerollCost) return;

    _gold -= rerollCost;
    _shopList.clear();

    // Generate 3-5 heroes based on tier
    final shopSize = 3 + (_currentTier.index ~/ 2).clamp(0, 2);
    for (int i = 0; i < shopSize; i++) {
      _shopList.add(HeroData.random());
    }
    notifyListeners();
  }

  /// Recruit hero from shop
  void recruit(HeroData hero) {
    if (_gold >= hero.cost) {
      if (_heroInventory.length >= 30) return; // Max inventory

      _gold -= hero.cost;
      _heroInventory.add(hero);
      _shopList.remove(hero);
      notifyListeners();
    }
  }

  /// Add hero to team
  void addToTeam(HeroData hero) {
    if (_myTeam.length >= 5) return; // Max team size
    if (!_heroInventory.contains(hero)) return;

    _myTeam.add(hero);
    notifyListeners();
  }

  /// Remove hero from team
  void removeFromTeam(HeroData hero) {
    _myTeam.remove(hero);
    notifyListeners();
  }

  /// Battle Logic - Generate enemy team
  void generateEnemyTeam() {
    _enemyTeam.clear();

    // Enemy count based on tier (3-5 units)
    final enemyCount = 3 + (_currentTier.index ~/ 2).clamp(0, 2);

    for (int i = 0; i < enemyCount; i++) {
      _enemyTeam.add(HeroData.random());
    }
    notifyListeners();
  }

  /// Claim daily rewards
  void claimDailyRewards() {
    final tierData = currentTierData;
    addGold(tierData.dailyGoldReward);
    addCrystal(tierData.dailyCrystalReward);
    notifyListeners();
  }

  /// End season and give rewards
  void endSeason() {
    if (_currentSeason == null) return;

    final tierData = currentTierData;
    addGold(tierData.seasonGoldReward);
    addCrystal(tierData.seasonCrystalReward);

    // Reset for new season
    _leaguePoints = 0;
    _currentTier = LeagueTier.bronze;
    _wins = 0;
    _losses = 0;
    _matchHistory.clear();

    _currentSeason = SeasonData.createNextSeason(_currentSeason!);
    notifyListeners();
  }
}
