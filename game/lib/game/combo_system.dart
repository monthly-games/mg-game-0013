import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/progression/upgrade_manager.dart';
import 'package:get_it/get_it.dart';

/// Combo system for MG-0013 Arena Legends
/// Tracks consecutive skill usage and damage output to provide increasing bonuses
class ComboSystem extends ChangeNotifier {
  // Combo state
  int _currentCombo = 0;
  double _comboTimer = 0.0;
  double _lastDamageTime = 0.0;
  double _totalDamageInCombo = 0.0;
  int _skillsUsedInCombo = 0;

  // Combo statistics
  int _maxCombo = 0;
  int _totalCombosCompleted = 0;
  double _totalComboDamage = 0.0;

  // Getters
  int get currentCombo => _currentCombo;
  double get comboTimer => _comboTimer;
  int get maxCombo => _maxCombo;
  int get totalCombosCompleted => _totalCombosCompleted;
  double get totalComboDamage => _totalComboDamage;
  int get skillsUsedInCombo => _skillsUsedInCombo;

  // Combo tiers
  static const int comboTier1 = 3;  // Bronze combo
  static const int comboTier2 = 5;  // Silver combo
  static const int comboTier3 = 8;  // Gold combo
  static const int comboTier4 = 12; // Platinum combo
  static const int comboTier5 = 16; // Diamond combo
  static const int comboTier6 = 20; // Master combo

  // Timing
  static const double comboWindowSeconds = 3.0;
  static const double comboDecayRate = 1.0;

  /// Get current combo tier multiplier
  double getComboMultiplier() {
    if (_currentCombo >= comboTier6) return 2.5;  // Master
    if (_currentCombo >= comboTier5) return 2.0;  // Diamond
    if (_currentCombo >= comboTier4) return 1.75; // Platinum
    if (_currentCombo >= comboTier3) return 1.5;  // Gold
    if (_currentCombo >= comboTier2) return 1.25; // Silver
    if (_currentCombo >= comboTier1) return 1.1;  // Bronze
    return 1.0;
  }

  /// Get combo tier name for UI display
  String getComboTierName() {
    if (_currentCombo >= comboTier6) return 'MASTER';
    if (_currentCombo >= comboTier5) return 'DIAMOND';
    if (_currentCombo >= comboTier4) return 'PLATINUM';
    if (_currentCombo >= comboTier3) return 'GOLD';
    if (_currentCombo >= comboTier2) return 'SILVER';
    if (_currentCombo >= comboTier1) return 'BRONZE';
    return 'NONE';
  }

  /// Get combo tier color (ARGB for Flutter)
  int getComboTierColor() {
    if (_currentCombo >= comboTier6) return 0xFFFF4500; // Orange-Red
    if (_currentCombo >= comboTier5) return 0xFF00BFFF; // Deep Sky Blue
    if (_currentCombo >= comboTier4) return 0xFF00CED1; // Dark Turquoise
    if (_currentCombo >= comboTier3) return 0xFFFFD700; // Gold
    if (_currentCombo >= comboTier2) return 0xFFC0C0C0; // Silver
    if (_currentCombo >= comboTier1) return 0xFF8B6914; // Bronze
    return 0xFF808080; // Gray
  }

  /// Check if combo is at a tier milestone (for visual effects)
  bool isTierMilestone() {
    return _currentCombo == comboTier1 ||
           _currentCombo == comboTier2 ||
           _currentCombo == comboTier3 ||
           _currentCombo == comboTier4 ||
           _currentCombo == comboTier5 ||
           _currentCombo == comboTier6;
  }

  /// Calculate bonus damage from combo upgrades
  double getUpgradeBonus() {
    try {
      final upgradeManager = GetIt.I<UpgradeManager>();
      final comboUpgrade = upgradeManager.getUpgrade('combo_bonus');
      if (comboUpgrade != null) {
        return comboUpgrade.currentValue * _currentCombo;
      }
    } catch (e) {
      debugPrint('Error getting combo upgrade: $e');
    }
    return 0.0;
  }

