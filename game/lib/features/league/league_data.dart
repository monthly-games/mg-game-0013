/// League tier and season system for Arena Legends

enum LeagueTier {
  bronze,    // 브론즈 (Starting)
  silver,    // 실버
  gold,      // 골드
  platinum,  // 플래티넘
  diamond,   // 다이아몬드
  master,    // 마스터
  legend,    // 레전드 (Top tier)
}

class LeagueTierData {
  final LeagueTier tier;
  final String name;
  final String nameKr;
  final int minPoints;     // 진입 포인트
  final int maxPoints;     // 최대 포인트 (다음 티어 진입점 -1)
  final int promotionPoints; // 승급 필요 포인트
  final int relegationPoints; // 강등 포인트

  // Rewards
  final int dailyGoldReward;    // 일일 골드 보상
  final int dailyCrystalReward; // 일일 크리스탈 보상
  final int seasonGoldReward;   // 시즌 종료 골드
  final int seasonCrystalReward; // 시즌 종료 크리스탈

  // Matchmaking
  final int matchmakingRange; // 매칭 범위 (±N 티어)

  // Visual
  final String color;
  final String iconPath;

  const LeagueTierData({
    required this.tier,
    required this.name,
    required this.nameKr,
    required this.minPoints,
    required this.maxPoints,
    required this.promotionPoints,
    required this.relegationPoints,
    required this.dailyGoldReward,
    required this.dailyCrystalReward,
    required this.seasonGoldReward,
    required this.seasonCrystalReward,
    this.matchmakingRange = 1,
    required this.color,
    this.iconPath = '',
  });

  /// Get points for winning a match
  int getWinPoints(LeagueTier opponentTier) {
    final tierDiff = opponentTier.index - tier.index;
    if (tierDiff > 0) {
      // Beat higher tier: bonus points
      return 30 + (tierDiff * 5);
    } else if (tierDiff < 0) {
      // Beat lower tier: fewer points
      return max(15, 30 + (tierDiff * 5));
    } else {
      // Same tier
      return 30;
    }
  }

  /// Get points lost for losing a match
  int getLosePoints(LeagueTier opponentTier) {
    final tierDiff = opponentTier.index - tier.index;
    if (tierDiff > 0) {
      // Lost to higher tier: less penalty
      return max(5, 15 - (tierDiff * 3));
    } else if (tierDiff < 0) {
      // Lost to lower tier: more penalty
      return 15 + (tierDiff.abs() * 5);
    } else {
      // Same tier
      return 15;
    }
  }

  /// Check if should promote to next tier
  bool shouldPromote(int currentPoints) {
    return currentPoints >= promotionPoints;
  }

  /// Check if should relegate to previous tier
  bool shouldRelegate(int currentPoints) {
    return currentPoints <= relegationPoints;
  }

  int max(int a, int b) => a > b ? a : b;
}

/// League tier definitions
class LeagueTiers {
  static const bronze = LeagueTierData(
    tier: LeagueTier.bronze,
    name: 'Bronze',
    nameKr: '브론즈',
    minPoints: 0,
    maxPoints: 999,
    promotionPoints: 1000,
    relegationPoints: 0,
    dailyGoldReward: 100,
    dailyCrystalReward: 5,
    seasonGoldReward: 1000,
    seasonCrystalReward: 50,
    color: '#CD7F32', // Bronze color
  );

  static const silver = LeagueTierData(
    tier: LeagueTier.silver,
    name: 'Silver',
    nameKr: '실버',
    minPoints: 1000,
    maxPoints: 1999,
    promotionPoints: 2000,
    relegationPoints: 950,
    dailyGoldReward: 200,
    dailyCrystalReward: 10,
    seasonGoldReward: 2500,
    seasonCrystalReward: 100,
    color: '#C0C0C0', // Silver color
  );

  static const gold = LeagueTierData(
    tier: LeagueTier.gold,
    name: 'Gold',
    nameKr: '골드',
    minPoints: 2000,
    maxPoints: 2999,
    promotionPoints: 3000,
    relegationPoints: 1950,
    dailyGoldReward: 300,
    dailyCrystalReward: 15,
    seasonGoldReward: 5000,
    seasonCrystalReward: 200,
    color: '#FFD700', // Gold color
  );

