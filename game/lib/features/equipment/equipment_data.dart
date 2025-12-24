/// Equipment system for Arena Legends
library;
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../hero/hero_data.dart';

enum EquipmentSlot {
  weapon,    // 무기
  armor,     // 갑옷
  helmet,    // 투구
  boots,     // 신발
  accessory, // 악세서리
}

enum EquipmentRarity {
  common,    // 1성 (50%)
  uncommon,  // 2성 (30%)
  rare,      // 3성 (15%)
  epic,      // 4성 (4%)
  legendary, // 5성 (1%)
}

enum StatType {
  hp,
  attack,
  defense,
  critRate,
  critDamage,
  speed,
}

class StatBonus {
  final StatType type;
  final double value;
  final bool isPercentage; // true면 %, false면 고정값

  const StatBonus({
    required this.type,
    required this.value,
    this.isPercentage = false,
  });

  @override
  String toString() {
    if (isPercentage) {
      return '${type.name} +${(value * 100).toStringAsFixed(1)}%';
    } else {
      return '${type.name} +${value.toStringAsFixed(0)}';
    }
  }
}

class EquipmentData {
  final String id;
  final String name;
  final EquipmentSlot slot;
  final EquipmentRarity rarity;
  final HeroJob? requiredJob; // null이면 모든 직업 착용 가능
  final int requiredLevel;

  // Stat bonuses
  final List<StatBonus> bonuses;

  // Set bonus (추후 세트 아이템 시스템용)
  final String? setName;

  // Visual
  final String? iconPath;

  const EquipmentData({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    this.requiredJob,
    this.requiredLevel = 1,
    required this.bonuses,
    this.setName,
    this.iconPath,
  });

  /// Generate random equipment
  static EquipmentData random({HeroJob? job, int minLevel = 1}) {
    final random = Random();
    final rarity = _randomRarity(random);
    final slot = EquipmentSlot.values[random.nextInt(EquipmentSlot.values.length)];

    return _createEquipment(slot, rarity, job, random);
  }

  /// Create equipment with specific parameters
  static EquipmentData _createEquipment(
    EquipmentSlot slot,
    EquipmentRarity rarity,
    HeroJob? job,
    Random random,
  ) {
    final name = _generateName(slot, rarity, job);
    final bonuses = _generateBonuses(slot, rarity, random);
    final requiredLevel = 1 + (rarity.index * 5); // 1, 6, 11, 16, 21

    return EquipmentData(
      id: const Uuid().v4(),
      name: name,
      slot: slot,
      rarity: rarity,
      requiredJob: (random.nextDouble() > 0.7) ? job : null, // 30% 직업 전용
      requiredLevel: requiredLevel,
      bonuses: bonuses,
    );
  }

  /// Generate stat bonuses based on slot and rarity
  static List<StatBonus> _generateBonuses(
    EquipmentSlot slot,
    EquipmentRarity rarity,
    Random random,
  ) {
    final bonuses = <StatBonus>[];
    final numBonuses = 1 + rarity.index; // Common: 1, Legendary: 5

    // Primary stat (slot에 따라 결정)
    final primaryStat = _getPrimaryStat(slot);
    final primaryValue = _getBaseValue(primaryStat, rarity) * (0.9 + random.nextDouble() * 0.2);
    bonuses.add(StatBonus(
      type: primaryStat,
      value: primaryValue,
      isPercentage: _isPercentageStat(primaryStat),
    ));

    // Secondary stats (랜덤)
    final availableStats = StatType.values.where((s) => s != primaryStat).toList();
    for (var i = 1; i < numBonuses && availableStats.isNotEmpty; i++) {
      final stat = availableStats.removeAt(random.nextInt(availableStats.length));
      final value = _getBaseValue(stat, rarity) * 0.5 * (0.8 + random.nextDouble() * 0.4);
      bonuses.add(StatBonus(
        type: stat,
        value: value,
        isPercentage: _isPercentageStat(stat),
      ));
    }

    return bonuses;
  }

