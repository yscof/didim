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
    required this.gainLabel,
    required this.impactPreview,
    this.impactAmountWon = 0,
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
  final GainLabel gainLabel;

  /// 완료 리액션 2단계에 보여줄 금융 효과 문구.
  /// TODO: 실제로는 사용자 입력 기반 산식으로 계산한다 (impactCalculation).
  final String impactPreview;

  /// 카운터에 반영할 금액. 실행 완료 시에만 반영한다.
  final int impactAmountWon;

  final List<ChallengeCategory> categories;
  final String regionId;
  final String mapEffect;
  final int progressWeight;
  final String? nextChallengeId;
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
