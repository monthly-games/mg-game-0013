# MG-0013 아레나 레전드: 용병 리그 - 개발 진행 상황

## 프로젝트 개요
- **게임명**: 아레나 레전드: 용병 리그 (Arena Legends: Mercenary League)
- **장르**: 오토배틀 + 리그 시스템 + 라이트 PVP
- **플랫폼**: Mobile (iOS/Android)
- **엔진**: Flutter + Flame
- **상태 관리**: Provider + GetIt
- **백엔드**: Firebase + Cloud Functions

---

## 최신 업데이트 (2025-12-17)

### 🎮 핵심 시스템 구현 완료!

대규모 개발 진행: 7개 주요 커밋으로 핵심 시스템 완성

1. **완전한 데이터 모델 시스템** ✅
   - hero_data.dart: 5단계 레어리티, 6개 직업, 확장된 스탯 시스템
   - skill_data.dart: 18개 사전 정의 스킬, 5가지 스킬 타입
   - equipment_data.dart: 5개 장비 슬롯, 스탯 보너스 시스템
   - league_data.dart: 7개 리그 티어, 시즌 시스템

2. **강화된 상태 관리** ✅
   - 3가지 화폐 시스템 (Gold, Crystal, Battle Tickets)
   - 승급/강등 메커니즘
   - 전적 추적 (승/패, 승률)
   - 매치 히스토리

3. **완전한 오토배틀 시스템** ✅
   - 스킬 쿨다운 시스템
   - 크리티컬 히트 (critRate, critDamage)
   - 방어력 시스템
   - 버프/디버프 시스템
   - 5가지 스킬 타입 실행 로직

4. **개선된 UI** ✅
   - 레어리티 색상 코딩
   - 직업별 아이콘
   - 상세 스탯 표시
   - 3가지 화폐 표시

**현재 진행도**: ~60% (코어 루프 단계)

---

## 완료된 작업

### ✅ 1. 프로젝트 초기 설정 (100%)
- Flutter 프로젝트 생성
- mg-common-game 서브모듈 연결
- 기본 의존성 설정 (Flame, Provider, GetIt)
- 테마 시스템 (AppColors, AppTextStyles)

### ✅ 2. 핵심 데이터 모델 (100%)
#### 구현 완료:
- [hero_data.dart](game/lib/features/hero/hero_data.dart)
  - 5단계 레어리티 시스템 (Common → Legendary)
  - 6개 직업 (Warrior, Archer, Mage, Tank, Assassin, Healer)
  - 확장 스탯: HP, ATK, DEF, critRate, critDamage, range, speed
  - 레벨/경험치 시스템
  - SkillData 통합
  - 가중치 랜덤 생성 (60% Common, 1% Legendary)
  - 레어리티별 스탯 배율 (1.0x ~ 2.2x)

- [skill_data.dart](game/lib/features/skill/skill_data.dart)
  - 5가지 SkillType (damage, heal, buff, debuff, aoe)
  - 5가지 SkillTarget (enemy, ally, self, allEnemies, allAllies)
  - 18개 사전 정의 스킬 (직업당 3개)
  - 쿨다운, 마나 코스트, 지속시간, AOE 반경

- [equipment_data.dart](game/lib/features/equipment/equipment_data.dart)
  - 5개 장비 슬롯 (weapon, armor, helmet, boots, accessory)
  - 5단계 레어리티 (가중치 랜덤)
  - 6가지 StatType (HP, ATK, DEF, critRate, critDamage, speed)
  - 퍼센트 및 고정 보너스
  - 직업 전용 장비
  - 세트 아이템 기반

- [league_data.dart](game/lib/features/league/league_data.dart)
  - 7개 리그 티어 (Bronze → Legend)
  - 티어별 승급/강등 포인트
  - 동적 포인트 계산 (상대 티어 기반)
  - 일일/시즌 보상
  - 시즌 시스템 (30일 주기)
  - 매치 히스토리 데이터