  /// Get primary stat for equipment slot
  static StatType _getPrimaryStat(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:    return StatType.attack;
      case EquipmentSlot.armor:     return StatType.defense;
      case EquipmentSlot.helmet:    return StatType.hp;
      case EquipmentSlot.boots:     return StatType.speed;
      case EquipmentSlot.accessory: return StatType.critRate;
    }
  }

  /// Get base stat value based on stat type and rarity
  static double _getBaseValue(StatType stat, EquipmentRarity rarity) {
    final multiplier = 1.0 + (rarity.index * 0.5); // 1.0 ~ 3.0

    switch (stat) {
      case StatType.hp:         return 20 * multiplier;
      case StatType.attack:     return 5 * multiplier;
      case StatType.defense:    return 3 * multiplier;
      case StatType.critRate:   return 0.02 * multiplier;  // 2% ~ 6%
      case StatType.critDamage: return 0.05 * multiplier;  // 5% ~ 15%
      case StatType.speed:      return 5 * multiplier;
    }
  }

  /// Check if stat should be displayed as percentage
  static bool _isPercentageStat(StatType stat) {
    return stat == StatType.critRate || stat == StatType.critDamage;
  }

  /// Weighted random rarity
  static EquipmentRarity _randomRarity(Random random) {
    final roll = random.nextDouble() * 100;
    if (roll < 50) return EquipmentRarity.common;      // 50%
    if (roll < 80) return EquipmentRarity.uncommon;    // 30%
    if (roll < 95) return EquipmentRarity.rare;        // 15%
    if (roll < 99) return EquipmentRarity.epic;        // 4%
    return EquipmentRarity.legendary;                   // 1%
  }

  /// Generate equipment name
  static String _generateName(EquipmentSlot slot, EquipmentRarity rarity, HeroJob? job) {
    final rarityPrefix = ['', 'Fine', 'Superior', 'Masterwork', 'Legendary'][rarity.index];
    final jobPrefix = job != null ? _jobPrefix(job) : '';
    final slotName = _slotBaseName(slot);

    if (rarityPrefix.isEmpty) {
      return jobPrefix.isEmpty ? slotName : '$jobPrefix $slotName';
    } else {
      return jobPrefix.isEmpty
        ? '$rarityPrefix $slotName'
        : '$rarityPrefix $jobPrefix $slotName';
    }
  }

  static String _jobPrefix(HeroJob job) {
    switch (job) {
      case HeroJob.warrior:  return 'Warrior\'s';
      case HeroJob.archer:   return 'Ranger\'s';
      case HeroJob.mage:     return 'Mage\'s';
      case HeroJob.tank:     return 'Guardian\'s';
      case HeroJob.assassin: return 'Shadow';
      case HeroJob.healer:   return 'Holy';
    }
  }

  static String _slotBaseName(EquipmentSlot slot) {
    switch (slot) {
      case EquipmentSlot.weapon:    return 'Blade';
      case EquipmentSlot.armor:     return 'Armor';
      case EquipmentSlot.helmet:    return 'Helmet';
      case EquipmentSlot.boots:     return 'Boots';
      case EquipmentSlot.accessory: return 'Ring';
    }
  }

  /// Get rarity color for UI
  String getRarityColor() {
    switch (rarity) {
      case EquipmentRarity.common:    return '#AAAAAA'; // Gray
      case EquipmentRarity.uncommon:  return '#00FF00'; // Green
      case EquipmentRarity.rare:      return '#0088FF'; // Blue
      case EquipmentRarity.epic:      return '#AA00FF'; // Purple
      case EquipmentRarity.legendary: return '#FFAA00'; // Gold
    }
  }

  /// Check if hero can equip this item
  bool canEquip(HeroData hero) {
    if (requiredLevel > hero.level) return false;
    if (requiredJob != null && requiredJob != hero.job) return false;
    return true;
  }

  /// Copy with modified fields
  EquipmentData copyWith({
    String? name,
    EquipmentSlot? slot,
    EquipmentRarity? rarity,
    HeroJob? requiredJob,
    int? requiredLevel,
    List<StatBonus>? bonuses,
    String? setName,
    String? iconPath,
  }) {
    return EquipmentData(
      id: id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      rarity: rarity ?? this.rarity,
      requiredJob: requiredJob ?? this.requiredJob,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      bonuses: bonuses ?? this.bonuses,
      setName: setName ?? this.setName,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}

/// Predefined equipment sets (for later use)
class EquipmentSets {
  static const warriorSet = 'Berserker Set';
  static const archerSet = 'Hunter Set';
  static const mageSet = 'Arcane Set';
  static const tankSet = 'Fortress Set';
  static const assassinSet = 'Shadow Set';
  static const healerSet = 'Holy Set';

  /// Get set bonus description (추후 구현)
  static String getSetBonus(String setName, int pieceCount) {
    // Example: 2-piece bonus, 4-piece bonus
    return '$setName ($pieceCount/4): +10% Attack';
  }
}
