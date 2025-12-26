import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'dart:math';
import 'package:flame/effects.dart';
import 'damage_text_component.dart';
import 'arena_projectile.dart';
import 'simple_particle.dart';
import '../arena_game.dart';
import '../../features/hero/hero_data.dart';
import '../../features/skill/skill_data.dart';

enum UnitTeam { ally, enemy }

enum UnitState { idle, moving, attacking, casting, dead }

class UnitComponent extends PositionComponent with HasGameRef<ArenaGame> {
  final UnitTeam team;
  final HeroData data;

  // Combat Stats
  double hp;
  double get maxHp => data.maxHp;
  double get attack => data.attack;
  double get defense => data.defense;
  double get critRate => data.critRate;
  double get critDamage => data.critDamage;

  // Helpers
  bool get isDead => state == UnitState.dead;

  // Skill System
  double _skillCooldownTimer = 0.0;
  bool get canUseSkill => _skillCooldownTimer <= 0;

  // Buffs/Debuffs
  final Map<String, double> _buffs = {};
  final Map<String, double> _debuffs = {};

  // State
  UnitState state = UnitState.idle;
  UnitComponent? target;
  double _attackTimer = 0.0;
  double get attackInterval =>
      1.0 / (data.speed / 50.0); // Speed affects attack speed

  UnitComponent({
    required this.team,
    required this.data,
    required Vector2 position,
  }) : hp = data.maxHp,
       super(position: position, size: Vector2(30, 30), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);

    // Death check
    if (hp <= 0) {
      if (state != UnitState.dead) {
        state = UnitState.dead;
        _spawnDeathParticles();
        removeFromParent();
      }
      return;
    }

    // Update skill cooldown
    if (_skillCooldownTimer > 0) {
      _skillCooldownTimer -= dt;
    }

    // Update buffs/debuffs
    _updateBuffs(dt);

