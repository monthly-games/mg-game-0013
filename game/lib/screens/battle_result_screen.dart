import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../features/league/battle_result_data.dart';
import '../features/league/league_data.dart';

class BattleResultScreen extends StatelessWidget {
  final BattleResultData result;
  final VoidCallback onClose;

  const BattleResultScreen({
    super.key,
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: result.isVictory ? Colors.amber : Colors.red,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Result Header
                _buildResultHeader(),
                const SizedBox(height: 24),

                // Tier Change (if applicable)
                if (result.tierChanged) ...[
                  _buildTierChange(),
                  const SizedBox(height: 24),
                ],

                // Rewards Section
                _buildRewardsSection(),
                const SizedBox(height: 24),

                // Stats Section
                _buildStatsSection(),
                const SizedBox(height: 24),

                // Record Section
                _buildRecordSection(),
                const SizedBox(height: 32),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: result.isVictory
                          ? AppColors.primary
                          : AppColors.error,
                      foregroundColor: AppColors.textHighEmphasis,
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Column(
      children: [
        // Victory/Defeat Icon
        Icon(
          result.isVictory ? Icons.emoji_events : Icons.cancel,
          size: 80,
          color: result.isVictory ? Colors.amber : Colors.red,
        ),
        const SizedBox(height: 16),
        // Result Message
        Text(
          result.resultMessage,
          style: AppTextStyles.header1.copyWith(
            color: result.isVictory ? Colors.amber : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTierChange() {
    final isPromotion = result.tierChangeType == TierChangeType.promotion;
    final tierData = LeagueTiers.getByTier(result.newTier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPromotion ? Colors.amber.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPromotion ? Colors.amber : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPromotion ? Icons.trending_up : Icons.trending_down,
            color: isPromotion ? Colors.amber : Colors.red,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            isPromotion ? 'PROMOTED!' : 'RELEGATED',
            style: AppTextStyles.subHeader.copyWith(
              color: isPromotion ? Colors.amber : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${LeagueTiers.getByTier(result.previousTier).nameKr} → ${tierData.nameKr}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textHighEmphasis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REWARDS',
            style: AppTextStyles.subHeader.copyWith(
              color: AppColors.textHighEmphasis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Gold Reward
              if (result.goldEarned > 0)
                _buildRewardItem(
                  icon: '💰',
                  label: 'Gold',
                  value: '+${result.goldEarned}',
                  color: Colors.amber,
                ),
              // League Points
              _buildRewardItem(
                icon: '⭐',
                label: 'LP',
                value: result.pointsDisplay,
                color: result.pointsChanged >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMediumEmphasis,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BATTLE STATS',
            style: AppTextStyles.subHeader.copyWith(
              color: AppColors.textHighEmphasis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Allies Remaining',
                value: result.allyUnitsRemaining.toString(),
                color: Colors.blue,
              ),
              _buildStatItem(
                label: 'Enemies Killed',
                value: result.enemyUnitsKilled.toString(),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.header2.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMediumEmphasis,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecordSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildRecordItem(
            label: 'Total Wins',
            value: result.totalWins.toString(),
            color: Colors.green,
          ),
          _buildRecordItem(
            label: 'Total Losses',
            value: result.totalLosses.toString(),
            color: Colors.red,
          ),
          _buildRecordItem(
            label: 'Win Rate',
            value: '${(result.winRate * 100).toStringAsFixed(1)}%',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textMediumEmphasis,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
