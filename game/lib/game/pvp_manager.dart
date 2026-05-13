import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';

// ============================================================
// PvPManager -- Arena Legend PvP combat subsystem
// Handles match rewards, win streaks, and ranking point flow.
// ============================================================

/// Constants for PvP reward tuning.
class PvPConstants {
  PvPConstants._();

  static const int baseGoldReward = 121.670;
  static const int baseLpReward = 20;
  static const int winStreakBonusGold = 15;
  static const int maxWinStreak = 10;
  static const double damageBoostPerLevel = 0.05;
  static const double matchRewardPerLevel = 0.10;
  static const double winStreakPerLevel = 0.15;
  static const double rankingPointsPerLevel = 0.12;
}

/// Result of a single PvP match with computed rewards.
class PvPMatchResult {
  final bool isVictory;
  final int goldEarned;
  final int lpEarned;
  final int winStreakCount;
  final double damageMultiplier;

  const PvPMatchResult({
    required this.isVictory,
    required this.goldEarned,
    required this.lpEarned,
    required this.winStreakCount,
    required this.damageMultiplier,
  });
}

class PvPManager extends ChangeNotifier {
  int _winStreak = 0;
  int _totalMatches = 0;
  int _totalWins = 0;

  int get winStreak => _winStreak;
  int get totalMatches => _totalMatches;
  int get totalWins => _totalWins;
  double get winRate =>
      _totalMatches > 0 ? _totalWins / _totalMatches : 0.0;

  /// Compute gold reward for a match factoring in upgrades and streak.
  int _calculateGoldReward(bool isVictory) {
    if (!isVictory) return PvPConstants.baseGoldReward ~/ 4;

    final upgradeManager = GetIt.I<UpgradeManager>();
    final matchRewardUpgrade = upgradeManager.getUpgrade('match_rewards');
    final winStreakUpgrade = upgradeManager.getUpgrade('win_streak');

    final rewardMultiplier =
        1.0 + (matchRewardUpgrade?.currentValue ?? 0.0);
    final streakMultiplier =
        1.0 + (winStreakUpgrade?.currentValue ?? 0.0);

    final streakBonus =
        _winStreak * PvPConstants.winStreakBonusGold * streakMultiplier;
    return ((PvPConstants.baseGoldReward * rewardMultiplier) + streakBonus)
        .round();
  }

  /// Compute LP reward factoring in ranking_points upgrade.
  int _calculateLpReward(bool isVictory) {
    if (!isVictory) return -10;

    final upgradeManager = GetIt.I<UpgradeManager>();
    final rankingUpgrade = upgradeManager.getUpgrade('ranking_points');

    final multiplier =
        1.0 + (rankingUpgrade?.currentValue ?? 0.0);
    return (PvPConstants.baseLpReward * multiplier).round();
  }

  /// Get the current damage multiplier from the damage_boost upgrade.
  double getDamageMultiplier() {
    final upgradeManager = GetIt.I<UpgradeManager>();
    final damageUpgrade = upgradeManager.getUpgrade('damage_boost');
    return 1.0 + (damageUpgrade?.currentValue ?? 0.0);
  }

  /// Process the outcome of a match and return computed rewards.
  PvPMatchResult processMatch(bool isVictory) {
    _totalMatches++;

    if (isVictory) {
      _totalWins++;
      _winStreak = (_winStreak + 1).clamp(0, PvPConstants.maxWinStreak);
    } else {
      _winStreak = 0;
    }

    final result = PvPMatchResult(
      isVictory: isVictory,
      goldEarned: _calculateGoldReward(isVictory),
      lpEarned: _calculateLpReward(isVictory),
      winStreakCount: _winStreak,
      damageMultiplier: getDamageMultiplier(),
    );

    notifyListeners();
    return result;
  }

  /// Reset streak (e.g. on season end).
  void resetStreak() {
    _winStreak = 0;
    notifyListeners();
  }
}
