import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_icon_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_linear_progress.dart';
import 'package:mg_common_game/core/ui/widgets/indicators/mg_resource_bar.dart';

/// MG-0013 Arena Legend HUD
/// 아레나 리그 게임용 HUD - 랭크, 티어, 골드, 배틀 정보 표시
class MGArenaHud extends StatelessWidget {
  final int gold;
  final int gems;
  final String rankTier;
  final int rankPoints;
  final int maxRankPoints;
  final int winStreak;
  final VoidCallback? onPause;
  final VoidCallback? onSettings;

  const MGArenaHud({
    super.key,
    required this.gold,
    required this.gems,
    required this.rankTier,
    required this.rankPoints,
    required this.maxRankPoints,
    this.winStreak = 0,
    this.onPause,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              children: [
                // 랭크 정보
                _buildRankBadge(),
                const Spacer(),
                // 자원 표시
                MGResourceBar(
                  resources: [
                    ResourceItem(
                      icon: Icons.monetization_on,
                      value: gold,
                      color: MGColors.resourceGold,
                    ),
                    ResourceItem(
                      icon: Icons.diamond,
                      value: gems,
                      color: MGColors.resourceGem,
                    ),
                  ],
                ),
                const SizedBox(width: MGSpacing.sm),
                // 설정 버튼
                if (onSettings != null)
                  MGIconButton(
                    icon: Icons.settings,
                    onPressed: onSettings!,
                    size: MGIconButtonSize.small,
                  ),
                // 일시정지 버튼
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    size: MGIconButtonSize.small,
                  ),
              ],
            ),
            const SizedBox(height: MGSpacing.xs),
            // 랭크 진행도
            _buildRankProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTierColor().withOpacity(0.8),
            _getTierColor().withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(
          color: _getTierColor(),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTierIcon(),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: MGSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rankTier,
                style: MGTextStyles.buttonMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (winStreak > 0)
                Text(
                  '🔥 $winStreak Win Streak',
                  style: MGTextStyles.caption.copyWith(
                    color: Colors.orangeAccent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
      ),
      child: Row(
        children: [
          Text(
            'Rank Points',
            style: MGTextStyles.caption.copyWith(
              color: MGColors.textSecondary,
            ),
          ),
          const SizedBox(width: MGSpacing.sm),
          Expanded(
            child: MGLinearProgress(
              value: rankPoints / maxRankPoints,
              height: 8,
              backgroundColor: MGColors.surface,
              progressColor: _getTierColor(),
            ),
          ),
          const SizedBox(width: MGSpacing.sm),
          Text(
            '$rankPoints / $maxRankPoints',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor() {
    switch (rankTier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      case 'diamond':
        return const Color(0xFFB9F2FF);
      case 'master':
        return const Color(0xFF9932CC);
      case 'grandmaster':
        return const Color(0xFFFF4500);
      default:
        return MGColors.primaryAction;
    }
  }

  IconData _getTierIcon() {
    switch (rankTier.toLowerCase()) {
      case 'bronze':
        return Icons.shield;
      case 'silver':
        return Icons.shield;
      case 'gold':
        return Icons.shield;
      case 'platinum':
        return Icons.military_tech;
      case 'diamond':
        return Icons.diamond;
      case 'master':
        return Icons.star;
      case 'grandmaster':
        return Icons.emoji_events;
      default:
        return Icons.shield;
    }
  }
}
