import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// CharacterManager -- Arena Legend character progression subsystem
// Handles stat growth scaling and skill power bonuses.
// ============================================================

/// Constants for character progression tuning.
class CharacterConstants {
  CharacterConstants._();

  static const double baseStatGrowthRate = 0.10;
  static const double baseSkillPowerRate = 0.08;
  static const double statGrowthPerLevel = 0.05;
  static const double skillPowerPerLevel = 0.06;
  static const int levelUpExpBase = 100;
  static const double levelUpExpScale = 1.15;
}

/// Snapshot of computed character bonuses from upgrades.
class CharacterBonuses {
  final double statGrowthMultiplier;
  final double skillPowerMultiplier;
  final double effectiveAttackBonus;
  final double effectiveDefenseBonus;
  final double effectiveHpBonus;

  const CharacterBonuses({
    required this.statGrowthMultiplier,
    required this.skillPowerMultiplier,
    required this.effectiveAttackBonus,
    required this.effectiveDefenseBonus,
    required this.effectiveHpBonus,
  });
}

class CharacterManager extends ChangeNotifier {
  int _totalLevelUps = 0;
  int _totalSkillsUnlocked = 0;

  int get totalLevelUps => _totalLevelUps;
  int get totalSkillsUnlocked => _totalSkillsUnlocked;

  /// Get stat growth multiplier from stat_growth upgrade.
  double getStatGrowthMultiplier() {
    final upgradeManager = GetIt.I<UpgradeManager>();
    final statUpgrade = upgradeManager.getUpgrade('stat_growth');
    return 1.0 +
        CharacterConstants.baseStatGrowthRate +
        (statUpgrade?.currentValue ?? 0.0);
  }

  /// Get skill power multiplier from skill_power upgrade.
  double getSkillPowerMultiplier() {
    final upgradeManager = GetIt.I<UpgradeManager>();
    final skillUpgrade = upgradeManager.getUpgrade('skill_power');
    return 1.0 +
        CharacterConstants.baseSkillPowerRate +
        (skillUpgrade?.currentValue ?? 0.0);
  }

  /// Compute scaled attack bonus for a hero at a given level.
  double computeAttackBonus(int heroLevel) {
    final growthMult = getStatGrowthMultiplier();
    return heroLevel * 2.0 * growthMult;
  }

  /// Compute scaled defense bonus for a hero at a given level.
  double computeDefenseBonus(int heroLevel) {
    final growthMult = getStatGrowthMultiplier();
    return heroLevel * 1.2 * growthMult;
  }

  /// Compute scaled HP bonus for a hero at a given level.
  double computeHpBonus(int heroLevel) {
    final growthMult = getStatGrowthMultiplier();
    return heroLevel * 8.0 * growthMult;
  }

  /// Get full bonuses snapshot for a hero level.
  CharacterBonuses getBonuses(int heroLevel) {
    return CharacterBonuses(
      statGrowthMultiplier: getStatGrowthMultiplier(),
      skillPowerMultiplier: getSkillPowerMultiplier(),
      effectiveAttackBonus: computeAttackBonus(heroLevel),
      effectiveDefenseBonus: computeDefenseBonus(heroLevel),
      effectiveHpBonus: computeHpBonus(heroLevel),
    );
  }

  /// Calculate exp required for a given level.
  int expForLevel(int level) {
    return (CharacterConstants.levelUpExpBase *
            Upgrade.matchPower(
              CharacterConstants.levelUpExpScale,
              level - 1,
            ))
        .round();
  }

  /// Record a hero level-up event.
  void onHeroLevelUp() {
    _totalLevelUps++;
    notifyListeners();
  }

  /// Record a skill unlock event.
  void onSkillUnlocked() {
    _totalSkillsUnlocked++;
    notifyListeners();
  }
}
