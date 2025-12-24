import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../../features/league/league_manager.dart';
import '../../features/hero/hero_data.dart';

class RecruitScreen extends StatefulWidget {
  const RecruitScreen({super.key});

  @override
  State<RecruitScreen> createState() => _RecruitScreenState();
}

class _RecruitScreenState extends State<RecruitScreen> {
  HeroData? _lastRecruit;

  void _onRecruit(BuildContext context, bool isPremium) async {
    final manager = Provider.of<LeagueManager>(context, listen: false);
    final hero = await manager.recruitHero(isPremium);

    if (hero != null) {
      GetIt.I<AudioManager>().playSfx('summon.wav'); // Play SFX
      setState(() {
        _lastRecruit = hero;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not enough currency!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<LeagueManager>(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Recruit Heroes"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Currencies
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CurrencyChip(
                  label: "Gold",
                  value: manager.gold,
                  color: Colors.amber,
                ),
                const SizedBox(width: 20),
                _CurrencyChip(
                  label: "Crystals",
                  value: manager.crystals,
                  color: Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Summon Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummonCard(
                  title: "Normal Summon",
                  cost: "100 Gold",
                  color: Colors.blueGrey,
                  onTap: () => _onRecruit(context, false),
                ),
                _SummonCard(
                  title: "Premium Summon",
                  cost: "100 Crystals",
                  color: Colors.purpleAccent,
                  onTap: () => _onRecruit(context, true),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Result Display with Animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _lastRecruit != null
                  ? Column(
                      key: ValueKey<String>(
                        _lastRecruit!.id,
                      ), // Unique key triggers animation
                      children: [
                        const Text(
                          "SUMMONED!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _HeroCard(_lastRecruit!),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CurrencyChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text("$value", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _SummonCard extends StatelessWidget {
  final String title;
  final String cost;
  final Color color;
  final VoidCallback onTap;

  const _SummonCard({
    required this.title,
    required this.cost,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 48, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(cost, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final HeroData hero;

  const _HeroCard(this.hero);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Text(
            hero.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "${hero.rarity.name.toUpperCase()} ${hero.job.name}",
            style: TextStyle(color: Colors.grey[400]),
          ),
          const Divider(),
          Text("ATK: ${hero.attack.toInt()}"),
          Text("DEF: ${hero.defense.toInt()}"),
          Text("HP: ${hero.maxHp.toInt()}"),
        ],
      ),
    );
  }
}
