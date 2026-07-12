import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_challenges.dart';
import 'models.dart';

final challengesProvider = Provider<List<Challenge>>((ref) => mockChallenges);
final regionsProvider = Provider<List<MapRegion>>((ref) => mockRegions);

/// 카테고리별 챌린지 목록. null이면 전체를 반환한다.
final challengesByCategoryProvider =
    Provider.family<List<Challenge>, ChallengeCategory?>((ref, category) {
  final challenges = ref.watch(challengesProvider);
  if (category == null) return challenges;
  return challenges.where((c) => c.categories.contains(category)).toList();
});

final challengeByIdProvider = Provider.family<Challenge?, String>((ref, id) {
  for (final c in ref.watch(challengesProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

/// 챌린지별 완료 기록. TODO: 백엔드 연동 시 서버 상태로 교체.
class ChallengeCompletionNotifier
    extends Notifier<Map<String, ChallengeCompletion>> {
  @override
  Map<String, ChallengeCompletion> build() => const {};

  /// 계획 완료·보류처럼 게이트 없이 상태만 기록할 때 쓴다.
  void setStatus(String challengeId, ChallengeStatus status) {
    state = {...state, challengeId: ChallengeCompletion(status: status)};
  }

  /// 실행 완료 게이트를 통과한 기록. 회고는 필수, 증빙은 선택.
  /// [impactWon]은 실측 입력으로 계산된 확보효과 (입력형 챌린지만 > 0).
  void completeExecuted(String challengeId,
      {required String reflection,
      bool hasEvidence = false,
      int impactWon = 0}) {
    state = {
      ...state,
      challengeId: ChallengeCompletion(
        status: ChallengeStatus.executed,
        reflection: reflection,
        hasEvidence: hasEvidence,
        impactWon: impactWon,
      ),
    };
  }
}

final challengeCompletionProvider = NotifierProvider<
    ChallengeCompletionNotifier,
    Map<String, ChallengeCompletion>>(ChallengeCompletionNotifier.new);

// 주의: 완료 상태를 Map으로 변환하는 파생 Provider를 두면 상태 변경 직후
// 화면 전환 시 위젯 build 중에 lazy 재계산·전파가 일어나
// "setState() called during build"로 터진다. 모든 파생 프로바이더는
// challengeCompletionProvider를 직접 watch한다.

/// 지역 진행도(%). 실행 완료 = 가중치 100%, 계획 완료 = 50% 반영.
/// 규칙 출처: shared/gamification/journey-map.yaml progressRules.
final regionProgressProvider = Provider.family<int, String>((ref, regionId) {
  final completions = ref.watch(challengeCompletionProvider);
  final challenges = ref.watch(challengesProvider);
  var percent = 0.0;
  for (final c in challenges) {
    if (c.regionId != regionId) continue;
    switch (completions[c.id]?.status) {
      case ChallengeStatus.executed:
        percent += c.progressWeight;
      case ChallengeStatus.planned:
        percent += c.progressWeight / 2;
      default:
        break;
    }
  }
  return percent.round().clamp(0, 100);
});

/// 지킨 돈: realized 확보효과만 합산한다 (실행 완료 기준).
/// 금액 출처는 완료 시 실측 입력으로 계산된 completion.impactWon이다.
final realizedWonProvider = Provider<int>((ref) {
  final completions = ref.watch(challengeCompletionProvider);
  return ref
      .watch(challengesProvider)
      .where((c) =>
          c.gainLabel == GainLabel.realized &&
          completions[c.id]?.status == ChallengeStatus.executed)
      .fold(0, (sum, c) => sum + completions[c.id]!.impactWon);
});

/// 예약된 돈: estimated·annualized 효과의 별도 트랙 (실행 완료 기준).
final reservedWonProvider = Provider<int>((ref) {
  final completions = ref.watch(challengeCompletionProvider);
  return ref
      .watch(challengesProvider)
      .where((c) =>
          (c.gainLabel == GainLabel.estimated ||
              c.gainLabel == GainLabel.annualized) &&
          completions[c.id]?.status == ChallengeStatus.executed)
      .fold(0, (sum, c) => sum + completions[c.id]!.impactWon);
});

/// 획득한 배지. 규칙 출처: shared/gamification/badges.yaml.
final earnedBadgesProvider = Provider<List<DidimBadge>>((ref) {
  final completions = ref.watch(challengeCompletionProvider);
  ChallengeStatus status(String id) =>
      completions[id]?.status ?? ChallengeStatus.none;
  bool done(String id) =>
      status(id) == ChallengeStatus.planned ||
      status(id) == ChallengeStatus.executed;

  final earned = <DidimBadge>[];
  if (completions.values.any((c) =>
      c.status == ChallengeStatus.planned ||
      c.status == ChallengeStatus.executed)) {
    earned.add(mockBadges[0]); // 첫 금융 행동
  }
  if (status('mvp-emergency-fund-account-auto-transfer') ==
      ChallengeStatus.executed) {
    earned.add(mockBadges[1]); // 자동저축 시작
  }
  if (done('mvp-money-scan-policy-benefits') ||
      done('mvp-year-end-tax-preview')) {
    earned.add(mockBadges[2]); // 혜택 탐험가
  }
  if (completions.values.any(
      (c) => c.status == ChallengeStatus.executed && c.hasEvidence)) {
    earned.add(mockBadges[3]); // 기록으로 남긴 실행 (증빙 보너스)
  }
  // 이번 주 유지 + 과거 연속 주 합산이 2주 이상이면 스트릭 배지.
  // 이번 주 기록 없이는 목 히스토리만으로 지급하지 않는다.
  if (completions.isNotEmpty &&
      1 + consecutivePastWeeks(mockStreakHistory) >= 2) {
    earned.add(mockBadges[4]); // 2주 금융 루틴
  }
  return earned;
});

/// 확보효과 상세 내역. track: 'realized'(지킨 돈) | 'reserved'(예약된 돈).
/// 실행 완료한 챌린지 중 해당 트랙 라벨에 금액이 있는 것만 반환한다.
final gainEntriesProvider =
    Provider.family<List<Challenge>, String>((ref, track) {
  final completions = ref.watch(challengeCompletionProvider);
  bool matchesTrack(Challenge c) => track == 'realized'
      ? c.gainLabel == GainLabel.realized
      : c.gainLabel == GainLabel.estimated ||
          c.gainLabel == GainLabel.annualized;
  return ref
      .watch(challengesProvider)
      .where((c) =>
          completions[c.id]?.status == ChallengeStatus.executed &&
          matchesTrack(c) &&
          completions[c.id]!.impactWon > 0)
      .toList();
});

/// 히스토리 끝(최근)에서부터 이어진 유지 주 수. 완료와 성실한 보류 모두
/// 유지로 센다 (docs/16 6장). provider 간 파생 체인을 피하려고 순수 함수로
/// 두고 weeklyStreakProvider와 earnedBadgesProvider가 공유한다.
int consecutivePastWeeks(List<WeeklyStreakEntry> history) {
  var weeks = 0;
  for (final entry in history.reversed) {
    if (entry.status == WeeklyStreakStatus.missed) break;
    weeks++;
  }
  return weeks;
}

/// 주간 스트릭 스냅샷.
class WeeklyStreak {
  const WeeklyStreak({
    required this.pastWeeks,
    required this.thisWeekKept,
    required this.thisWeekHeldOnly,
  });

  /// 과거 연속 유지 주 수 (목 히스토리 기준).
  final int pastWeeks;

  /// 이번 주 유지 여부: 완료(계획·실행) 또는 성실한 보류 기록 1개 이상.
  final bool thisWeekKept;

  /// 이번 주가 보류로만 유지됐는지 (문구·도트 구분용).
  final bool thisWeekHeldOnly;

  int get totalWeeks => thisWeekKept ? pastWeeks + 1 : pastWeeks;
}

/// 주간 스트릭. 매주 핵심 챌린지 1개 이상 완료 시 유지, 성실한 보류도
/// 유지로 인정한다 (docs/16 6장). 과거 주는 목 히스토리로 시뮬레이션.
/// TODO: 성실한 보류 게이트(사유 기록 + 재시도 예약)는 보류 사유 입력
/// 구현 시 강화한다.
final weeklyStreakProvider = Provider<WeeklyStreak>((ref) {
  final completions = ref.watch(challengeCompletionProvider);
  final kept = completions.isNotEmpty; // none은 저장되지 않는다
  final heldOnly = kept &&
      completions.values.every((c) => c.status == ChallengeStatus.held);
  return WeeklyStreak(
    pastWeeks: consecutivePastWeeks(mockStreakHistory),
    thisWeekKept: kept,
    thisWeekHeldOnly: heldOnly,
  );
});

/// 이번 주 추천 챌린지: 아직 완료하지 않은 첫 챌린지.
/// TODO: 진단 결과 기반 추천 룰(recommendedRoutes)로 교체.
final weeklyChallengeProvider = Provider<Challenge?>((ref) {
  final completions = ref.watch(challengeCompletionProvider);
  for (final c in ref.watch(challengesProvider)) {
    final status = completions[c.id]?.status ?? ChallengeStatus.none;
    if (status == ChallengeStatus.none || status == ChallengeStatus.held) {
      return c;
    }
  }
  return null;
});
