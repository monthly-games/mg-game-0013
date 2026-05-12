import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../features/league/battle_result_data.dart';
import '../features/league/league_data.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';


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
            padding: const EdgeInsets.all(MGSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: result.isVictory ? Colors.amber : MGColors.error,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Result Header
                _buildResultHeader(),
                const SizedBox(height: MGSpacing.lg),

                // Tier Change (if applicable)
                if (result.tierChanged) ...[
                  _buildTierChange(),
                  const SizedBox(height: MGSpacing.lg),
                ],

                // Rewards Section
                _buildRewardsSection(),
                const SizedBox(height: MGSpacing.lg),

                // Stats Section
                _buildStatsSection(),
                const SizedBox(height: MGSpacing.lg),

                // Record Section
                _buildRecordSection(),
                const SizedBox(height: MGSpacing.xl),

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
          color: result.isVictory ? Colors.amber : MGColors.error,
        ),
        const SizedBox(height: MGSpacing.md),
        // Result Message
        Text(
          result.resultMessage,
          style: AppTextStyles.header1.copyWith(
            color: result.isVictory ? Colors.amber : MGColors.error,
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
      padding: const EdgeInsets.all(MGSpacing.md),
      decoration: BoxDecoration(
        color: isPromotion ? Colors.amber.withValues(alpha: 0.2) : MGColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPromotion ? Colors.amber : MGColors.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPromotion ? Icons.trending_up : Icons.trending_down,
            color: isPromotion ? Colors.amber : MGColors.error,
            size: 40,
          ),
          const SizedBox(height: MGSpacing.xs),
          Text(
            isPromotion ? 'PROMOTED!' : 'RELEGATED',
            style: AppTextStyles.subHeader.copyWith(
              color: isPromotion ? Colors.amber : MGColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: MGSpacing.xxs),
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
      padding: const EdgeInsets.all(MGSpacing.md),
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
          const SizedBox(height: MGSpacing.sm),
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
                label: 'League Points',
                value: result.pointsDisplay,
                color: result.pointsChanged >= 0 ? MGColors.success : MGColors.error,
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
        const SizedBox(height: MGSpacing.xxs),
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
      padding: const EdgeInsets.all(MGSpacing.md),
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
          const SizedBox(height: MGSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Allies Remaining',
                value: result.allyUnitsRemaining.toString(),
                color: MGColors.info,
              ),
              _buildStatItem(
                label: 'Enemies Killed',
                value: result.enemyUnitsKilled.toString(),
                color: MGColors.error,
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
        const SizedBox(height: MGSpacing.xxs),
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
      padding: const EdgeInsets.all(MGSpacing.md),
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
            color: MGColors.success,
          ),
          _buildRecordItem(
            label: 'Total Losses',
            value: result.totalLosses.toString(),
            color: MGColors.error,
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
        const SizedBox(height: MGSpacing.xxs),
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
