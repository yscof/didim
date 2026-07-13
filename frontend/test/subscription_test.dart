import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:didim/data/ledger.dart' show sharedPreferencesProvider;
import 'package:didim/data/subscriptions.dart';
import 'package:didim/main.dart';

Future<SharedPreferences> freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('메뉴바에서 디지털 월세로 들어가 구독을 등록·삭제한다', (tester) async {
    final prefs = await freshPrefs();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DidimApp(webLayout: true),
    ));
    await tester.pumpAndSettle();

    // 메뉴바 → 디지털 월세 (빈 상태)
    await tester.tap(find.text('디지털 월세'));
    await tester.pumpAndSettle();
    expect(find.text('이번 달 디지털 월세'), findsOneWidget);
    expect(find.textContaining('아직 등록한 구독이 없어요'), findsOneWidget);

    // 구독 추가: 프리셋 칩으로 이름 채우고 요금 입력
    await tester.tap(find.text('구독 추가'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('넷플릭스'));
    await tester.pump();
    await tester.enterText(
        find.byKey(const Key('subscription-fee-input')), '17000');
    await tester.pump();
    await tester.ensureVisible(find.text('저장'));
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    // 요약(월 총액·연 환산)과 목록 반영
    expect(find.text('17,000원'), findsOneWidget);
    expect(find.text('구독 1개 · 연 환산 204,000원'), findsOneWidget);
    expect(find.text('넷플릭스'), findsOneWidget);

    // 절감 혜택·방법 안내가 보인다
    await tester.scrollUntilVisible(find.text('연간 결제로 전환'), 100);
    expect(find.text('연간 결제로 전환'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('구독 전수조사 챌린지 하러 가기'), 100);
    expect(find.text('구독 전수조사 챌린지 하러 가기'), findsOneWidget);

    // 삭제하면 빈 상태로 돌아간다. 섹션 헤더 기준으로 위로 스크롤해
    // 삭제 버튼이 FAB와 겹치지 않는 위치에 오게 한다.
    await tester.scrollUntilVisible(find.text('내 구독'), -100);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('삭제'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 등록한 구독이 없어요'), findsOneWidget);
  });

  test('저장 후 새 컨테이너에서 로드해도 구독이 유지된다', () async {
    final prefs = await freshPrefs();
    final overrides = [sharedPreferencesProvider.overrideWithValue(prefs)];

    final first = ProviderContainer(overrides: overrides);
    first.read(subscriptionsProvider.notifier).add(
        name: '유튜브 프리미엄', monthlyFeeWon: 14900, billingDay: 3);
    first.dispose();

    final second = ProviderContainer(overrides: overrides);
    final loaded = second.read(subscriptionsProvider);
    expect(loaded, hasLength(1));
    expect(loaded.single.name, '유튜브 프리미엄');
    expect(loaded.single.monthlyFeeWon, 14900);
    expect(loaded.single.billingDay, 3);
    second.dispose();
  });

  test('월 총액은 구독 요금 합계다', () async {
    final prefs = await freshPrefs();
    final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    final notifier = container.read(subscriptionsProvider.notifier);
    notifier.add(name: '넷플릭스', monthlyFeeWon: 17000);
    notifier.add(name: '쿠팡 와우', monthlyFeeWon: 7890);

    expect(container.read(digitalRentMonthlyProvider), 24890);
    container.dispose();
  });
}
