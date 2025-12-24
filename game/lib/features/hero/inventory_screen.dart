import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/league/league_manager.dart';
import '../../features/hero/hero_data.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Temporary team selection state
  List<String> _selectedIds = [];

  @override
  void initState() {
    super.initState();
    // Initialize with current team
    final manager = Provider.of<LeagueManager>(context, listen: false);
    _selectedIds = List.from(manager.myTeam.map((h) => h.id));
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        if (_selectedIds.length < 5) {
          _selectedIds.add(id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Team is full! Remove a hero first.")),
          );
        }
      }
    });
  }

  void _saveTeam() async {
    final manager = Provider.of<LeagueManager>(context, listen: false);
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Team cannot be empty!")));
      return;
    }
    await manager.updateTeam(_selectedIds);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<LeagueManager>(context);
    final heroes = manager.heroes;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Manage Team"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveTeam),
        ],
      ),
      body: Column(
        children: [
          // Team Preview
          Container(
            height: 100,
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _selectedIds.map((id) {
                final hero = heroes.firstWhere(
                  (h) => h.id == id,
                  orElse: () => heroes.first,
                ); // fallback safe
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Text(hero.job.name[0].toUpperCase()),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: heroes.length,
              itemBuilder: (context, index) {
                final hero = heroes[index];
                final isSelected = _selectedIds.contains(hero.id);

                return GestureDetector(
                  onTap: () => _toggleSelection(hero.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey[800],
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hero.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hero.job.name,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "Lv.${hero.level}",
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
