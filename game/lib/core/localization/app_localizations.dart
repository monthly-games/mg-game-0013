// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:mg_common_game/l10n/extensions.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  const AppLocalizations();

  String get notification_rewardslength_rewards_claimed => 'Rewards Claimed';
  String get progress_tier_level_names => 'Tier';
  String get progress_level_battlepasscurrentlevel => 'Battle Pass';
  String get ui_general_hp_heromaxhptoint => 'HP';
  String get ui_general_team_is_full_remove_a => 'Team is full. Remove a hero first.';
  String get error_team_cannot_be_empty => 'Team cannot be empty';
  String get ui_general_manage_team => 'Manage Team';
  String get ui_general_recruit_heroes => 'Recruit Heroes';
  String get ui_general_not_enough_currency => 'Not enough currency';
  String get ui_general_received_500_gold => 'Received 500 Gold';
  String get ui_general_atk_heroattacktoint => 'ATK';
  String get ui_general_def_herodefensetoint => 'DEF';
  String get notification_claim_all__bpmanagerunclaimedrewardcount => 'Claim All';
  String get ui_general__gachatotalpulls_90_90 => 'Gacha';
  String get ui_general_allies_remaining => 'Allies Remaining';
  String get ui_general_enemies_killed => 'Enemies Killed';
  String get game_state_total_wins => 'Total Wins';
  String get ui_general_continue_experiment => 'Continue';
  String get ui_general_10x_pull => '10x Pull';
  String get ui_general_1x_pull => '1x Pull';
  String get game_state_win_rate => 'Win Rate';
  String get ui_general_diwali_token_collection => 'Token Collection';
  String get ui_general_total_losses => 'Total Losses';
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return const AppLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}