### ✅ 3. 상태 관리 (90%)
#### 구현 완료:
- [league_manager.dart](game/lib/features/league/league_manager.dart)
  - 3가지 화폐 시스템 (Gold, Crystal, Battle Tickets)
  - 완전한 리그 티어 시스템 (7개 티어)
  - 자동 승급/강등 메커니즘
  - 팀 구성 (myTeam, enemyTeam)
  - 용병 인벤토리 (최대 30개)
  - 장비 인벤토리
  - 용병 상점 (티어 기반 3-5개 상점)
  - 상점 리롤 시스템 (10 Gold)
  - 전투 상태 관리 (startBattle, endBattle)
  - 전적 추적 (승/패/승률)
  - 매치 히스토리
  - 시즌 시스템 (30일 주기, 초기화, 보상)
  - 일일 보상 (클레임 기능)

#### 남은 작업:
- 로컬 저장 (Hive/SharedPreferences)
- 실시간 매치메이킹 (Firebase)

### ✅ 4. 오토배틀 시스템 (85%)
#### 구현 완료:
- [arena_game.dart](game/lib/game/arena_game.dart)
  - Flame Game 기본 구조
  - 아군/적군 자동 배치
  - 승리/패배 감지 및 콜백

- [unit_component.dart](game/lib/game/components/unit_component.dart)
  - 5가지 유닛 상태 (idle, moving, attacking, casting, dead)
  - 완전한 스킬 시스템 (cooldown 기반)
  - 5가지 스킬 타입 실행 (_executeDamageSkill, _executeHealSkill 등)
  - 크리티컬 히트 시스템 (critRate, critDamage)
  - 방어력 시스템 (데미지 감소)
  - 버프/디버프 추적 및 자동 만료
  - 공격 속도 계산 (speed 스탯 기반)
  - 타겟 선택 AI (최근접 적)
  - 스킬 쿨다운 시각화 (오렌지/노란색 바)
  - 직업별 비주얼 (Warrior: 사각형, Archer: 삼각형, Mage: 다이아몬드 등)

- [arena_projectile.dart](game/lib/game/components/arena_projectile.dart)
  - 유도 투사체
  - 타겟 추적
  - 크리티컬 색상 표시

- [damage_text.dart](game/lib/game/components/damage_text.dart)
  - 데미지 표시 (크리티컬: 노란색, 큰 폰트)
  - 힐 텍스트 (초록색)
  - 스킬 이름 표시

- [simple_particle.dart](game/lib/game/components/simple_particle.dart)
  - 사망 파티클
  - 힐 파티클

#### 남은 작업:
- 더 정교한 타겟 선택 AI (우선순위 시스템)
- 전투 애니메이션 개선
- 스킬 이펙트 강화

### ✅ 5. UI 시스템 (65%)
#### 구현 완료:
- [main.dart](game/lib/main.dart)
  - Lobby 화면
    - 헤더 (리그 티어 한글명, 승률, 전적)
    - 3가지 화폐 표시 (Gold 💰, Crystal 💎, Tickets 🎫)
    - My Team 표시 (레어리티 색상, 직업 아이콘, 별 표시)
    - 용병 상점 (카드 기반 레이아웃)
      - 레어리티 색상 및 별 표시
      - 직업 아이콘
      - 상세 스탯 (HP, ATK, DEF, SPD)
      - 스킬 이름 표시
    - 상점 리롤 버튼 (10 💰, 잔액 확인)
    - 전투 시작 버튼 (티켓 확인)
  - Battle 화면
    - Flame GameWidget 통합
    - 전투 진행 오버레이

#### 남은 작업:
- 용병 상세 정보 화면
- 인벤토리 화면
- 장비 관리 화면
- 리그 랭킹 화면
- 시즌 패스 화면
- 전투 결과 화면

---

## 진행 중인 작업

현재 세션에서 완료된 작업 (2025-12-17):
- ✅ 4개 핵심 데이터 모델 구현 (hero, skill, equipment, league)
- ✅ LeagueManager 대폭 강화 (3가지 화폐, 7개 티어, 시즌 시스템)
- ✅ UnitComponent 완전 재작성 (스킬, 크리티컬, 방어, 버프/디버프)
- ✅ Flame 게임 컴포넌트 추가 (projectile, damage_text, particle)
- ✅ main.dart UI 대폭 개선 (레어리티 시스템, 상세 스탯)
- ✅ 개발 진행 문서 업데이트

