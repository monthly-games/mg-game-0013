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

### 🎮 기본 프로토타입 구현 완료!

현재 다음 기능이 구현되어 있습니다:

1. **기본 UI 구조** (main.dart)
   - Lobby 화면 (팀 편성, 용병 상점)
   - Battle 화면 전환

2. **용병 시스템 기초**
   - hero_data.dart 구현
   - 용병 모집 및 팀 구성

3. **리그 관리** (league_manager.dart)
   - 골드 시스템
   - 리그 포인트
   - 전투 시작/종료

4. **Flame 게임 엔진** (arena_game.dart)
   - 오토배틀 기본 구조
   - Unit, Projectile, Particle 컴포넌트

**현재 진행도**: ~20% (프로토타입 단계)

---

## 완료된 작업

### ✅ 1. 프로젝트 초기 설정 (100%)
- Flutter 프로젝트 생성
- mg-common-game 서브모듈 연결
- 기본 의존성 설정 (Flame, Provider, GetIt)
- 테마 시스템 (AppColors, AppTextStyles)

### ✅ 2. 기본 데이터 모델 (60%)
#### 구현 완료:
- [hero_data.dart](d:\mg-games\repos\mg-game-0013\game\lib\features\hero\hero_data.dart)
  - Hero 클래스 (이름, 직업, 스탯)
  - Job enum (Warrior, Archer, Mage, Healer, Tank)
  - 기본 스탯 시스템

#### 남은 작업:
- 스킬 시스템 데이터 모델
- 장비 시스템 데이터 모델
- 레벨/성장 시스템

### ✅ 3. 상태 관리 (40%)
#### 구현 완료:
- [league_manager.dart](d:\mg-games\repos\mg-game-0013\game\lib\features\league\league_manager.dart)
  - 골드 관리
  - 리그 포인트 관리
  - 팀 구성 (myTeam, enemyTeam)
  - 용병 상점 (shopList, recruit, refreshShop)
  - 전투 상태 관리 (startBattle, endBattle)

#### 남은 작업:
- 리그 티어 시스템 (Bronze → Legend)
- 시즌 관리
- 매치메이킹 로직
- 로컬 저장 (Hive)

### ✅ 4. 오토배틀 시스템 (30%)
#### 구현 완료:
- [arena_game.dart](d:\mg-games\repos\mg-game-0013\game\lib\game\arena_game.dart)
  - Flame Game 기본 구조
  - 아군/적군 배치
  - 승리/패배 콜백

- [unit_component.dart](d:\mg-games\repos\mg-game-0013\game\lib\game\components\unit_component.dart)
  - 유닛 기본 컴포넌트
  - HP, 공격력 등 스탯
  - 기본 애니메이션

- [arena_projectile.dart](d:\mg-games\repos\mg-game-0013\game\lib\game\components\arena_projectile.dart)
  - 투사체 컴포넌트

- [damage_text.dart](d:\mg-games\repos\mg-game-0013\game\lib\game\components\damage_text.dart)
  - 데미지 표시 텍스트

- [simple_particle.dart](d:\mg-games\repos\mg-game-0013\game\lib\game\components\simple_particle.dart)
  - 파티클 이펙트

#### 남은 작업:
- 전투 AI 로직 (타겟 선택, 스킬 사용)
- 스킬 시스템 구현
- 전투 애니메이션 개선
- 승리/패배 조건 구현

### ✅ 5. UI 시스템 (30%)
#### 구현 완료:
- Lobby 화면
  - 헤더 (리그 정보, 골드)
  - My Team 표시
  - 용병 상점
  - 전투 시작 버튼
- Battle 화면 전환

#### 남은 작업:
- 용병 상세 정보 화면
- 리그 랭킹 화면
- 시즌 패스 화면
- 설정 화면
- 전투 결과 화면

---

## 진행 중인 작업

현재 작업 없음 - 다음 단계 대기 중

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
