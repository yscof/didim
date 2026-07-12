import 'package:flutter/material.dart';

/// 지역 진행도를 마일스톤 이모지 장면으로 표현하는 플레이스홀더.
///
/// 마일스톤 규칙(20/40/60/80/100%)은 shared/gamification/journey-map.yaml
/// milestones 계약을 따른다. 연출 수준(정적 일러스트 vs 애니메이션)은 9월
/// 별도 결정 예정이라(docs/09), 이모지 세트는 데이터 계약에 넣지 않고
/// 이 파일에만 둔다. 미도달 마일스톤은 흐리게 보여 "다음에 나타날 것"을
/// 예고한다 (Fortune City 패턴: 행동 직후 즉시 가시화).
class RegionScene extends StatelessWidget {
  const RegionScene({
    super.key,
    required this.regionId,
    required this.percent,
    this.previousPercent,
  });

  final String regionId;
  final int percent;

  /// 직전 진행도. null이 아니면 이번에 새로 도달한 마일스톤에
  /// 등장 연출(1회 스케일 애니메이션)을 적용한다. 지도 화면은 null.
  final int? previousPercent;

  static const _milestones = [20, 40, 60, 80, 100];

  /// 지역별 장면 스펙. 마일스톤 의미: 20 길·지형 / 40 작은 건물·나무 /
  /// 60 지역 대표 오브젝트 / 80 활성화(불빛·주민) / 100 지역 완성.
  static const _specs = <String, _SceneSpec>{
    'region-living-cost-village': _SceneSpec(
      emojis: ['🛤️', '🏠', '🏪', '🏮', '🏘️'],
      color: Colors.amber,
    ),
    'region-emergency-forest': _SceneSpec(
      emojis: ['🌱', '🌿', '🌳', '🦌', '🏕️'],
      color: Colors.green,
    ),
    'region-benefit-harbor': _SceneSpec(
      emojis: ['🌊', '⛵', '⚓', '🗼', '🚢'],
      color: Colors.blue,
    ),
    'region-year-end-tax': _SceneSpec(
      emojis: ['🗺️', '🗂️', '🏦', '🪙', '💰'],
      color: Colors.indigo,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final spec = _specs[regionId];
    if (spec == null) return const SizedBox.shrink(); // 베타 지역 가드

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [spec.color.shade50, spec.color.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (index, milestone) in _milestones.indexed)
            _MilestoneSlot(
              key: Key(
                  'scene-$regionId-$milestone-${percent >= milestone ? 'on' : 'off'}'),
              emoji: spec.emojis[index],
              milestone: milestone,
              reached: percent >= milestone,
              // 이번에 새로 도달한 마일스톤만 등장 연출.
              justRevealed: previousPercent != null &&
                  previousPercent! < milestone &&
                  percent >= milestone,
            ),
        ],
      ),
    );
  }
}

class _SceneSpec {
  const _SceneSpec({required this.emojis, required this.color});

  final List<String> emojis;
  final MaterialColor color;
}

class _MilestoneSlot extends StatelessWidget {
  const _MilestoneSlot({
    super.key,
    required this.emoji,
    required this.milestone,
    required this.reached,
    required this.justRevealed,
  });

  final String emoji;
  final int milestone;
  final bool reached;
  final bool justRevealed;

  @override
  Widget build(BuildContext context) {
    Widget slot = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 이모지는 색을 무시하므로 미도달 표시는 Opacity로 처리한다.
        Opacity(
          opacity: reached ? 1 : 0.2,
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
        const SizedBox(height: 2),
        Text('$milestone%', style: Theme.of(context).textTheme.bodySmall),
      ],
    );

    if (justRevealed) {
      // 유한 1회 애니메이션 (무한 반복 금지 — 테스트 pumpAndSettle 안전).
      slot = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: slot,
      );
    }
    return slot;
  }
}
