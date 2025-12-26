/// Skill system for Arena Legends
library;

enum SkillType {
  damage, // 데미지 스킬
  heal, // 힐 스킬
  buff, // 버프 스킬
  debuff, // 디버프 스킬
  aoe, // 광역 스킬
}

enum SkillTarget {
  enemy, // 적 단일 대상
  ally, // 아군 단일 대상
  self, // 자신
  allEnemies, // 모든 적
  allAllies, // 모든 아군
}

class SkillData {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final SkillTarget target;

  // Cooldown
  final double cooldown; // 쿨다운 시간 (초)

  // Effect values
  final double value; // 스킬 효과 값 (데미지, 힐량 등)
  final double? duration; // 지속 시간 (버프/디버프)
  final double? aoeRadius; // AOE 범위

  // Mana cost (if applicable)
  final double manaCost;

  // Visual
  final String? iconPath;
  final String? animationName;

  const SkillData({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.target,
    required this.cooldown,
    required this.value,
    this.duration,
    this.aoeRadius,
    this.manaCost = 0,
    this.iconPath,
    this.animationName,
  });

  /// Create a copy with modified fields
  SkillData copyWith({
    String? id,
    String? name,
    String? description,
    SkillType? type,
    SkillTarget? target,
    double? cooldown,
    double? value,
    double? duration,
    double? aoeRadius,
    double? manaCost,
    String? iconPath,
    String? animationName,
  }) {
    return SkillData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      cooldown: cooldown ?? this.cooldown,
      value: value ?? this.value,
      duration: duration ?? this.duration,
      aoeRadius: aoeRadius ?? this.aoeRadius,
      manaCost: manaCost ?? this.manaCost,
      iconPath: iconPath ?? this.iconPath,
      animationName: animationName ?? this.animationName,
    );
  }
}

/// Predefined skills
class Skills {
  // Warrior skills
  static const slash = SkillData(
    id: 'skill_slash',
    name: 'Slash',
    description: 'Deal 150% damage to single enemy',
    type: SkillType.damage,
    target: SkillTarget.enemy,
    cooldown: 5.0,
    value: 1.5,
    iconPath: 'skills/skill_slash.png',
    animationName: 'skills/slash_effect.png',
  );

  static const whirlwind = SkillData(
    id: 'skill_whirlwind',
    name: 'Whirlwind',
    description: 'Deal 100% damage to all nearby enemies',
    type: SkillType.aoe,
    target: SkillTarget.allEnemies,
    cooldown: 10.0,
    value: 1.0,
    aoeRadius: 150.0,
    iconPath: 'skills/skill_slash.png', // Fallback or reusing slash icon
    animationName: 'skills/whirlwind_effect.png',
  );

  static const battleCry = SkillData(
    id: 'skill_battle_cry',
    name: 'Battle Cry',
    description: 'Increase all allies attack by 30% for 5s',
    type: SkillType.buff,
    target: SkillTarget.allAllies,
    cooldown: 15.0,
    value: 0.3,
    duration: 5.0,
    iconPath:
        'skills/skill_shield_bash.png', // Reusing shield bash icon as fallback
    animationName: 'skills/charge_effect.png', // Fallback effect
  );

  // Archer skills
  static const preciseShot = SkillData(
    id: 'skill_precise_shot',
    name: 'Precise Shot',
    description: 'Deal 200% damage to single enemy',
    type: SkillType.damage,
    target: SkillTarget.enemy,
    cooldown: 6.0,
    value: 2.0,
    iconPath: 'skills/skill_fireball.png', // Placeholder
    animationName: 'skills/precise_shot_effect.png',
  );

  static const multiShot = SkillData(
    id: 'skill_multi_shot',
    name: 'Multi Shot',
    description: 'Deal 80% damage to 3 random enemies',
    type: SkillType.damage,
    target: SkillTarget.allEnemies,
    cooldown: 8.0,
    value: 0.8,
    iconPath: 'skills/skill_fireball.png', // Placeholder
    animationName: 'skills/multishot_effect.png',
  );

  static const poisonArrow = SkillData(
    id: 'skill_poison_arrow',
    name: 'Poison Arrow',
    description: 'Deal 120% damage and reduce enemy attack by 20% for 5s',
    type: SkillType.debuff,
    target: SkillTarget.enemy,
    cooldown: 10.0,
    value: 1.2,
    duration: 5.0,
    iconPath: 'skills/skill_slash.png', // Placeholder
    animationName: 'skills/poison_arrow_effect.png',
  );

  // Mage skills
  static const fireball = SkillData(
    id: 'skill_fireball',
    name: 'Fireball',
    description: 'Deal 180% magic damage to single enemy',
    type: SkillType.damage,
    target: SkillTarget.enemy,
    cooldown: 7.0,
    value: 1.8,
    manaCost: 30,
    iconPath: 'skills/skill_fireball.png',
    animationName: 'skills/fireball_effect.png',
  );

  static const frostNova = SkillData(
    id: 'skill_frost_nova',
    name: 'Frost Nova',
    description: 'Deal 100% damage and slow all nearby enemies',
    type: SkillType.aoe,
    target: SkillTarget.allEnemies,
    cooldown: 12.0,
    value: 1.0,
    aoeRadius: 200.0,
    manaCost: 50,
    iconPath: 'skills/skill_fireball.png', // Placeholder
    animationName: 'skills/frostbolt_effect.png',
  );

