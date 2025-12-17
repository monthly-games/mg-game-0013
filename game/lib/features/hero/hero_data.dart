import 'dart:math';
import 'package:uuid/uuid.dart';
import '../skill/skill_data.dart';

enum HeroJob { warrior, archer, mage, tank, assassin, healer }

enum HeroRarity {
  common,    // 1성 (60% 확률)
  uncommon,  // 2성 (25% 확률)
  rare,      // 3성 (10% 확률)
  epic,      // 4성 (4% 확률)
  legendary, // 5성 (1% 확률)
}

class HeroData {
  final String id;
  final String name;
  final HeroJob job;
  final HeroRarity rarity;
  final int cost;

  // Level & Growth
  int level;
  double exp;

  // Combat Stats
  double maxHp;
  double attack;
  double defense;
  double critRate;
  double critDamage;
  double range;
  double speed;

  // Skills
  final SkillData skill;

  HeroData({
    required this.name,
    required this.job,
    required this.rarity,
    required this.cost,
    required this.skill,
    this.level = 1,
    this.exp = 0,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.critRate,
    required this.critDamage,
    required this.range,
    required this.speed,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Generate a random hero with weighted rarity
  static HeroData random() {
    final random = Random();
    final rarity = _randomRarity(random);
    final job = HeroJob.values[random.nextInt(HeroJob.values.length)];

    return _createHeroByJob(job, rarity, random);
  }

  /// Create a hero with specific job and rarity
  static HeroData _createHeroByJob(HeroJob job, HeroRarity rarity, Random random) {
    final multiplier = _getRarityMultiplier(rarity);
    final name = _generateName(job, rarity);

    // Base stats per job
    double baseHp, baseAtk, baseDef, baseRange, baseSpeed;
    SkillData defaultSkill;

    switch (job) {
      case HeroJob.warrior:
        baseHp = 120; baseAtk = 15; baseDef = 10; baseRange = 60; baseSpeed = 50;
        defaultSkill = Skills.slash;
        break;
      case HeroJob.archer:
        baseHp = 80; baseAtk = 18; baseDef = 6; baseRange = 200; baseSpeed = 60;
        defaultSkill = Skills.preciseShot;
        break;
      case HeroJob.mage:
        baseHp = 70; baseAtk = 20; baseDef = 5; baseRange = 180; baseSpeed = 45;
        defaultSkill = Skills.fireball;
        break;
      case HeroJob.tank:
        baseHp = 150; baseAtk = 12; baseDef = 15; baseRange = 50; baseSpeed = 40;
        defaultSkill = Skills.shieldBash;
        break;
      case HeroJob.assassin:
        baseHp = 75; baseAtk = 22; baseDef = 5; baseRange = 70; baseSpeed = 70;
        defaultSkill = Skills.backstab;
        break;
      case HeroJob.healer:
        baseHp = 90; baseAtk = 10; baseDef = 8; baseRange = 150; baseSpeed = 50;
        defaultSkill = Skills.heal;
        break;
    }

    // Apply rarity multiplier with some variance
    final variance = 0.9 + random.nextDouble() * 0.2; // 0.9 ~ 1.1

    return HeroData(
      name: name,
      job: job,
      rarity: rarity,
      cost: (50 + (rarity.index * 50)).toInt(),
      skill: defaultSkill,
      maxHp: baseHp * multiplier * variance,
      attack: baseAtk * multiplier * variance,
      defense: baseDef * multiplier * variance,
      critRate: 0.05 + (rarity.index * 0.02), // 5% ~ 13%
      critDamage: 1.5 + (rarity.index * 0.1),  // 150% ~ 190%
      range: baseRange,
      speed: baseSpeed * (0.95 + random.nextDouble() * 0.1),
    );
  }

  /// Weighted random rarity selection
  static HeroRarity _randomRarity(Random random) {
    final roll = random.nextDouble() * 100;
    if (roll < 60) return HeroRarity.common;      // 60%
    if (roll < 85) return HeroRarity.uncommon;    // 25%
    if (roll < 95) return HeroRarity.rare;        // 10%
    if (roll < 99) return HeroRarity.epic;        // 4%
    return HeroRarity.legendary;                   // 1%
  }

  /// Get stat multiplier based on rarity
  static double _getRarityMultiplier(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.common:    return 1.0;
      case HeroRarity.uncommon:  return 1.2;
      case HeroRarity.rare:      return 1.5;
      case HeroRarity.epic:      return 1.8;
      case HeroRarity.legendary: return 2.2;
    }
  }

  /// Generate name based on job and rarity
  static String _generateName(HeroJob job, HeroRarity rarity) {
    final jobNames = {
      HeroJob.warrior: ['Warrior', 'Blade', 'Berserker', 'Champion', 'Warlord'],
      HeroJob.archer: ['Archer', 'Ranger', 'Hunter', 'Marksman', 'Sniper'],
      HeroJob.mage: ['Mage', 'Wizard', 'Sorcerer', 'Archmage', 'Sage'],
      HeroJob.tank: ['Guardian', 'Defender', 'Sentinel', 'Paladin', 'Fortress'],
      HeroJob.assassin: ['Rogue', 'Shadow', 'Assassin', 'Reaper', 'Phantom'],
      HeroJob.healer: ['Cleric', 'Priest', 'Monk', 'Bishop', 'Saint'],
    };

    return jobNames[job]![rarity.index];
  }

  /// Get rarity color for UI
  String getRarityColor() {
    switch (rarity) {
      case HeroRarity.common:    return '#FFFFFF'; // White
      case HeroRarity.uncommon:  return '#00FF00'; // Green
      case HeroRarity.rare:      return '#0088FF'; // Blue
      case HeroRarity.epic:      return '#AA00FF'; // Purple
      case HeroRarity.legendary: return '#FFAA00'; // Gold
    }
  }

  /// Copy with modified fields
  HeroData copyWith({
    String? name,
    HeroJob? job,
    HeroRarity? rarity,
    int? cost,
    int? level,
    double? exp,
    double? maxHp,
    double? attack,
    double? defense,
    double? critRate,
    double? critDamage,
    double? range,
    double? speed,
    SkillData? skill,
  }) {
    return HeroData(
      id: id,
      name: name ?? this.name,
      job: job ?? this.job,
      rarity: rarity ?? this.rarity,
      cost: cost ?? this.cost,
      skill: skill ?? this.skill,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      critRate: critRate ?? this.critRate,
      critDamage: critDamage ?? this.critDamage,
      range: range ?? this.range,
      speed: speed ?? this.speed,
    );
  }
}
