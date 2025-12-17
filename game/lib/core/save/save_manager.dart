import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/hero/hero_data.dart';
import '../../features/league/league_data.dart';

/// Save manager using SharedPreferences
class SaveManager {
  static const String _saveKey = 'game_save_data';

  /// Save game data
  static Future<void> saveGame(SaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = data.toJson();
    final jsonStr = jsonEncode(json);
    await prefs.setString(_saveKey, jsonStr);
  }

  /// Load game data
  static Future<SaveData?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_saveKey);

    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SaveData.fromJson(json);
    } catch (e) {
      print('Error loading save data: $e');
      return null;
    }
  }

  /// Check if save exists
  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  /// Delete save data
  static Future<void> deleteSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }
}

/// Save data structure
class SaveData {
  final int gold;
  final int crystal;
  final int battleTickets;
  final int leaguePoints;
  final LeagueTier currentTier;
  final int wins;
  final int losses;
  final List<HeroData> myTeam;
  final List<HeroData> heroInventory;
  final int seasonNumber;
  final DateTime seasonEndDate;
  final DateTime lastPlayed;

  SaveData({
    required this.gold,
    required this.crystal,
    required this.battleTickets,
    required this.leaguePoints,
    required this.currentTier,
    required this.wins,
    required this.losses,
    required this.myTeam,
    required this.heroInventory,
    required this.seasonNumber,
    required this.seasonEndDate,
    required this.lastPlayed,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'gold': gold,
      'crystal': crystal,
      'battleTickets': battleTickets,
      'leaguePoints': leaguePoints,
      'currentTier': currentTier.name,
      'wins': wins,
      'losses': losses,
      'myTeam': myTeam.map((h) => _heroToJson(h)).toList(),
      'heroInventory': heroInventory.map((h) => _heroToJson(h)).toList(),
      'seasonNumber': seasonNumber,
      'seasonEndDate': seasonEndDate.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SaveData.fromJson(Map<String, dynamic> json) {
    return SaveData(
      gold: json['gold'] as int,
      crystal: json['crystal'] as int,
      battleTickets: json['battleTickets'] as int,
      leaguePoints: json['leaguePoints'] as int,
      currentTier: LeagueTier.values.firstWhere(
        (t) => t.name == json['currentTier'],
        orElse: () => LeagueTier.bronze,
      ),
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      myTeam: (json['myTeam'] as List)
          .map((h) => _heroFromJson(h as Map<String, dynamic>))
          .toList(),
      heroInventory: (json['heroInventory'] as List)
          .map((h) => _heroFromJson(h as Map<String, dynamic>))
          .toList(),
      seasonNumber: json['seasonNumber'] as int,
      seasonEndDate: DateTime.parse(json['seasonEndDate'] as String),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
    );
  }

  /// Convert HeroData to JSON
  static Map<String, dynamic> _heroToJson(HeroData hero) {
    return {
      'id': hero.id,
      'name': hero.name,
      'job': hero.job.name,
      'rarity': hero.rarity.name,
      'cost': hero.cost,
      'level': hero.level,
      'exp': hero.exp,
      'maxHp': hero.maxHp,
      'attack': hero.attack,
      'defense': hero.defense,
      'critRate': hero.critRate,
      'critDamage': hero.critDamage,
      'range': hero.range,
      'speed': hero.speed,
      'skillId': hero.skill.id,
    };
  }

  /// Convert JSON to HeroData
  static HeroData _heroFromJson(Map<String, dynamic> json) {
    final job = HeroJob.values.firstWhere((j) => j.name == json['job']);
    final rarity = HeroRarity.values.firstWhere((r) => r.name == json['rarity']);

    // Import skill registry to get skill by ID
    final skillId = json['skillId'] as String;
    final skill = _getSkillById(skillId);

    return HeroData(
      id: json['id'] as String,
      name: json['name'] as String,
      job: job,
      rarity: rarity,
      cost: json['cost'] as int,
      level: json['level'] as int,
      exp: (json['exp'] as num).toDouble(),
      maxHp: (json['maxHp'] as num).toDouble(),
      attack: (json['attack'] as num).toDouble(),
      defense: (json['defense'] as num).toDouble(),
      critRate: (json['critRate'] as num).toDouble(),
      critDamage: (json['critDamage'] as num).toDouble(),
      range: (json['range'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      skill: skill,
    );
  }

  /// Get skill by ID
  static dynamic _getSkillById(String id) {
    // Import and use skill registry
    return null; // Placeholder - will be fixed in integration
  }
}
