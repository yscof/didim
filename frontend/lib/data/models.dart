/// 데이터 계약의 기준은 shared/ 폴더다.
/// - 챌린지: shared/challenges/mvp-core-challenges.yaml
/// - 지도: shared/gamification/journey-map.yaml
/// - 배지: shared/gamification/badges.yaml
library;

/// 챌린지 유형. A 즉시완료 / B 실행 / C 습관.
enum ChallengeType {
  instant('즉시완료'),
  action('실행'),
  habit('습관');

  const ChallengeType(this.label);
  final String label;
}

/// 확보효과 라벨. realized만 '지킨 돈' 실적에 합산한다.
enum GainLabel {
  discovery('발견'),
  estimated('추정'),
  annualized('연 환산'),
  realized('실발생');

  const GainLabel(this.label);
  final String label;
}

/// 챌린지 탐색용 카테고리. 지도 지역(MapRegion)과 별개의 브라우징 축이다.
/// shared/challenges/challenge-library-v1.yaml의 category 분류를 사용자용
/// 라벨로 묶은 것. 한 챌린지가 여러 카테고리에 속할 수 있다
/// (예: 청약통장 = 정책 혜택 + 연말정산 소득공제).
enum ChallengeCategory {
  spending('소비 절약'),
  saving('저축·비상금'),
  benefit('정책 혜택'),
  yearEndTax('연말정산');

  const ChallengeCategory(this.label);
  final String label;
}

/// 완료 상태 3분류 + 미시작.
enum ChallengeStatus {
  none('시작 전'),
  planned('계획 완료'),
  executed('실행 완료'),
  held('보류');

  const ChallengeStatus(this.label);
  final String label;
}

/// 챌린지 1개의 완료 기록. 상태 + 실행 완료 게이트에서 수집한 회고·증빙 여부.
/// 증빙 이미지 자체는 저장하지 않는다 (개인정보 원칙: 첨부 여부만 기록).
class ChallengeCompletion {
  const ChallengeCompletion({
    required this.status,
    this.reflection,
    this.hasEvidence = false,
    this.impactWon = 0,
  });

  final ChallengeStatus status;

  /// 실행 완료 게이트에서 입력한 회고. 계획 완료·보류는 null.
  final String? reflection;

  /// 인증샷 첨부 여부. 보너스 배지 조건에만 쓰이고 금액에는 영향 없다.
  final bool hasEvidence;

  /// 실행 완료 시 실측 입력으로 계산·확정된 확보효과(원).
  /// 지킨 돈/예약된 돈 카운터의 유일한 금액 출처다.
  final int impactWon;
}

/// 확보효과 실측 입력 사양. 완료 확인 시트에서 실제 수치를 입력받아
/// `입력값 × multiplier`로 확보효과를 계산한다. 고정 예시 금액 대신
/// 실측을 요구해 자가검증의 거짓 비용을 높인다.
/// 산식 출처: shared/challenges/mvp-core-challenges.yaml impactCalculation.
class ImpactInputSpec {
  const ImpactInputSpec({
    required this.label,
    required this.multiplier,
    required this.formulaNote,
  });

  /// 입력 필드 라벨. 예: '해지한 구독의 월 요금 합계'
  final String label;

  /// 입력값에 곱할 계수. 예: 연 환산 = 12
  final double multiplier;

  /// 계산 근거 문구. 예: '월 요금 × 12개월'
  final String formulaNote;

  /// 입력값으로 확보효과(원)를 계산한다.
  int calc(int input) => (input * multiplier).round();
}

class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    required this.estimatedMinutes,
    required this.coachHook,
    required this.whyContent,
    required this.steps,
    required this.completionCheckQuestions,
    required this.reflectionQuestions,
    required this.gainLabel,
    required this.impactPreview,
    this.impactInput,
    required this.categories,
    required this.regionId,
    required this.mapEffect,
    required this.progressWeight,
    this.nextChallengeId,
  });

  final String id;
  final String title;
  final String? subtitle;
  final ChallengeType type;
  final int estimatedMinutes;
  final String coachHook;
  final String whyContent;
  final List<String> steps;

  /// 완료 확인 시트의 자가체크 질문. 전부 긍정해야 실행 완료로 인정한다.
  /// 출처: shared/challenges/mvp-core-challenges.yaml completionCheckQuestions.
  final List<String> completionCheckQuestions;

  /// 회고 질문. MVP 게이트는 첫 번째 질문 1개만 사용한다.
  final List<String> reflectionQuestions;

  final GainLabel gainLabel;

  /// 미완료 상태에서 보여줄 금융 효과 미리보기 문구.
  /// 실제 금액은 완료 시 [impactInput] 실측 입력으로 계산한다.
  final String impactPreview;

  /// 확보효과 실측 입력 사양. null이면 발견·목표설정형(금액 없음).
  final ImpactInputSpec? impactInput;

  final List<ChallengeCategory> categories;
  final String regionId;
  final String mapEffect;
  final int progressWeight;
  final String? nextChallengeId;
}

/// 주간 스트릭 한 주의 상태. heldKept = 성실한 보류(사유 기록 + 재시도
/// 예약)로 리듬을 유지한 주 (docs/16-gamification.md 6장).
enum WeeklyStreakStatus {
  completed('완료'),
  heldKept('성실한 보류'),
  missed('쉼');

  const WeeklyStreakStatus(this.label);
  final String label;
}

class WeeklyStreakEntry {
  const WeeklyStreakEntry({required this.weekLabel, required this.status});

  final String weekLabel;
  final WeeklyStreakStatus status;
}

class MapRegion {
  const MapRegion({
    required this.id,
    required this.name,
    required this.theme,
    required this.completionMessage,
  });

  final String id;
  final String name;
  final String theme;
  final String completionMessage;
}

class DidimBadge {
  const DidimBadge({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

/// 12,345 → "12,345원"
String won(int amount) {
  final digits = amount.abs().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
  return '${amount < 0 ? '-' : ''}$digits원';
}
