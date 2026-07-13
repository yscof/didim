import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didim/main.dart';

void main() {
  testWidgets('메뉴바에서 서비스 소개로 들어가 상세 페이지까지 본다', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: DidimApp(webLayout: true)));
    await tester.pumpAndSettle();

    // 메뉴바 → 서비스 소개 (Footer에도 같은 라벨 링크가 있어 키로 탭한다)
    await tester.tap(find.byKey(const ValueKey('nav:/about')));
    await tester.pumpAndSettle();
    // 소개 본문과 Footer 브랜드 문구에 같은 태그라인이 있어 존재만 확인한다.
    expect(find.text('사회초년생을 위한 금융 행동 코치'), findsWidgets);
    expect(find.text('무엇을 할 수 있나요'), findsOneWidget);
    expect(find.text('챌린지 & 금융 여정 지도'), findsOneWidget);

    // 완료 검증 상세: OCR가 아니라 자가검증 게이트
    await tester.scrollUntilVisible(find.text('완료 검증 자세히 보기'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('완료 검증 자세히 보기'));
    await tester.pumpAndSettle();
    expect(find.text('자가검증 게이트'), findsOneWidget);
    expect(find.text('실측 입력'), findsOneWidget);
    expect(find.text('인증샷은 선택, 보너스만'), findsOneWidget);

    // 뒤로 → 보상 시스템 상세: 현금·랭킹 없음, 비교 대상은 과거의 나
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('보상 시스템 자세히 보기'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('보상 시스템 자세히 보기'));
    await tester.pumpAndSettle();
    expect(find.text('현금·포인트·실물 보상은 없어요'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('"같은 나이 상위 몇 %"는 왜 없나요'), 100);
    expect(find.text('"같은 나이 상위 몇 %"는 왜 없나요'), findsOneWidget);
  });
}