  /// Register damage dealt and update combo
  double registerDamage(double baseDamage) {
    final now = _comboTimer;

    // Check if combo expired
    if (now - _lastDamageTime > comboWindowSeconds) {
      _completeCombo();
      _resetCombo();
    }

    // Update combo state
    _currentCombo++;
    _lastDamageTime = now;
    _totalDamageInCombo += baseDamage;
    _totalComboDamage += baseDamage;

    // Calculate final damage with combo multiplier
    final comboMultiplier = getComboMultiplier();
    final upgradeBonus = getUpgradeBonus();
    final finalMultiplier = comboMultiplier + upgradeBonus;
    final finalDamage = baseDamage * finalMultiplier;

    // Update max combo
    if (_currentCombo > _maxCombo) {
      _maxCombo = _currentCombo;
    }

    notifyListeners();
    return finalDamage;
  }

  /// Register skill usage (counts toward combo)
  void registerSkillUsage() {
    _skillsUsedInCombo++;
    notifyListeners();
  }

  /// Update combo timer (call each frame)
  void update(double dt) {
    _comboTimer += dt;

    // Check if combo expired
    if (_currentCombo > 0 && _comboTimer - _lastDamageTime > comboWindowSeconds) {
      _completeCombo();
      _resetCombo();
    }
  }

  /// Complete current combo and calculate rewards
  void _completeCombo() {
    if (_currentCombo > 0) {
      _totalCombosCompleted++;

      // Calculate completion bonus
      final tierMultiplier = getComboMultiplier();
      final completionBonus = (_totalDamageInCombo * 0.1 * tierMultiplier).round();

      debugPrint('Combo completed! Count: $_currentCombo, Damage: ${_totalDamageInCombo.toStringAsFixed(1)}, Bonus: $completionBonus');
    }
  }

  /// Reset combo state
  void _resetCombo() {
    _currentCombo = 0;
    _comboTimer = 0.0;
    _lastDamageTime = 0.0;
    _totalDamageInCombo = 0.0;
    _skillsUsedInCombo = 0;
    notifyListeners();
  }

  /// Reset combo (e.g., when taking damage or battle ends)
  void resetCombo() {
    _completeCombo();
    _resetCombo();
  }

  /// Get combo statistics for battle summary
  Map<String, dynamic> getBattleStats() {
    return {
      'maxCombo': _maxCombo,
      'totalCombosCompleted': _totalCombosCompleted,
      'totalComboDamage': _totalComboDamage,
      'averageComboLength': _totalCombosCompleted > 0
          ? _maxCombo / _totalCombosCompleted
          : 0.0,
    };
  }

  /// Reset statistics (new battle)
  void resetStats() {
    _maxCombo = 0;
    _totalCombosCompleted = 0;
    _totalComboDamage = 0.0;
    resetCombo();
  }
}

/// Combo reward data for battle end calculations
class ComboRewardData {
  final int maxCombo;
  final int totalCombos;
  final double totalDamage;
  final int bonusGold;

  const ComboRewardData({
    required this.maxCombo,
    required this.totalCombos,
    required this.totalDamage,
    required this.bonusGold,
  });

  /// Calculate gold bonus from combo performance
  static ComboRewardData fromStats(Map<String, dynamic> stats) {
    final maxCombo = stats['maxCombo'] as int;
    final totalCombos = stats['totalCombosCompleted'] as int;
    final totalDamage = stats['totalComboDamage'] as double;

    // Bonus formula: maxCombo * 10 + totalCombos * 5
    final bonusGold = (maxCombo * 10) + (totalCombos * 5);

    return ComboRewardData(
      maxCombo: maxCombo,
      totalCombos: totalCombos,
      totalDamage: totalDamage,
      bonusGold: bonusGold,
    );
  }
}