
import os
import shutil

BASE_DIR = 'game/assets/images'
BG_DIR = os.path.join(BASE_DIR, 'backgrounds')
UI_DIR = os.path.join(BASE_DIR, 'ui')
SKILL_DIR = os.path.join(BASE_DIR, 'skills')

# Source Files
LOBBY_BG = os.path.join(BG_DIR, 'lobby_bg.png')
SHOP_BG_TARGET = os.path.join(BG_DIR, 'shop_bg.png')
ARENA_BASE = os.path.join(BASE_DIR, 'bg_arena.png') # Root images/bg_arena.png
TIER_BASE = os.path.join(SKILL_DIR, 'skill_shield_bash.png')

# Targets
ARENAS = [
    'arena_bronze.png', 'arena_silver.png', 'arena_gold.png', 
    'arena_platinum.png', 'arena_diamond.png', 'arena_master.png', 'arena_legend.png'
]
TIERS = [
    'tier_bronze.png', 'tier_silver.png', 'tier_gold.png', 
    'tier_platinum.png', 'tier_diamond.png', 'tier_master.png', 'tier_legend.png'
]

def distribute_backgrounds():
    # Shop uses Lobby as placeholder
    if os.path.exists(LOBBY_BG) and not os.path.exists(SHOP_BG_TARGET):
        shutil.copy(LOBBY_BG, SHOP_BG_TARGET)
        print("Created shop_bg.png")

    # Arenas use bg_arena.png
    if os.path.exists(ARENA_BASE):
        for arena in ARENAS:
            dst = os.path.join(BG_DIR, arena)
            if not os.path.exists(dst):
                shutil.copy(ARENA_BASE, dst)
                print(f"Created {arena}")
    else:
        print(f"Warning: Base arena {ARENA_BASE} not found")

def distribute_tiers():
    # Tiers use Shield Bash skill as placeholder
    if os.path.exists(TIER_BASE):
        for tier in TIERS:
            dst = os.path.join(UI_DIR, tier)
            if not os.path.exists(dst):
                shutil.copy(TIER_BASE, dst)
                print(f"Created {tier}")
    else:
        print(f"Warning: Base tier {TIER_BASE} not found")

if __name__ == "__main__":
    distribute_backgrounds()
    distribute_tiers()