  static const arcaneBarrier = SkillData(
    id: 'skill_arcane_barrier',
    name: 'Arcane Barrier',
    description: 'Shield self for 50% of max HP',
    type: SkillType.buff,
    target: SkillTarget.self,
    cooldown: 15.0,
    value: 0.5,
    duration: 5.0,
    manaCost: 40,
    iconPath: 'skills/skill_heal.png', // Placeholder
    animationName: 'skills/arcane_blast_effect.png',
  );

  // Tank skills
  static const shieldBash = SkillData(
    id: 'skill_shield_bash',
    name: 'Shield Bash',
    description: 'Deal 120% damage and stun enemy for 1s',
    type: SkillType.damage,
    target: SkillTarget.enemy,
    cooldown: 8.0,
    value: 1.2,
    duration: 1.0,
    iconPath: 'skills/skill_shield_bash.png',
    animationName: 'skills/shield_bash_effect.png',
  );

  static const ironWill = SkillData(
    id: 'skill_iron_will',
    name: 'Iron Will',
    description: 'Increase self defense by 50% for 5s',
    type: SkillType.buff,
    target: SkillTarget.self,
    cooldown: 12.0,
    value: 0.5,
    duration: 5.0,
    iconPath: 'skills/skill_shield_bash.png', // Placeholder
    animationName: 'skills/iron_wall_effect.png',
  );

  static const taunt = SkillData(
    id: 'skill_taunt',
    name: 'Taunt',
    description: 'Force all enemies to target you for 3s',
    type: SkillType.debuff,
    target: SkillTarget.allEnemies,
    cooldown: 15.0,
    value: 1.0,
    duration: 3.0,
    iconPath: 'skills/skill_shield_bash.png', // Placeholder
    animationName: 'skills/taunt_effect.png',
  );

  // Assassin skills
  static const backstab = SkillData(
    id: 'skill_backstab',
    name: 'Backstab',
    description: 'Deal 250% damage to single enemy',
    type: SkillType.damage,
    target: SkillTarget.enemy,
    cooldown: 8.0,
    value: 2.5,
    iconPath: 'skills/skill_slash.png', // Placeholder
    animationName: 'skills/backstab_effect.png',
  );

  static const shadowStep = SkillData(
    id: 'skill_shadow_step',
    name: 'Shadow Step',
    description: 'Become invisible and increase attack speed by 50% for 3s',
    type: SkillType.buff,
    target: SkillTarget.self,
    cooldown: 12.0,
    value: 0.5,
    duration: 3.0,
    iconPath: 'skills/skill_slash.png', // Placeholder
    animationName: 'skills/shadow_step_effect.png',
  );

  static const executioner = SkillData(
    id: 'skill_executioner',
    name: 'Executioner',
    description: 'Deal 400% damage to enemies below 30% HP',
    type: SkillType.damage,
    target: SkillTarget.enemy,
    cooldown: 15.0,
    value: 4.0,
    iconPath: 'skills/skill_slash.png', // Placeholder
    animationName: 'skills/critical_strike_effect.png',
  );

  // Healer skills
  static const heal = SkillData(
    id: 'skill_heal',
    name: 'Heal',
    description: 'Restore 40% HP to single ally',
    type: SkillType.heal,
    target: SkillTarget.ally,
    cooldown: 5.0,
    value: 0.4,
    manaCost: 25,
    iconPath: 'skills/skill_heal.png',
    animationName: 'skills/heal_effect.png',
  );

  static const groupHeal = SkillData(
    id: 'skill_group_heal',
    name: 'Group Heal',
    description: 'Restore 25% HP to all allies',
    type: SkillType.heal,
    target: SkillTarget.allAllies,
    cooldown: 10.0,
    value: 0.25,
    manaCost: 50,
    iconPath: 'skills/skill_heal.png', // Placeholder
    animationName: 'skills/resurrection_effect.png',
  );

  static const bless = SkillData(
    id: 'skill_bless',
    name: 'Bless',
    description: 'Increase all allies HP regeneration by 5/s for 5s',
    type: SkillType.buff,
    target: SkillTarget.allAllies,
    cooldown: 15.0,
    value: 5.0,
    duration: 5.0,
    manaCost: 40,
    iconPath: 'skills/skill_heal.png', // Placeholder
    animationName: 'skills/bless_effect.png',
  );

  /// Get all skills as a list
  static List<SkillData> get all => [
    slash,
    whirlwind,
    battleCry,
    preciseShot,
    multiShot,
    poisonArrow,
    fireball,
    frostNova,
    arcaneBarrier,
    shieldBash,
    ironWill,
    taunt,
    backstab,
    shadowStep,
    executioner,
    heal,
    groupHeal,
    bless,
  ];

  /// Get skills by ID
  static SkillData? getById(String id) {
    try {
      return all.firstWhere((skill) => skill.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get skills by type
  static List<SkillData> getByType(SkillType type) {
    return all.where((skill) => skill.type == type).toList();
  }
}
