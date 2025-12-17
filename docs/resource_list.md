# MG-0013 아레나 레전드 - 리소스 생성 목록

## 🎨 그래픽 리소스

### 1. 용병 아이콘/아바타
**개수**: 30개 (6개 직업 × 5개 레어리티)
**크기**: 512x512px
**포맷**: PNG (투명 배경)
**스타일**: 픽셀 아트 또는 판타지 일러스트

**직업 목록**:
1. Warrior (전사)
2. Archer (궁수)
3. Mage (마법사)
4. Tank (탱커)
5. Assassin (암살자)
6. Healer (힐러)

**레어리티 목록**:
1. Common (일반) - 회색 테두리
2. Uncommon (고급) - 초록색 테두리
3. Rare (희귀) - 파란색 테두리
4. Epic (영웅) - 보라색 테두리
5. Legendary (전설) - 황금색 테두리

#### AI 프롬프트 예시 (Stable Diffusion / Midjourney)
```
# 기본 템플릿
"pixel art character portrait, [JOB_NAME] mercenary, [RARITY_ADJECTIVE] quality, fantasy RPG style, square icon, clean background, vibrant colors, detailed armor and weapons, front-facing, mobile game asset, 512x512"

# 구체적 예시
- Warrior (Common): "pixel art character portrait, warrior mercenary, common quality, fantasy RPG style, square icon, clean background, basic iron armor, sword and shield, front-facing, mobile game asset"
- Archer (Legendary): "pixel art character portrait, archer mercenary, legendary quality, fantasy RPG style, square icon, clean background, golden ornate bow, mystical arrows, glowing effects, front-facing, mobile game asset"
- Mage (Epic): "pixel art character portrait, mage mercenary, epic quality, fantasy RPG style, square icon, clean background, purple robes, magical staff with crystals, arcane symbols, front-facing, mobile game asset"
```

---

### 2. 스킬 이펙트 스프라이트
**개수**: 18개 스킬
**크기**: 256x256px (4-8 프레임 애니메이션)
**포맷**: PNG 스프라이트 시트
**FPS**: 12-24fps

**스킬 목록**:
#### Warrior (전사)
1. Slash - 빠른 베기
2. Charge - 돌진 공격
3. Whirlwind - 회전베기 (AOE)

#### Archer (궁수)
4. Precise Shot - 정확한 사격
5. Multishot - 다중 화살
6. Poison Arrow - 독 화살 (디버프)

#### Mage (마법사)
7. Fireball - 화염구 (불 이펙트)
8. Frostbolt - 냉기 화살 (얼음 이펙트)
9. Arcane Blast - 비전 폭발 (마법진)

#### Tank (탱커)
10. Shield Bash - 방패 강타
11. Taunt - 도발 (버프)
12. Iron Wall - 철벽 방어 (방어 버프)

#### Assassin (암살자)
13. Backstab - 뒤치기
14. Shadow Step - 그림자 이동
15. Critical Strike - 치명타

#### Healer (힐러)
16. Heal - 치유 (녹색 빛)
17. Bless - 축복 (버프)
18. Resurrection - 부활 (광휘)

#### AI 프롬프트 예시
```
# 기본 템플릿
"2D game effect sprite sheet, [SKILL_NAME] magical effect, 4-8 animation frames, transparent background, [COLOR] energy particles, fantasy style, mobile game VFX asset"

# 구체적 예시
- Fireball: "2D game effect sprite sheet, fireball spell effect, 6 animation frames, transparent background, red orange flame particles, explosion on impact, fantasy style, mobile game VFX asset"
- Heal: "2D game effect sprite sheet, healing light effect, 4 animation frames, transparent background, green white holy particles, divine glow, sparkles, fantasy style, mobile game VFX asset"
- Shadow Step: "2D game effect sprite sheet, shadow teleport effect, 6 animation frames, transparent background, purple black smoke particles, mysterious void, fantasy style, mobile game VFX asset"
```

---

### 3. UI 배경 이미지
**개수**: 9개
**크기**: 1920x1080px (16:9)
**포맷**: JPG/PNG
**스타일**: 판타지 아레나

