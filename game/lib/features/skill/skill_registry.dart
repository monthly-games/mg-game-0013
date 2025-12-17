import 'skill_data.dart';

/// Global skill registry for easy lookup by ID
class SkillRegistry {
  static final Map<String, SkillData> _skills = {};

  /// Initialize the skill registry
  static void initialize() {
    _skills.clear();

    // Register all skills
    _registerSkill(Skills.slash);
    _registerSkill(Skills.charge);
    _registerSkill(Skills.whirlwind);

    _registerSkill(Skills.preciseShot);
    _registerSkill(Skills.multishot);
    _registerSkill(Skills.poisonArrow);

    _registerSkill(Skills.fireball);
    _registerSkill(Skills.frostbolt);
    _registerSkill(Skills.arcaneBlast);

    _registerSkill(Skills.shieldBash);
    _registerSkill(Skills.taunt);
    _registerSkill(Skills.ironWall);

    _registerSkill(Skills.backstab);
    _registerSkill(Skills.shadowStep);
    _registerSkill(Skills.criticalStrike);

    _registerSkill(Skills.heal);
    _registerSkill(Skills.bless);
    _registerSkill(Skills.resurrection);
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