**7개 주요 커밋 완료**
**진행도: 20% → 60%** (코어 루프 거의 완성)

---

## 다음 작업 계획

### 우선순위 1: 핵심 게임플레이 완성
1. **오토배틀 AI 구현**
   - 타겟 선택 로직
   - 공격 실행
   - 승리/패배 판정

2. **스킬 시스템 기초**
   - Skill 데이터 모델
   - 스킬 사용 로직
   - 3개 기본 스킬 구현

3. **리그 시스템 확장**
   - 7개 티어 구현 (Bronze → Legend)
   - 티어별 승급/강등
   - 리그 보상

### 우선순위 2: 성장 시스템
1. **용병 강화**
   - 레벨업 시스템
   - 스탯 성장

2. **장비 시스템**
   - 장비 데이터 모델
   - 장비 착용/해제
   - 장비 효과

### 우선순위 3: 라이브 서비스 기능
1. **시즌 시스템**
   - 시즌 기간 관리
   - 시즌 보상
   - 시즌 초기화

2. **상점 확장**
   - 크리스탈 시스템
   - 가챠 시스템
   - 시즌 패스

---

## 기술 스택

### 프론트엔드
- **Flutter 3.27+**
- **Flame 1.20+** - 게임 엔진
- **Provider** - 상태 관리
- **GetIt** - 의존성 주입
- **mg-common-game** - 공통 게임 모듈

### 백엔드
- **Firebase** - 인증, 데이터베이스
- **Cloud Functions** - 서버 로직
- **mg-common-backend** - 공통 백엔드 모듈

### 분석
- **Firebase Analytics**
- **Google Analytics 4**
- **BigQuery**

---

## 폴더 구조

```
mg-game-0013/game/lib/
├── features/
│   ├── hero/
│   │   └── hero_data.dart          ✅ 용병 데이터 모델
│   └── league/
│       └── league_manager.dart     ✅ 리그 관리
├── game/
│   ├── arena_game.dart             ✅ 메인 게임 클래스
│   └── components/
│       ├── unit_component.dart     ✅ 유닛 컴포넌트
│       ├── arena_projectile.dart   ✅ 투사체
│       ├── damage_text.dart        ✅ 데미지 텍스트
│       └── simple_particle.dart    ✅ 파티클
├── theme/
│   └── (AppColors, AppTextStyles from mg-common-game)
└── main.dart                        ✅ 앱 진입점
```

---

## 마일스톤

### M1: 프로토타입 (현재)
- [x] 기본 UI 구조
- [x] 용병 모집/팀 구성
- [x] 기본 오토배틀
- [ ] 전투 AI 완성
- [ ] 승리/패배 판정

**목표**: 완전히 플레이 가능한 1회 전투 루프

### M2: 코어 루프
- [ ] 리그 시스템 (7 티어)
- [ ] 용병 레벨업
- [ ] 기본 스킬 3종
- [ ] 전투 결과 화면
- [ ] 리그 보상

**목표**: 반복 가능한 성장 루프

### M3: 컨텐츠 확장
- [ ] 30종 용병
- [ ] 15종 스킬
- [ ] 장비 시스템
- [ ] 가챠 시스템

**목표**: 다양성 확보

### M4: 라이브 서비스
- [ ] 시즌 시스템
- [ ] 시즌 패스
- [ ] 일일 퀘스트
- [ ] 랭킹 시스템

**목표**: 장기 운영 준비

---

## 알려진 이슈

1. 전투 AI 미구현 - 유닛이 공격하지 않음
2. 승리/패배 조건 미정의
3. 로컬 저장 없음 - 앱 재시작 시 데이터 초기화
4. 스킬 시스템 없음
5. 장비 시스템 없음

---

## 참고 문서

- [GDD](design/gdd_game_0013.json)
- [경제 설계](design/economy.json)
- [레벨 디자인](design/level_design.json)
- [BM 설계](bm_design.md)
- [재미 설계](fun_design.md)
- [운영 설계](ops_design.md)
- [수익화 설계](monetization_design.md)