**배경 목록**:
1. **로비 배경** - 용병 길드 홀
2. **상점 배경** - 시장터
3. **전투 아레나 배경** - 7개 (각 리그 티어별)
   - Bronze Arena - 훈련장
   - Silver Arena - 돌 콜로세움
   - Gold Arena - 황금 경기장
   - Platinum Arena - 수정 궁전
   - Diamond Arena - 얼음 성채
   - Master Arena - 화산 경기장
   - Legend Arena - 하늘의 전장

#### AI 프롬프트 예시
```
# 로비
"fantasy medieval guild hall interior, wooden tables and benches, weapon racks on walls, fireplace, warm lighting, tavern atmosphere, game background art, 1920x1080"

# Bronze Arena
"simple stone training arena, wooden dummies, dirt floor, medieval fantasy, outdoor colosseum, daytime, game background art"

# Legend Arena
"legendary floating sky arena, clouds below, divine architecture, golden pillars, epic fantasy, dramatic lighting, game background art"
```

---

### 4. 리그 티어 엠블럼
**개수**: 7개
**크기**: 256x256px
**포맷**: PNG (투명 배경)
**스타일**: 문장/배지 스타일

**티어 목록**:
1. Bronze (브론즈) - 갈색 청동 방패
2. Silver (실버) - 은색 검
3. Gold (골드) - 황금 왕관
4. Platinum (플래티넘) - 백금 별
5. Diamond (다이아몬드) - 다이아몬드 크리스탈
6. Master (마스터) - 보라색 마법 룬
7. Legend (레전드) - 불타는 용의 날개

#### AI 프롬프트 예시
```
"fantasy game rank emblem, [TIER_NAME] tier badge, [MATERIAL] shield with ornate border, medieval heraldry style, glowing effect, game UI icon, 256x256, transparent background"

# 예시
- Bronze: "fantasy game rank emblem, bronze tier badge, copper shield with simple border, medieval heraldry style, game UI icon"
- Legend: "fantasy game rank emblem, legend tier badge, dragon wings with fire effect, epic glowing border, medieval heraldry style, game UI icon"
```

---

## 🔊 사운드 리소스

### 효과음 (SFX)
**포맷**: WAV (44.1kHz, 16-bit)
**길이**: 0.1-2초

**목록** (10개):
1. `attack.wav` - 근접 공격 (칼 휘두르는 소리)
2. `shoot.wav` - 원거리 공격 (화살/마법 발사)
3. `skill.wav` - 스킬 사용 (마법 효과음)
4. `hit.wav` - 피격 (타격음)
5. `crit.wav` - 크리티컬 피격 (강렬한 타격)
6. `victory.wav` - 승리 (팡파레)
7. `defeat.wav` - 패배 (낮은 음)
8. `coin.wav` - 골드 획득 (동전 소리)
9. `button.wav` - 버튼 클릭 (UI 클릭)
10. `levelup.wav` - 승급 (레벨업/성취)

### 배경 음악 (BGM)
**포맷**: MP3 (192kbps)
**길이**: 2-3분 (루프 가능)

**목록** (3개):
1. `lobby_theme.mp3` - 로비 테마 (평화로운 판타지)
2. `battle_theme.mp3` - 전투 테마 (긴장감 있는 오케스트라)
3. `victory_theme.mp3` - 승리 테마 (영웅적인 팡파레)

#### 음악 스타일 가이드
- **Lobby**: 중세 판타지 선술집 분위기 (Lute, Flute)
- **Battle**: Epic orchestral battle music (Drums, Brass, Strings)
- **Victory**: Triumphant fanfare (Horns, Drums)

---

## 📝 텍스트 리소스

### 용병 이름 생성 규칙
**패턴**: [직업명] + [레어리티 수식어]

**예시**:
- Common Warrior / Uncommon Blade / Rare Berserker / Epic Champion / Legendary Warlord
- Common Cleric / Uncommon Priest / Rare Monk / Epic Bishop / Legendary Saint

