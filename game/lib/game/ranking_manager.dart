import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// RankingManager -- Arena Legend tier & season subsystem
// Handles tier progression, promotion rewards, and season flow.
// ============================================================

/// Constants for ranking tuning.
class RankingConstants {
  RankingConstants._();

  static const int seasonDurationDays = 30;
  static const int promotionBonusGold = 200;
  static const double tierBonusPerLevel = 0.10;
  static const double seasonMultiplierPerLevel = 0.08;
}

/// Represents a ranked tier with LP boundaries.
enum RankedTier {
  bronze(0, 'Bronze', 0xFF8B6914),
  silver(100, 'Silver', 0xFFC0C0C0),
  gold(250, 'Gold', 0xFFFFD700),
  platinum(500, 'Platinum', 0xFF00CED1),
  diamond(800, 'Diamond', 0xFF00BFFF),
  master(1200, 'Master', 0xFFFF4500);

  final int minLp;
  final String label;
  final int colorValue;
  const RankedTier(this.minLp, this.label, this.colorValue);
}

class RankingManager extends ChangeNotifier {
  int _seasonNumber = 1;
  int _seasonWins = 0;
  RankedTier _highestTier = RankedTier.bronze;

  int get seasonNumber => _seasonNumber;
  int get seasonWins => _seasonWins;
  RankedTier get highestTier => _highestTier;

  /// Determine current tier from LP value.
  RankedTier getTierForLp(int lp) {
    for (final tier in RankedTier.values.reversed) {
      if (lp >= tier.minLp) return tier;
    }
    return RankedTier.bronze;
  }

  /// Get tier-based gold bonus multiplier from upgrade.
  double getTierBonusMultiplier() {
    final upgradeManager = GetIt.I<UpgradeManager>();
    final tierBonus = upgradeManager.getUpgrade('tier_bonus');
    return 1.0 + (tierBonus?.currentValue ?? 0.0);
  }

  /// Get season reward multiplier from upgrade.
  double getSeasonMultiplier() {
    final upgradeManager = GetIt.I<UpgradeManager>();
    final seasonUpgrade = upgradeManager.getUpgrade('season_multiplier');
    return 1.0 + (seasonUpgrade?.currentValue ?? 0.0);
  }

  /// Calculate promotion bonus when player enters a new tier.
  int calculatePromotionBonus(RankedTier newTier) {
    final tierMultiplier = getTierBonusMultiplier();
    final tierIndex = newTier.index + 1;
    return (RankingConstants.promotionBonusGold *
            tierIndex *
            tierMultiplier)
        .round();
  }

  /// Update tier tracking after LP change, returns promotion bonus if promoted.
  int? onLpChanged(int newLp) {
    final newTier = getTierForLp(newLp);

    if (newTier.index > _highestTier.index) {
      _highestTier = newTier;
      final bonus = calculatePromotionBonus(newTier);
      notifyListeners();
      return bonus;
    }

    notifyListeners();
    return null;
  }

  /// Record a win this season.
  void recordWin() {
    _seasonWins++;
    notifyListeners();
  }

  /// Calculate end-of-season rewards.
  int calculateSeasonRewards() {
    final seasonMult = getSeasonMultiplier();
    final tierMult = _highestTier.index + 1;
    return (_seasonWins * 10 * tierMult * seasonMult).round();
  }

  /// Reset for a new season.
  void startNewSeason() {
    _seasonNumber++;
    _seasonWins = 0;
    _highestTier = RankedTier.bronze;
    notifyListeners();
  }
}
