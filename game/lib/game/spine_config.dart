import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Arena Fighter ────────────────────────────────────────────

const kArenaFighterMeta = SpineAssetMeta(
  key: 'arena_fighter',
  path: 'spine/characters/arena_fighter',
  atlasPath:
      'assets/spine/characters/arena_fighter/arena_fighter.atlas',
  skeletonPath:
      'assets/spine/characters/arena_fighter/arena_fighter.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Arena Ranger ─────────────────────────────────────────────

const kArenaRangerMeta = SpineAssetMeta(
  key: 'arena_ranger',
  path: 'spine/characters/arena_ranger',
  atlasPath:
      'assets/spine/characters/arena_ranger/arena_ranger.atlas',
  skeletonPath:
      'assets/spine/characters/arena_ranger/arena_ranger.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Arena Mage ───────────────────────────────────────────────

const kArenaMageMeta = SpineAssetMeta(
  key: 'arena_mage',
  path: 'spine/characters/arena_mage',
  atlasPath: 'assets/spine/characters/arena_mage/arena_mage.atlas',
  skeletonPath:
      'assets/spine/characters/arena_mage/arena_mage.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);
