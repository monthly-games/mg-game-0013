import 'package:hive/hive.dart';
import '../../features/hero/hero_data.dart';
import '../../features/league/league_data.dart';
import '../../features/skill/skill_data.dart';
import '../../features/skill/skill_registry.dart';

part 'game_data.g.dart';

/// Main game data saved locally
@HiveType(typeId: 0)
class GameData extends HiveObject {
  @HiveField(0)
  int gold;

  @HiveField(1)
  int crystal;

  @HiveField(2)
  int battleTickets;

  @HiveField(3)
  int leaguePoints;

  @HiveField(4)
  String currentTier; // LeagueTier as string

  @HiveField(5)
  int wins;

  @HiveField(6)
  int losses;

  @HiveField(7)
  List<SavedHeroData> myTeam;

  @HiveField(8)
  List<SavedHeroData> heroInventory;

  @HiveField(9)
  int seasonNumber;

  @HiveField(10)
  DateTime seasonEndDate;

  @HiveField(11)
  DateTime lastPlayed;

  GameData({
    this.gold = 1000,
    this.crystal = 100,
    this.battleTickets = 10,
    this.leaguePoints = 0,
    this.currentTier = 'bronze',
    this.wins = 0,
    this.losses = 0,
    required this.myTeam,
    required this.heroInventory,
    this.seasonNumber = 1,
    required this.seasonEndDate,
    required this.lastPlayed,
  });

  /// Create default save data
  factory GameData.createDefault() {
    return GameData(
      myTeam: [],
      heroInventory: [],
      seasonEndDate: DateTime.now().add(const Duration(days: 30)),
      lastPlayed: DateTime.now(),
    );
  }

  /// Convert LeagueTier to saved string
  static String tierToString(LeagueTier tier) {
    return tier.name;
  }

  /// Convert saved string to LeagueTier
  static LeagueTier stringToTier(String tierStr) {
    return LeagueTier.values.firstWhere(
      (t) => t.name == tierStr,
      orElse: () => LeagueTier.bronze,
    );
  }
}

/// Saved hero data (simplified for Hive storage)
@HiveType(typeId: 1)
class SavedHeroData extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String job; // HeroJob as string

  @HiveField(3)
  String rarity; // HeroRarity as string

  @HiveField(4)
  int cost;

  @HiveField(5)
  int level;

  @HiveField(6)
  double exp;

  @HiveField(7)
  double maxHp;

  @HiveField(8)
  double attack;

  @HiveField(9)
  double defense;

  @HiveField(10)
  double critRate;

  @HiveField(11)
  double critDamage;

  @HiveField(12)
  double range;

  @HiveField(13)
  double speed;

  @HiveField(14)
  String skillId; // SkillData ID

  SavedHeroData({
    required this.id,
    required this.name,
    required this.job,
    required this.rarity,
    required this.cost,
    required this.level,
    required this.exp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.critRate,
    required this.critDamage,
    required this.range,
    required this.speed,
    required this.skillId,
  });

  /// Convert HeroData to SavedHeroData
  factory SavedHeroData.fromHero(HeroData hero) {
    return SavedHeroData(
      id: hero.id,
      name: hero.name,
      job: hero.job.name,
      rarity: hero.rarity.name,
      cost: hero.cost,
      level: hero.level,
      exp: hero.exp,
      maxHp: hero.maxHp,
      attack: hero.attack,
      defense: hero.defense,
      critRate: hero.critRate,
      critDamage: hero.critDamage,
      range: hero.range,
      speed: hero.speed,
      skillId: hero.skill.id,
    );
  }

  /// Convert SavedHeroData to HeroData
  HeroData toHero() {
    final heroJob = HeroJob.values.firstWhere((j) => j.name == job);
    final heroRarity = HeroRarity.values.firstWhere((r) => r.name == rarity);

    // Find skill by ID (simplified - in real game, use skill registry)
    final skill = _getSkillById(skillId);

    return HeroData(
      id: id,
      name: name,
      job: heroJob,
      rarity: heroRarity,
      cost: cost,
      level: level,
      exp: exp,
      maxHp: maxHp,
      attack: attack,
      defense: defense,
      critRate: critRate,
      critDamage: critDamage,
      range: range,
      speed: speed,
      skill: skill,
    );
  }

  /// Get skill by ID (helper method)
  SkillData _getSkillById(String id) {
    final skill = SkillRegistry.getSkillById(id);
    // Fallback to default skill if not found
    return skill ?? Skills.slash;
  }
}
