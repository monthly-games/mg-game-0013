import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/hero/hero_data.dart';

class StorageService {
  static const String _boxName = 'arena_legends_data';

  // Keys
  static const String _kGold = 'gold';
  static const String _kCrystals = 'crystals';
  static const String _kTickets = 'tickets';
  static const String _kLp = 'lp';
  static const String _kDivision = 'division';
  static const String _kHeroes = 'heroes'; // List<Map>
  static const String _kMyTeam = 'my_team'; // List<String> IDs

  late Box _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // Currency
  int get gold => _box.get(_kGold, defaultValue: 100);
  int get crystals => _box.get(_kCrystals, defaultValue: 0);
  int get tickets => _box.get(_kTickets, defaultValue: 5);

  Future<void> saveCurrencies({
    required int gold,
    required int crystals,
    required int tickets,
  }) async {
    await _box.put(_kGold, gold);
    await _box.put(_kCrystals, crystals);
    await _box.put(_kTickets, tickets);
  }

  // League
  int get lp => _box.get(_kLp, defaultValue: 0);

  Future<void> saveLeague({required int lp}) async {
    await _box.put(_kLp, lp);
  }

  // Heroes
  List<HeroData> getHeroes() {
    final dynamic rawData = _box.get(_kHeroes);
    if (rawData == null) return [];

    try {
      final List<dynamic> list = jsonDecode(rawData);
      return list.map((e) => HeroData.fromJson(e)).toList();
    } catch (e) {
      print('Error loading heroes: $e');
      return [];
    }
  }

  Future<void> saveHeroes(List<HeroData> heroes) async {
    final jsonList = heroes.map((h) => h.toJson()).toList();
    await _box.put(_kHeroes, jsonEncode(jsonList));
  }

  // My Team
  List<String> getMyTeam() {
    return List<String>.from(_box.get(_kMyTeam, defaultValue: <String>[]));
  }

  Future<void> saveMyTeam(List<String> teamIds) async {
    await _box.put(_kMyTeam, teamIds);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
