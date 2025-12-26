
import os
import shutil

# Config
BASE_DIR = 'game/assets'
IMG_DIR = os.path.join(BASE_DIR, 'images')
AUDIO_DIR = os.path.join(BASE_DIR, 'audio')

# 1. Heroes (30 files)
# Map: Base existing -> Targets
HERO_MAP = {
    'hero_warrior.png': ['warrior'],
    'hero_archer.png': ['archer'],
    'hero_mage.png': ['mage'],
    'hero_tank.png': ['tank'],
    'hero_assassin.png': ['assassin'],
    'hero_healer.png': ['healer']
}
RARITIES = ['common', 'uncommon', 'rare', 'epic', 'legendary']

def copy_hero_assets():
    src_dir = os.path.join(IMG_DIR, 'heroes')
    for base_file, jobs in HERO_MAP.items():
        src = os.path.join(src_dir, base_file)
        if not os.path.exists(src):
            print(f"Missing base: {src}")
            continue
            
        for job in jobs:
            for rarity in RARITIES:
                dst_name = f"{job}_{rarity}.png"
                dst = os.path.join(src_dir, dst_name)
                if not os.path.exists(dst):
                    shutil.copy(src, dst)
                    print(f"Created {dst_name}")

# 2. Skills (18 files)
# Map: Base existing -> Targets
SKILL_MAP = {
    'skill_slash.png': ['slash_effect.png', 'charge_effect.png', 'whirlwind_effect.png'],
    'skill_fireball.png': ['fireball_effect.png', 'precise_shot_effect.png', 'multishot_effect.png', 'poison_arrow_effect.png', 'arcane_blast_effect.png', 'frostbolt_effect.png'],
    'skill_shield_bash.png': ['shield_bash_effect.png', 'taunt_effect.png', 'iron_wall_effect.png', 'backstab_effect.png', 'shadow_step_effect.png', 'critical_strike_effect.png'],
    'skill_heal.png': ['heal_effect.png', 'bless_effect.png', 'resurrection_effect.png']
}

def copy_skill_assets():
    src_dir = os.path.join(IMG_DIR, 'skills')
    for base, targets in SKILL_MAP.items():
        src = os.path.join(src_dir, base)
        if not os.path.exists(src):
            print(f"Missing base: {src}")
            continue
        for t in targets:
            dst = os.path.join(src_dir, t)
            if not os.path.exists(dst):
                shutil.copy(src, dst)
                print(f"Created {t}")

# 3. Audio Placeholders
# Map: Base existing -> Targets
AUDIO_MAP = {
    'music/bgm_battle.mp3': ['music/lobby_theme.mp3', 'music/victory_theme.mp3'],
    'sfx/attack.wav': ['sfx/victory.wav', 'sfx/defeat.wav', 'sfx/coin.wav', 'sfx/button.wav', 'sfx/levelup.wav']
}

def copy_audio_assets():
    for base, targets in AUDIO_MAP.items():
        src = os.path.join(AUDIO_DIR, base)
        if not os.path.exists(src):
            print(f"Missing base: {src}")
            continue
        for t in targets:
            dst = os.path.join(AUDIO_DIR, t)
            if not os.path.exists(dst):
                shutil.copy(src, dst)
                print(f"Created {t}")

if __name__ == "__main__":
    copy_hero_assets()
    copy_skill_assets()
    copy_audio_assets()
