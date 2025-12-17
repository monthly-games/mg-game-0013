/// Battle result data for post-battle screen
import 'league_data.dart';

class BattleResultData {
  final bool isVictory;
  final int goldEarned;
  final int pointsChanged;
  final int previousPoints;
  final int newPoints;
  final LeagueTier previousTier;
  final LeagueTier newTier;
  final bool tierChanged;
  final int totalWins;
  final int totalLosses;
  final double winRate;

  // Team stats
  final int allyUnitsRemaining;
  final int enemyUnitsKilled;
  final double damageDealt;
  final double damageTaken;

  const BattleResultData({
    required this.isVictory,
    required this.goldEarned,
    required this.pointsChanged,
    required this.previousPoints,
    required this.newPoints,
    required this.previousTier,
    required this.newTier,
    required this.tierChanged,
    required this.totalWins,
    required this.totalLosses,
    required this.winRate,
    this.allyUnitsRemaining = 0,
    this.enemyUnitsKilled = 0,
    this.damageDealt = 0,
    this.damageTaken = 0,
  });

  /// Get tier change type
  TierChangeType get tierChangeType {
    if (!tierChanged) return TierChangeType.none;
    if (newTier.index > previousTier.index) return TierChangeType.promotion;
    return TierChangeType.relegation;
  }

  /// Get result message
  String get resultMessage {
    if (isVictory) {
      if (tierChangeType == TierChangeType.promotion) {
        return 'PROMOTED TO ${LeagueTiers.getByTier(newTier).nameKr.toUpperCase()}!';
      }
      return 'VICTORY!';
    } else {
      if (tierChangeType == TierChangeType.relegation) {
        return 'RELEGATED TO ${LeagueTiers.getByTier(newTier).nameKr.toUpperCase()}';
      }
      return 'DEFEAT';
    }
  }

  /// Get points display string
  String get pointsDisplay {
    if (pointsChanged >= 0) {
      return '+$pointsChanged LP';
    } else {
      return '$pointsChanged LP';
    }
  }

  /// Get gold display string
  String get goldDisplay {
    return '+$goldEarned 💰';
  }
}

enum TierChangeType {
  none,
  promotion,
  relegation,
}