### 스킬 설명 텍스트
각 스킬별 간단한 설명 (20-30자)
- "Deal 150% damage to single enemy"
- "Heal ally for 30% of max HP"
- "Increase all allies' ATK by 20% for 5s"

---

## 🎯 우선순위 정리

### High Priority (즉시 필요)
1. ✅ 기본 UI 아이콘 (Material Icons 사용 중)
2. ⬜ 효과음 3개: attack.wav, hit.wav, button.wav
3. ⬜ 로비 배경 1개

### Medium Priority (베타 전 필요)
1. ⬜ 용병 아이콘 30개
2. ⬜ 리그 티어 엠블럼 7개
3. ⬜ 스킬 이펙트 18개
4. ⬜ 효과음 전체 10개
5. ⬜ BGM 1개 (lobby_theme)

### Low Priority (정식 출시 전)
1. ⬜ 아레나 배경 7개
2. ⬜ BGM 전체 3개
3. ⬜ 스킬 이펙트 애니메이션 강화

---

## 📂 파일 구조

```
game/assets/
├── audio/
│   ├── music/
│   │   ├── lobby_theme.mp3
│   │   ├── battle_theme.mp3
│   │   └── victory_theme.mp3
│   └── sfx/
│       ├── attack.wav
│       ├── shoot.wav
│       ├── skill.wav
│       ├── hit.wav
│       ├── crit.wav
│       ├── victory.wav
│       ├── defeat.wav
│       ├── coin.wav
│       ├── button.wav
│       └── levelup.wav
└── images/
    ├── heroes/
    │   ├── warrior_common.png
    │   ├── warrior_uncommon.png
    │   ├── ... (30 files)
    │   └── healer_legendary.png
    ├── skills/
    │   ├── slash_effect.png
    │   ├── fireball_effect.png
    │   ├── ... (18 files)
    │   └── resurrection_effect.png
    ├── backgrounds/
    │   ├── lobby_bg.jpg
    │   ├── shop_bg.jpg
    │   ├── arena_bronze.jpg
    │   ├── ... (7 arena files)
    │   └── arena_legend.jpg
    └── ui/
        ├── tier_bronze.png
        ├── tier_silver.png
        ├── ... (7 files)
        └── tier_legend.png
```

---

## 🤖 AI 도구 추천

### 이미지 생성
1. **Stable Diffusion** (무료, 로컬)
   - 모델: DreamShaper, Realistic Vision
   - 용병 아이콘, 티어 엠블럼

2. **Midjourney** (유료, $10/월)
   - 고퀄리티 판타지 아트
   - 배경 이미지

3. **Pixe lfx AI** (무료)
   - 픽셀 아트 생성
   - 용병 아이콘 (픽셀 스타일)

### 사운드 생성
1. **Suno AI** (무료)
   - BGM 생성
   - 판타지 음악

2. **ElevenLabs** (무료 티어)
   - 효과음 생성

3. **Freesound.org** (무료)
   - 무료 SFX 라이브러리

---

## 📊 예상 작업량

| 리소스 타입 | 개수 | 예상 시간 |
|------------|------|-----------|
| 용병 아이콘 | 30개 | 3-5시간 |
| 스킬 이펙트 | 18개 | 4-6시간 |
| 배경 이미지 | 9개 | 2-3시간 |
| 티어 엠블럼 | 7개 | 1-2시간 |
| 효과음 | 10개 | 1-2시간 |
| BGM | 3개 | 2-3시간 |
| **합계** | **77개** | **13-21시간** |

**AI 도구 사용 시**: 총 작업 시간의 50-70% 단축 가능 (7-12시간)

---

## ✅ 체크리스트

### 이미지
- [ ] 용병 아이콘 30개
- [ ] 스킬 이펙트 18개
- [ ] 배경 이미지 9개
- [ ] 티어 엠블럼 7개

### 사운드
- [ ] 효과음 10개
- [ ] BGM 3개

### 통합
- [ ] assets 폴더 구조 생성
- [ ] pubspec.yaml에 asset 경로 추가
- [ ] 리소스 로딩 테스트
- [ ] 메모리 최적화 확인

---

**작성일**: 2025-12-17
**버전**: 1.0
