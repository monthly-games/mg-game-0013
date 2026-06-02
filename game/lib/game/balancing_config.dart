import 'package:mg_common_game/systems/balancing/balancing.dart';

/// Default balancing configuration for MG-0013: Arena Legends: Mercenary League.
///
/// Placeholder values -- override via RemoteConfig using
/// [BalancingManager.loadFromRemote] in production.
const kDefaultBalancingConfig = BalancingConfig(
  gameId: 'mg-0013',
  version: 1,
  currencies: [
    CurrencyConfig(id: 'gold', baseEarnRate: 8.0),
    CurrencyConfig(
      id: 'gems',
      baseEarnRate: 0.5,
    ),
  ],
  xpCurve: XpCurveConfig(baseXp: 100, maxLevel: 100),
  difficultyScaling: DifficultyScalingConfig(scalingFactor: 0.1),
  customParams: {
    'reward_multiplier': 1.0,
    'combo_bonus_enabled': true,
    'combo_multiplier_per_tier': 0.15,
    'combo_window_seconds': 3.0,
  },
);
