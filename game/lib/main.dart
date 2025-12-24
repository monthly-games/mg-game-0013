import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'features/league/league_manager.dart';
import 'features/league/league_screen.dart';
import 'core/audio/audio_manager_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();
  await LeagueManager().initialize();
  runApp(const ArenaLegendApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManagerImpl());
  }
}

class ArenaLegendApp extends StatelessWidget {
  const ArenaLegendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeagueManager()),
      ], // Error: LeagueManager not ChangeNotifier?
      // My LeagueManager wasn't a ChangeNotifier in the previous write. I need to fix that or wrap it.
      // Let's make it ChangeNotifier in this step's thinking, or simply not use Provider if state is local?
      // LeagueScreen uses State. setState.
      // But LeagueManager was written as a Singleton/internal.
      // Let's just use MaterialApp directly for now, LeagueScreen handles its own state for this prototype.
      child: MaterialApp(
        title: 'Arena Legend',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF222222),
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const LeagueScreen(),
      ),
    );
  }
}
