import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didim/main.dart';

Future<void> scrollToAndTap(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(find.text(text), 100);
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('홈 화면에 핵심 버튼 하나가 보인다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    expect(find.text('이번 주 챌린지 시작하기'), findsOneWidget);
    expect(find.text('지킨 돈'), findsOneWidget);
    expect(find.text('예약된 돈 (예상)'), findsOneWidget);
  });

  testWidgets('챌린지 실행 완료 시 리액션과 배지, 지도 진행도가 반영된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    // 홈 → 챌린지 상세 (첫 추천: 월급 하루 생존 테스트)
    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    expect(find.text('월급 하루 생존 테스트'), findsOneWidget);

    // 실행 완료 → 완료 리액션
    await scrollToAndTap(tester, '실행까지 했어요');
    expect(find.textContaining('실행 완료!'), findsOneWidget);
    expect(find.text('금융 효과'), findsOneWidget);
    expect(find.text('지도 변화'), findsOneWidget);
    expect(find.text('첫 금융 행동'), findsOneWidget); // 첫 배지

    await tester.scrollUntilVisible(find.text('다음 추천 챌린지'), 100);
    expect(find.text('다음 추천 챌린지'), findsOneWidget);

    // 홈으로 돌아가면 지도 진행도가 반영돼 있다 (생존 테스트 = 마을 15%)
    await scrollToAndTap(tester, '홈으로');
    await tester.scrollUntilVisible(find.text('15%'), 100);
    expect(find.text('15%'), findsOneWidget);
  });

  testWidgets('보류하면 홈으로 돌아오고 다음 주 재시도 안내가 보인다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await scrollToAndTap(tester, '이번 주는 보류할게요');

    expect(find.text('보류했어요. 다음 주에 다시 이어갈 수 있어요.'), findsOneWidget);
    expect(find.text('이번 주 챌린지 시작하기'), findsOneWidget);
  });
}