  static const platinum = LeagueTierData(
    tier: LeagueTier.platinum,
    name: 'Platinum',
    nameKr: '플래티넘',
    minPoints: 3000,
    maxPoints: 3999,
    promotionPoints: 4000,
    relegationPoints: 2950,
    dailyGoldReward: 500,
    dailyCrystalReward: 25,
    seasonGoldReward: 10000,
    seasonCrystalReward: 400,
    color: '#E5E4E2', // Platinum color
  );

  static const diamond = LeagueTierData(
    tier: LeagueTier.diamond,
    name: 'Diamond',
    nameKr: '다이아몬드',
    minPoints: 4000,
    maxPoints: 4999,
    promotionPoints: 5000,
    relegationPoints: 3950,
    dailyGoldReward: 800,
    dailyCrystalReward: 40,
    seasonGoldReward: 20000,
    seasonCrystalReward: 800,
    color: '#B9F2FF', // Diamond blue
  );

  static const master = LeagueTierData(
    tier: LeagueTier.master,
    name: 'Master',
    nameKr: '마스터',
    minPoints: 5000,
    maxPoints: 5999,
    promotionPoints: 6000,
    relegationPoints: 4950,
    dailyGoldReward: 1200,
    dailyCrystalReward: 60,
    seasonGoldReward: 40000,
    seasonCrystalReward: 1500,
    matchmakingRange: 2,
    color: '#FF00FF', // Magenta
  );

  static const legend = LeagueTierData(
    tier: LeagueTier.legend,
    name: 'Legend',
    nameKr: '레전드',
    minPoints: 6000,
    maxPoints: 99999,
    promotionPoints: 99999,
    relegationPoints: 5950,
    dailyGoldReward: 2000,
    dailyCrystalReward: 100,
    seasonGoldReward: 100000,
    seasonCrystalReward: 3000,
    matchmakingRange: 3,
    color: '#FF4500', // Red-orange
  );

  /// Get all tiers as a list
  static List<LeagueTierData> get all => [
        bronze,
        silver,
        gold,
        platinum,
        diamond,
        master,
        legend,
      ];

  /// Get tier data by tier enum
  static LeagueTierData getByTier(LeagueTier tier) {
    return all.firstWhere((t) => t.tier == tier);
  }

  /// Get tier by points
  static LeagueTierData getByPoints(int points) {
    for (var i = all.length - 1; i >= 0; i--) {
      if (points >= all[i].minPoints) {
        return all[i];
      }
    }
    return bronze;
  }

  /// Get next tier (null if already at max)
  static LeagueTierData? getNextTier(LeagueTier currentTier) {
    if (currentTier == LeagueTier.legend) return null;
    return all[currentTier.index + 1];
  }

  /// Get previous tier (null if already at min)
  static LeagueTierData? getPreviousTier(LeagueTier currentTier) {
    if (currentTier == LeagueTier.bronze) return null;
    return all[currentTier.index - 1];
  }
}

/// Season data
class SeasonData {
  final int seasonNumber;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;

  // Special season rewards
  final Map<LeagueTier, int> bonusCrystals;

  const SeasonData({
    required this.seasonNumber,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.durationDays = 30,
    this.bonusCrystals = const {},
  });

  /// Check if season is active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Get days remaining
  int get daysRemaining {
    if (!isActive) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Get season progress (0.0 ~ 1.0)
  double get progress {
    if (!isActive) return 1.0;
    final total = endDate.difference(startDate).inDays;
    final elapsed = DateTime.now().difference(startDate).inDays;
    return elapsed / total;
  }

  /// Create next season
  static SeasonData createNextSeason(SeasonData current) {
    return SeasonData(
      seasonNumber: current.seasonNumber + 1,
      name: 'Season ${current.seasonNumber + 1}',
      startDate: current.endDate,
      endDate: current.endDate.add(Duration(days: current.durationDays)),
      durationDays: current.durationDays,
    );
  }
}

/// Matchmaking data
class MatchData {
  final String matchId;
  final LeagueTier tier;
  final DateTime timestamp;
  final bool isWin;
  final int pointsGained;
  final int pointsLost;

  const MatchData({
    required this.matchId,
    required this.tier,
    required this.timestamp,
    required this.isWin,
    this.pointsGained = 0,
    this.pointsLost = 0,
  });

  int get netPoints => isWin ? pointsGained : -pointsLost;
}
