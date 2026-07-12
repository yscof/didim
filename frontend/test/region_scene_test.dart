import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didim/features/map/region_scene.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('진행도 0%면 모든 마일스톤이 흐린 예고 상태다', (tester) async {
    await tester.pumpWidget(wrap(
        const RegionScene(regionId: 'region-emergency-forest', percent: 0)));
    for (final m in [20, 40, 60, 80, 100]) {
      expect(find.byKey(Key('scene-region-emergency-forest-$m-off')),
          findsOneWidget);
    }
  });

  testWidgets('진행도 45%면 20·40% 오브젝트만 나타난다', (tester) async {
    await tester.pumpWidget(wrap(
        const RegionScene(regionId: 'region-emergency-forest', percent: 45)));
    expect(find.byKey(const Key('scene-region-emergency-forest-20-on')),
        findsOneWidget);
    expect(find.byKey(const Key('scene-region-emergency-forest-40-on')),
        findsOneWidget);
    for (final m in [60, 80, 100]) {
      expect(find.byKey(Key('scene-region-emergency-forest-$m-off')),
          findsOneWidget);
    }
  });

  testWidgets('진행도 100%면 지역 오브젝트가 전부 완성된다', (tester) async {
    await tester.pumpWidget(wrap(
        const RegionScene(regionId: 'region-year-end-tax', percent: 100)));
    for (final m in [20, 40, 60, 80, 100]) {
      expect(
          find.byKey(Key('scene-region-year-end-tax-$m-on')), findsOneWidget);
    }
  });

  testWidgets('새로 도달한 마일스톤의 등장 연출은 유한하게 끝난다', (tester) async {
    await tester.pumpWidget(wrap(const RegionScene(
      regionId: 'region-living-cost-village',
      percent: 45,
      previousPercent: 20,
    )));
    // 무한 애니메이션이 있으면 여기서 타임아웃으로 실패한다.
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('scene-region-living-cost-village-40-on')),
        findsOneWidget);
  });

  testWidgets('정의되지 않은 지역은 아무것도 그리지 않는다', (tester) async {
    await tester.pumpWidget(
        wrap(const RegionScene(regionId: 'region-unknown', percent: 50)));
    expect(find.byType(RegionScene), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });
}