    // AI
    _findTarget();
    _moveOrAttack(dt);
  }

  /// Update buff/debuff timers
  void _updateBuffs(double dt) {
    final expiredBuffs = <String>[];
    _buffs.forEach((key, duration) {
      final newDuration = duration - dt;
      if (newDuration <= 0) {
        expiredBuffs.add(key);
      } else {
        _buffs[key] = newDuration;
      }
    });
    expiredBuffs.forEach(_buffs.remove);

    final expiredDebuffs = <String>[];
    _debuffs.forEach((key, duration) {
      final newDuration = duration - dt;
      if (newDuration <= 0) {
        expiredDebuffs.add(key);
      } else {
        _debuffs[key] = newDuration;
      }
    });
    expiredDebuffs.forEach(_debuffs.remove);
  }

  void _findTarget() {
    if (target != null && target!.parent != null && target!.hp > 0) {
      return;
    }

    target = null;
    double minDistance = double.infinity;

    gameRef.children.query<UnitComponent>().forEach((other) {
      if (other.team != team && other.hp > 0) {
        final dist = position.distanceTo(other.position);
        if (dist < minDistance) {
          minDistance = dist;
          target = other;
        }
      }
    });
  }

  void _moveOrAttack(double dt) {
    if (target == null) {
      state = UnitState.idle;
      return;
    }

    final dist = position.distanceTo(target!.position);
    if (dist <= data.range + target!.width / 2) {
      // In range
      state = UnitState.attacking;
      _attackTimer += dt;

      // Try to use skill if available
      if (canUseSkill) {
        _castSkill();
        _playSfx('skill.wav');
        _attackTimer = 0;
        return;
      }

      // Normal attack
      if (_attackTimer >= attackInterval) {
        _attackTimer = 0;
        if (target != null) {
          _playAttackAnimation(target!.position);
        }
        _performAttack();
      }
    } else {
      // Move toward target
      state = UnitState.moving;
      final dir = (target!.position - position).normalized();
      position += dir * data.speed * dt;
    }
  }

  /// Perform normal attack
  void _performAttack() {
    if (target == null) return;

    final isCrit = Random().nextDouble() < critRate;
    final finalDamage = attack * (isCrit ? critDamage : 1.0);

    if (data.job == HeroJob.archer || data.job == HeroJob.mage) {
      // Ranged Attack
      _playSfx('shoot.wav');
      gameRef.add(
        ArenaProjectile(
          position: position.clone(),
          target: target!,
          damage: finalDamage,
          color: team == UnitTeam.ally
              ? (isCrit ? Colors.yellow : Colors.cyanAccent)
              : (isCrit ? Colors.yellow : Colors.orangeAccent),
        ),
      );
    } else {
      // Melee Attack
      _playSfx('attack.wav');
      target!.takeDamage(finalDamage, isCrit: isCrit);
    }
  }

  /// Cast skill using new skill system
  void _castSkill() {
    state = UnitState.casting;
    final skill = data.skill;

    // Start cooldown
    _skillCooldownTimer = skill.cooldown;

    // Show skill name
    gameRef.add(
      DamageTextComponent(damage: 0, position: position + Vector2(0, -30))
        ..textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        )
        ..text = "${skill.name}!",
    );

    // Show skill icon above head if available
    if (skill.iconPath != null) {
      // Logic to spawn a temporary icon effect could go here,
      // but for now we rely on the specific skill executions to show effects.
    }

    // Execute skill based on type and target
    switch (skill.type) {
      case SkillType.damage:
        _executeDamageSkill(skill);
        break;
      case SkillType.heal:
        _executeHealSkill(skill);
        break;
      case SkillType.buff:
        _executeBuffSkill(skill);
        break;
      case SkillType.debuff:
        _executeDebuffSkill(skill);
        break;
      case SkillType.aoe:
        _executeAOESkill(skill);
        break;
    }
  }

  void _executeDamageSkill(SkillData skill) {
    final damage = attack * skill.value;

    switch (skill.target) {
      case SkillTarget.enemy:
        if (target != null) {
          if (data.job == HeroJob.archer || data.job == HeroJob.mage) {
            // Projectile based skill
            gameRef.add(
              ArenaProjectile(
                position: position.clone(),
                target: target!,
                damage: damage,
                color: Colors.purpleAccent,
                // Pass animation/icon path if we update ArenaProjectile (Task left for future refactor to keep it simple)
              ),
            );
          } else {
            // Melee skill effect
            if (skill.animationName != null) {
              // TODO: Spawn sprite animation component for effect
              // For now, simple particle fallback is fine, logic handled by specific effects or add new effect component
              _playSkillEffect(skill.animationName!, target!.position);
            }
            target!.takeDamage(damage);
          }
        }
        break;
      case SkillTarget.allEnemies:
        gameRef.children.query<UnitComponent>().forEach((other) {
          if (other.team != team) {
            other.takeDamage(damage);
          }
        });
        break;
      default:
        break;
    }
  }

  void _executeHealSkill(SkillData skill) {
    final healAmount = maxHp * skill.value;

    switch (skill.target) {
      case SkillTarget.self:
        hp = (hp + healAmount).clamp(0, maxHp);
        _spawnHealParticles();
        _showHealText(healAmount);
        break;
      case SkillTarget.ally:
        // Heal lowest HP ally
        final ally = _findLowestHPAlly();
        if (ally != null) {
          ally.hp = (ally.hp + healAmount).clamp(0, ally.maxHp);
          ally._spawnHealParticles();
          ally._showHealText(healAmount);
        }
        break;
      case SkillTarget.allAllies:
        gameRef.children.query<UnitComponent>().forEach((other) {
          if (other.team == team) {
            other.hp = (other.hp + healAmount).clamp(0, other.maxHp);
            other._spawnHealParticles();
            other._showHealText(healAmount);
          }
        });
        break;
      default:
        break;
    }
  }

  void _executeBuffSkill(SkillData skill) {
    final duration = skill.duration ?? 5.0;

    switch (skill.target) {
      case SkillTarget.self:
        _buffs[skill.id] = duration;
        break;
      case SkillTarget.allAllies:
        gameRef.children.query<UnitComponent>().forEach((other) {
          if (other.team == team) {
            other._buffs[skill.id] = duration;
          }
        });
        break;
      default:
        break;
    }
  }

  void _executeDebuffSkill(SkillData skill) {
    final duration = skill.duration ?? 5.0;
    final damage = attack * skill.value;

    switch (skill.target) {
      case SkillTarget.enemy:
        if (target != null) {
          target!._debuffs[skill.id] = duration;
          target!.takeDamage(damage);
        }
        break;
      case SkillTarget.allEnemies:
        gameRef.children.query<UnitComponent>().forEach((other) {
          if (other.team != team) {
            other._debuffs[skill.id] = duration;
          }
        });
        break;
      default:
        break;
    }
  }

  void _executeAOESkill(SkillData skill) {
    final damage = attack * skill.value;
    final radius = skill.aoeRadius ?? 150.0;

    gameRef.children.query<UnitComponent>().forEach((other) {
      if (other.team != team && position.distanceTo(other.position) < radius) {
        other.takeDamage(damage);
      }
    });
  }

  UnitComponent? _findLowestHPAlly() {
    UnitComponent? lowestAlly;
    double minHpRatio = 1.0;

    gameRef.children.query<UnitComponent>().forEach((other) {
      if (other.team == team && other.hp < other.maxHp) {
        final ratio = other.hp / other.maxHp;
        if (ratio < minHpRatio) {
          minHpRatio = ratio;
          lowestAlly = other;
        }
      }
    });

    return lowestAlly;
  }

  void _showHealText(double amount) {
    gameRef.add(
      DamageTextComponent(damage: 0, position: position + Vector2(0, -20))
        ..text = "+${amount.toInt()}"
        ..textRenderer = TextPaint(
          style: const TextStyle(color: Colors.green, fontSize: 12),
        ),
    );
  }

  // Effects
  void _playAttackAnimation(Vector2 targetPos) {
    if ((targetPos - position).length < 10) return; // Too close
    final direction = (targetPos - position).normalized();

    // Simple Lunge
    add(
      MoveEffect.to(
        position + direction * 10,
        EffectController(duration: 0.1, reverseDuration: 0.1),
      ),
    );
  }

  void _playHitAnimation() {
    // Flash red or shake
    // In a real sprite component, we'd manipulate the sprite's paint or use a ColorEffect.
    // Since we are using render() override or sprites, let's use a ColorEffect if possible,
    // but ColorEffect works best on SpriteComponent.
    // For now, let's just shake it.
    add(
      MoveEffect.by(
        Vector2(5, 0),
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 2),
      ),
    );
  }

  void takeDamage(double amount, {bool isCrit = false}) {
    _playSfx(isCrit ? 'crit.wav' : 'hit.wav');
    _playHitAnimation();

    // Apply defense reduction
    final finalDamage = (amount - defense).clamp(1, amount);
    hp -= finalDamage;

    // Show Damage Text
    gameRef.add(
      DamageTextComponent(
        damage: finalDamage.toDouble(),
        position: position.clone() + Vector2(0, -20),
        isCrit: isCrit,
      ),
    );
  }

  void _playSfx(String sound) {
    try {
      GetIt.I<AudioManager>().playSfx(sound);
    } catch (_) {}
  }

  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load sprite based on job
    try {
      _sprite = await gameRef.loadSprite('heroes/hero_${data.job.name}.png');
    } catch (e) {
      print('Failed to load sprite for ${data.job.name}: $e');
    }
  }

  @override
  void render(Canvas canvas) {
    // Render sprite if available
    if (_sprite != null) {
      _sprite!.render(canvas, size: size);
    } else {
      // Fallback rendering
      final color = team == UnitTeam.ally ? Colors.blue : Colors.red;
      final paint = Paint()..color = color;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    }

    // HP Bar
    final hpRatio = hp / maxHp;
    canvas.drawRect(
      Rect.fromLTWH(0, -10, width, 5),
      Paint()..color = Colors.black,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, -10, width * hpRatio.clamp(0, 1), 5),
      Paint()..color = Colors.green,
    );

    // Skill Cooldown Bar
    if (_skillCooldownTimer > 0) {
      final cooldownRatio = _skillCooldownTimer / data.skill.cooldown;
      canvas.drawRect(
        Rect.fromLTWH(0, -5, width, 3),
        Paint()..color = Colors.black54,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, -5, width * cooldownRatio.clamp(0, 1), 3),
        Paint()..color = Colors.orangeAccent,
      );
    } else {
      // Skill ready indicator
      canvas.drawRect(
        Rect.fromLTWH(0, -5, width, 3),
        Paint()..color = Colors.yellow,
      );
    }
  }

  void _spawnDeathParticles() {
    final rand = Random();
    for (int i = 0; i < 15; i++) {
      gameRef.add(
        SimpleParticle(
          position: position.clone(),
          velocity: Vector2(
            (rand.nextDouble() - 0.5) * 200,
            (rand.nextDouble() - 0.5) * 200,
          ),
          color: team == UnitTeam.ally ? Colors.blue : Colors.red,
          lifeTime: 0.5 + rand.nextDouble() * 0.5,
        ),
      );
    }
  }

  void _spawnHealParticles() {
    final rand = Random();
    for (int i = 0; i < 8; i++) {
      gameRef.add(
        SimpleParticle(
          position:
              position.clone() + Vector2((rand.nextDouble() - 0.5) * 20, 0),
          velocity: Vector2(0, -50 - rand.nextDouble() * 50),
          color: Colors.greenAccent,
        ),
      );
    }
  }

  void _playSkillEffect(String assetPath, Vector2 pos) {
    // Placeholder: In a real implementation we would load the sprite sequence.
    // Since we only have static images for effects (e.g. slash_effect.png), we can show it briefly.
    final effectComponent = SpriteComponent()
      ..position = pos
      ..size = Vector2(50, 50)
      ..anchor = Anchor.center
      ..add(
        OpacityEffect.fadeOut(EffectController(duration: 0.5, startDelay: 0.2)),
      )
      ..add(RemoveEffect(delay: 0.8));

    gameRef.add(effectComponent);

    // Async load fix:
    gameRef
        .loadSprite(assetPath)
        .then((sprite) {
          effectComponent.sprite = sprite;
        })
        .catchError((e) {
          print("Failed to load skill effect: $assetPath");
        });
  }
}
