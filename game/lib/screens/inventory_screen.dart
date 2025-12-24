import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import '../features/league/league_manager.dart';
import '../features/hero/hero_data.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mercenary Inventory', style: AppTextStyles.header2),
        centerTitle: true,
      ),
      body: Consumer<LeagueManager>(
        builder: (context, lm, child) {
          return Column(
            children: [
              // Header with team slots
              _buildTeamSection(context, lm),

              const Divider(color: AppColors.textDisabled, thickness: 2),

              // Inventory header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Inventory (${lm.heroInventory.length}/30)',
                      style: AppTextStyles.subHeader,
                    ),
                    Text(
                      '💰 ${lm.gold}',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Inventory grid
              Expanded(
                child: lm.heroInventory.isEmpty
                    ? _buildEmptyState()
                    : _buildInventoryGrid(context, lm),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context, LeagueManager lm) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Team (Max 5)', style: AppTextStyles.subHeader),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: Row(
              children: List.generate(5, (index) {
                if (index < lm.myTeam.length) {
                  final hero = lm.myTeam[index];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildTeamSlotFilled(context, lm, hero),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildTeamSlotEmpty(),
                    ),
                  );
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSlotFilled(
    BuildContext context,
    LeagueManager lm,
    HeroData hero,
  ) {
    return GestureDetector(
      onTap: () => _showHeroDetails(context, lm, hero),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _getRarityColor(hero.rarity), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getJobIcon(hero.job),
              size: 28,
              color: _getRarityColor(hero.rarity),
            ),
            const SizedBox(height: 4),
            Text(
              hero.name,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: _getRarityColor(hero.rarity),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            Text(
              '⭐' * (hero.rarity.index + 1),
              style: const TextStyle(fontSize: 6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSlotEmpty() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textDisabled, width: 1),
      ),
      child: Center(
        child: Icon(Icons.add, color: AppColors.textDisabled, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            'No mercenaries in inventory',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMediumEmphasis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Recruit heroes from the shop',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(BuildContext context, LeagueManager lm) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: lm.heroInventory.length,
      itemBuilder: (context, index) {
        final hero = lm.heroInventory[index];
        final isInTeam = lm.isInTeam(hero);

        return GestureDetector(
          onTap: () => _showHeroDetails(context, lm, hero),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isInTeam
                    ? AppColors.primary
                    : _getRarityColor(hero.rarity),
                width: isInTeam ? 3 : 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // In Team Badge
                if (isInTeam)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'IN TEAM',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),

                // Job Icon
                Icon(
                  _getJobIcon(hero.job),
                  size: 36,
                  color: _getRarityColor(hero.rarity),
                ),
                const SizedBox(height: 4),

                // Name
                Text(
                  hero.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: _getRarityColor(hero.rarity),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Rarity Stars
                Text(
                  '⭐' * (hero.rarity.index + 1),
                  style: const TextStyle(fontSize: 8),
                ),

                // Job
                Text(
                  hero.job.name.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMediumEmphasis,
                    fontSize: 9,
                  ),
                ),

                // Level
                Text(
                  'Lv.${hero.level}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textDisabled,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHeroDetails(BuildContext context, LeagueManager lm, HeroData hero) {
    final isInTeam = lm.isInTeam(hero);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: Row(
          children: [
            Icon(_getJobIcon(hero.job), color: _getRarityColor(hero.rarity)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hero.name,
                    style: AppTextStyles.subHeader.copyWith(
                      color: _getRarityColor(hero.rarity),
                    ),
                  ),
                  Text(
                    '⭐' * (hero.rarity.index + 1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job & Level
              _buildDetailRow('Job', hero.job.name.toUpperCase()),
              _buildDetailRow('Level', hero.level.toString()),
              _buildDetailRow('Rarity', hero.rarity.name.toUpperCase()),

              const Divider(color: AppColors.textDisabled),

              // Stats
              Text('Combat Stats', style: AppTextStyles.subHeader),
              const SizedBox(height: 8),
              _buildStatBar('HP', hero.maxHp, 250, Colors.green),
              _buildStatBar('ATK', hero.attack, 50, Colors.red),
              _buildStatBar('DEF', hero.defense, 30, Colors.blue),
              _buildStatBar('SPD', hero.speed, 100, Colors.orange),
              _buildDetailRow(
                'Crit Rate',
                '${(hero.critRate * 100).toStringAsFixed(1)}%',
              ),
              _buildDetailRow(
                'Crit Damage',
                '${(hero.critDamage * 100).toStringAsFixed(0)}%',
              ),
              _buildDetailRow('Range', hero.range.toStringAsFixed(0)),

              const Divider(color: AppColors.textDisabled),

              // Skill
              Text('Skill', style: AppTextStyles.subHeader),
              const SizedBox(height: 8),
              Text(
                hero.skill.name,
                style: AppTextStyles.body.copyWith(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                hero.skill.description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMediumEmphasis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cooldown: ${hero.skill.cooldown}s',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Sell Button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmSell(context, lm, hero);
            },
            child: Text(
              'SELL (${(hero.cost * 0.5).toInt()} 💰)',
              style: const TextStyle(color: Colors.red),
            ),
          ),

          // Add/Remove from Team
          TextButton(
            onPressed: isInTeam
                ? () {
                    lm.removeFromTeam(hero);
                    Navigator.pop(context);
                  }
                : (lm.myTeam.length < 5
                      ? () {
                          lm.addToTeam(hero);
                          Navigator.pop(context);
                        }
                      : null),
            child: Text(
              isInTeam ? 'REMOVE FROM TEAM' : 'ADD TO TEAM',
              style: TextStyle(
                color: isInTeam ? Colors.orange : AppColors.primary,
              ),
            ),
          ),

          // Close
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _confirmSell(BuildContext context, LeagueManager lm, HeroData hero) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text('Sell Mercenary?', style: AppTextStyles.subHeader),
        content: Text(
          'Sell ${hero.name} for ${(hero.cost * 0.5).toInt()} 💰?\n\nThis action cannot be undone.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textMediumEmphasis,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              lm.sellHero(hero);
              Navigator.pop(context);
            },
            child: const Text('SELL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMediumEmphasis,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHighEmphasis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, double value, double max, Color color) {
    final ratio = (value / max).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMediumEmphasis,
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: ratio,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getJobIcon(HeroJob job) {
    switch (job) {
      case HeroJob.warrior:
        return Icons.shield;
      case HeroJob.archer:
        return Icons.sports_baseball;
      case HeroJob.mage:
        return Icons.auto_fix_high;
      case HeroJob.tank:
        return Icons.security;
      case HeroJob.assassin:
        return Icons.flash_on;
      case HeroJob.healer:
        return Icons.favorite;
    }
  }

  Color _getRarityColor(HeroRarity rarity) {
    switch (rarity) {
      case HeroRarity.common:
        return Colors.grey;
      case HeroRarity.uncommon:
        return Colors.green;
      case HeroRarity.rare:
        return Colors.blue;
      case HeroRarity.epic:
        return Colors.purple;
      case HeroRarity.legendary:
        return Colors.amber;
    }
  }
}
