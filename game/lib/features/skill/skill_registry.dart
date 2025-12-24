import 'skill_data.dart';

/// Global skill registry for easy lookup by ID
class SkillRegistry {
  static final Map<String, SkillData> _skills = {};

  /// Initialize the skill registry
  static void initialize() {
    _skills.clear();

    // Register all skills
    _registerSkill(Skills.slash);
    _registerSkill(Skills.whirlwind);
    _registerSkill(Skills.battleCry); // Replaced charge

    _registerSkill(Skills.preciseShot);
    _registerSkill(Skills.multiShot); // Fixed typo
    _registerSkill(Skills.poisonArrow);

    _registerSkill(Skills.fireball);
    _registerSkill(Skills.frostNova); // Replaced frostbolt
    _registerSkill(Skills.arcaneBarrier); // Replaced arcaneBlast

    _registerSkill(Skills.shieldBash);
    _registerSkill(Skills.taunt);
    _registerSkill(Skills.ironWill); // Replaced ironWall

    _registerSkill(Skills.backstab);
    _registerSkill(Skills.shadowStep);
    _registerSkill(Skills.executioner); // Replaced criticalStrike

    _registerSkill(Skills.heal);
    _registerSkill(Skills.bless);
    _registerSkill(Skills.groupHeal); // Replaced resurrection
  }

  static void _registerSkill(SkillData skill) {
    _skills[skill.id] = skill;
  }

  /// Get skill by ID
  static SkillData? getSkillById(String id) {
    return _skills[id];
  }

  /// Get all registered skills
  static List<SkillData> getAllSkills() {
    return _skills.values.toList();
  }
}
