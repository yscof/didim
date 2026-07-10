import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didim/data/mock_challenges.dart';
import 'package:didim/data/models.dart';
import 'package:didim/main.dart';

Future<void> scrollToAndTap(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 100);
  await tester.ensureVisible(finder); // 부분적으로 가려진 경우 완전히 노출
  await tester.pumpAndSettle();
  await tester.tap(finder);
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

  testWidgets('예약된 돈 카드를 누르면 챌린지별 상세 내역이 보인다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    // M-1(발견형) 완료 → 다음 챌린지(구독 전수조사, 연 환산 118,800원) 완료
    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await scrollToAndTap(tester, '실행까지 했어요');
    await scrollToAndTap(tester, '다음 챌린지 확인');
    await scrollToAndTap(tester, '실행까지 했어요');
    await scrollToAndTap(tester, '홈으로');

    // 예약된 돈 카드 → 상세 내역
    await tester.scrollUntilVisible(find.text('예약된 돈 (예상)'), 100);
    await tester.tap(find.text('예약된 돈 (예상)'));
    await tester.pumpAndSettle();

    expect(find.text('지금까지 예약된 돈 (예상)'), findsOneWidget);
    expect(find.text('구독 전수조사 + 1개 이상 해지'), findsOneWidget);
    expect(find.text('+118,800원'), findsOneWidget);

    // 발견형(M-1)은 금액이 없으므로 내역에 나타나지 않는다
    expect(find.text('월급 하루 생존 테스트'), findsNothing);
  });

  testWidgets('웹 레이아웃: 메뉴바로 챌린지 리스트에 가서 카테고리별로 본다', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: DidimApp(webLayout: true)));
    await tester.pumpAndSettle();

    // 상단 메뉴바: 로고 + 왼쪽 정렬 글로벌 메뉴
    expect(find.text('디딤'), findsOneWidget);
    expect(find.text('여정 지도'), findsOneWidget);

    // 웹 홈: 넓은 화면용 대시보드 레이아웃 (히어로 + 지역 카드 그리드)
    expect(find.text('이번 주 챌린지 시작하기'), findsOneWidget);
    expect(find.text('생활비 마을'), findsOneWidget);

    await tester.tap(find.text('챌린지'));
    await tester.pumpAndSettle();
    expect(find.text('전체 챌린지 ${mockChallenges.length}개'), findsOneWidget);

    // 연말정산 카테고리: 세금 챌린지들 + 청약통장(소득공제 관련)
    await tester.tap(find.text('연말정산'));
    await tester.pumpAndSettle();
    final yearEndTaxCount = mockChallenges
        .where((c) => c.categories.contains(ChallengeCategory.yearEndTax))
        .length;
    expect(find.text('연말정산 챌린지 $yearEndTaxCount개'), findsOneWidget);
    expect(find.text('13월의 월급 예약하기'), findsOneWidget);
    expect(find.text('청약통장 만들기'), findsOneWidget);
    expect(find.text('무지출 데이 1회'), findsNothing);

    // 리스트에서 챌린지를 누르면 상세로 가고, 메뉴바는 유지된다
    await tester.tap(find.text('청약통장 만들기'));
    await tester.pumpAndSettle();
    expect(find.text('왜 필요한가요?'), findsOneWidget);
    expect(find.text('디딤'), findsOneWidget);
  });

  testWidgets('앱 레이아웃에는 상단 메뉴바가 없다', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: DidimApp(webLayout: false)));
    await tester.pumpAndSettle();

    expect(find.text('디딤'), findsNothing);
    expect(find.text('여정 지도'), findsNothing);
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
