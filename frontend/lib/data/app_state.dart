import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_challenges.dart';
import 'models.dart';

final challengesProvider = Provider<List<Challenge>>((ref) => mockChallenges);
final regionsProvider = Provider<List<MapRegion>>((ref) => mockRegions);

final challengeByIdProvider = Provider.family<Challenge?, String>((ref, id) {
  for (final c in ref.watch(challengesProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

/// 챌린지별 완료 상태. TODO: 백엔드 연동 시 서버 상태로 교체.
class ChallengeProgress extends Notifier<Map<String, ChallengeStatus>> {
  @override
  Map<String, ChallengeStatus> build() => const {};

  void setStatus(String challengeId, ChallengeStatus status) {
    state = {...state, challengeId: status};
  }
}

final challengeProgressProvider =
    NotifierProvider<ChallengeProgress, Map<String, ChallengeStatus>>(
        ChallengeProgress.new);

/// 지역 진행도(%). 실행 완료 = 가중치 100%, 계획 완료 = 50% 반영.
/// 규칙 출처: shared/gamification/journey-map.yaml progressRules.
final regionProgressProvider = Provider.family<int, String>((ref, regionId) {
  final progress = ref.watch(challengeProgressProvider);
  final challenges = ref.watch(challengesProvider);
  var percent = 0.0;
  for (final c in challenges) {
    if (c.regionId != regionId) continue;
    switch (progress[c.id]) {
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
final realizedWonProvider = Provider<int>((ref) {
  final progress = ref.watch(challengeProgressProvider);
  return ref
      .watch(challengesProvider)
      .where((c) =>
          c.gainLabel == GainLabel.realized &&
          progress[c.id] == ChallengeStatus.executed)
      .fold(0, (sum, c) => sum + c.impactAmountWon);
});

/// 예약된 돈: estimated·annualized 효과의 별도 트랙 (실행 완료 기준).
final reservedWonProvider = Provider<int>((ref) {
  final progress = ref.watch(challengeProgressProvider);
  return ref
      .watch(challengesProvider)
      .where((c) =>
          (c.gainLabel == GainLabel.estimated ||
              c.gainLabel == GainLabel.annualized) &&
          progress[c.id] == ChallengeStatus.executed)
      .fold(0, (sum, c) => sum + c.impactAmountWon);
});

/// 획득한 배지. 규칙 출처: shared/gamification/badges.yaml.
final earnedBadgesProvider = Provider<List<DidimBadge>>((ref) {
  final progress = ref.watch(challengeProgressProvider);
  bool done(String id) =>
      progress[id] == ChallengeStatus.planned ||
      progress[id] == ChallengeStatus.executed;

  final earned = <DidimBadge>[];
  if (progress.values.any((s) =>
      s == ChallengeStatus.planned || s == ChallengeStatus.executed)) {
    earned.add(mockBadges[0]); // 첫 금융 행동
  }
  if (progress['mvp-emergency-fund-account-auto-transfer'] ==
      ChallengeStatus.executed) {
    earned.add(mockBadges[1]); // 자동저축 시작
  }
  if (done('mvp-money-scan-policy-benefits') ||
      done('mvp-year-end-tax-preview')) {
    earned.add(mockBadges[2]); // 혜택 탐험가
  }
  return earned;
});

/// 이번 주 추천 챌린지: 아직 완료하지 않은 첫 챌린지.
/// TODO: 진단 결과 기반 추천 룰(recommendedRoutes)로 교체.
final weeklyChallengeProvider = Provider<Challenge?>((ref) {
  final progress = ref.watch(challengeProgressProvider);
  for (final c in ref.watch(challengesProvider)) {
    final status = progress[c.id] ?? ChallengeStatus.none;
    if (status == ChallengeStatus.none || status == ChallengeStatus.held) {
      return c;
    }
  }
  return null;
});
