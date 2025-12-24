import 'package:flutter/foundation.dart';
import '../../core/storage/storage_service.dart';
import '../hero/hero_data.dart';

enum LeagueDivision {
  bronze(0, "Bronze"),
  silver(100, "Silver"),
  gold(250, "Gold"),
  platinum(500, "Platinum"),
  diamond(800, "Diamond"),
  master(1200, "Master");

  final int minLp;
  final String label;
  const LeagueDivision(this.minLp, this.label);
}

class LeagueManager with ChangeNotifier {
  // Singleton
  static final LeagueManager _instance = LeagueManager._internal();
  factory LeagueManager() => _instance;
  LeagueManager._internal();

  final StorageService _storage = StorageService();

  // Currencies
  int _gold = 0;
  int get gold => _gold;

  int _crystals = 0;
  int get crystals => _crystals;

  int _tickets = 0;
  int get tickets => _tickets;

  // League
  int _currentLp = 0;
  int get currentLp => _currentLp;

  LeagueDivision get currentDivision {
    for (var div in LeagueDivision.values.reversed) {
      if (_currentLp >= div.minLp) return div;
    }
    return LeagueDivision.bronze;
  }

  // Inventory
  List<HeroData> _heroes = [];
  List<HeroData> get heroes => List.unmodifiable(_heroes);

  List<String> _myTeamIds = [];
  List<HeroData> get myTeam {
    return _myTeamIds
        .map(
          (id) => _heroes.firstWhere(
            (h) => h.id == id,
            orElse: () => _heroes.first,
          ),
        )
        .toList();
  }

  Future<void> initialize() async {
    await _storage.initialize();

    _gold = _storage.gold;
    _crystals = _storage.crystals;
    _tickets = _storage.tickets;
    _currentLp = _storage.lp;

    _heroes = _storage.getHeroes();
    _myTeamIds = _storage.getMyTeam();

    // Starter pack if empty
    if (_heroes.isEmpty) {
      _heroes.add(
        HeroData.random().copyWith(
          job: HeroJob.warrior,
          rarity: HeroRarity.common,
        ),
      );
      _heroes.add(
        HeroData.random().copyWith(
          job: HeroJob.archer,
          rarity: HeroRarity.common,
        ),
      );
      _heroes.add(
        HeroData.random().copyWith(
          job: HeroJob.healer,
          rarity: HeroRarity.common,
        ),
      );
      await _storage.saveHeroes(_heroes);
    }

    if (_myTeamIds.isEmpty && _heroes.isNotEmpty) {
      _myTeamIds = _heroes.take(5).map((h) => h.id).toList();
      await _storage.saveMyTeam(_myTeamIds);
    }

    notifyListeners();
  }

  // --- Actions ---

  Future<void> addLp(int amount) async {
    _currentLp = (_currentLp + amount).clamp(0, 9999);
    await _storage.saveLeague(lp: _currentLp);
    notifyListeners();
  }

  Future<void> addGold(int amount) async {
    _gold += amount;
    await _saveCurrencies();
  }

  Future<void> addReward(int goldReward, int lpReward) async {
    _gold += goldReward;
    _currentLp = (_currentLp + lpReward).clamp(0, 9999);

    await _saveCurrencies();
    await _storage.saveLeague(lp: _currentLp);
    notifyListeners();
  }

  bool spendTicket() {
    if (_tickets > 0) {
      _tickets--;
      _saveCurrencies();
      return true;
    }
    return false;
  }

  Future<void> _saveCurrencies() async {
    await _storage.saveCurrencies(
      gold: _gold,
      crystals: _crystals,
      tickets: _tickets,
    );
    notifyListeners();
  }

  void addToTeam(String heroId) {
    if (_myTeamIds.contains(heroId)) return;
    if (_myTeamIds.length >= 5) return;

    _myTeamIds.add(heroId);
    _storage.saveMyTeam(_myTeamIds);
    notifyListeners();
  }

  void removeFromTeam(String heroId) {
    _myTeamIds.remove(heroId);
    _storage.saveMyTeam(_myTeamIds);
    notifyListeners();
  }

  // --- Recruitment & Management ---

  Future<HeroData?> recruitHero(bool isPremium) async {
    int cost = isPremium ? 100 : 100; // 100 Crystals vs 100 Gold
    if (isPremium) {
      if (_crystals < cost) return null;
      _crystals -= cost;
    } else {
      if (_gold < cost) return null;
      _gold -= cost;
    }
    await _saveCurrencies();

    // Rarity Weights
    Map<HeroRarity, double>? weights;
    if (isPremium) {
      weights = {
        HeroRarity.common: 30,
        HeroRarity.uncommon: 40,
        HeroRarity.rare: 20,
        HeroRarity.epic: 8,
        HeroRarity.legendary: 2,
      };
    } else {
      weights = {
        HeroRarity.common: 70,
        HeroRarity.uncommon: 25,
        HeroRarity.rare: 4.8,
        HeroRarity.epic: 0.2,
        HeroRarity.legendary: 0,
      };
    }

    final newHero = HeroData.random(weights);
    _heroes.add(newHero);
    await _storage.saveHeroes(_heroes);
    notifyListeners();
    return newHero;
  }

  Future<void> updateTeam(List<String> newTeamIds) async {
    if (newTeamIds.length > 5) return;
    _myTeamIds = List.from(newTeamIds);
    await _storage.saveMyTeam(_myTeamIds);
    notifyListeners();
  }
}
