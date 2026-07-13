import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:didim/data/cards.dart';
import 'package:didim/data/ledger.dart' show sharedPreferencesProvider;
import 'package:didim/main.dart';

Future<SharedPreferences> freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('메뉴바에서 카드 재테크로 들어가 실적을 관리한다', (tester) async {
    final prefs = await freshPrefs();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DidimApp(webLayout: true),
    ));
    await tester.pumpAndSettle();

    // 메뉴바 → 카드 재테크 (빈 상태 + 월말 D-day 안내)
    await tester.tap(find.text('카드 재테크'));
    await tester.pumpAndSettle();
    expect(find.textContaining('실적 마감까지 D-'), findsOneWidget);
    expect(find.textContaining('아직 등록한 카드가 없어요'), findsOneWidget);

    // 카드 추가: 이름 + 월 실적 기준 30만
    await tester.tap(find.text('카드 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('card-name-input')), '통신비 할인 카드');
    await tester.enterText(
        find.byKey(const Key('card-target-input')), '300000');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('저장'));
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    // 초기: 0원 / 기준 30만, 남은 금액 = 기준 전액
    expect(find.text('이번 달 0원 / 기준 300,000원'), findsOneWidget);
    expect(find.textContaining('앞으로 300,000원 더 쓰면'), findsOneWidget);

    // 사용액 12만 입력 → 남은 18만
    await tester.tap(find.text('이번 달 사용액 입력'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('card-spent-input')), '120000');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.textContaining('앞으로 180,000원 더 쓰면'), findsOneWidget);

    // 사용액 35만 입력 → 실적 달성
    await tester.tap(find.text('이번 달 사용액 입력'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('card-spent-input')), '350000');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.textContaining('실적 달성!'), findsOneWidget);

    // 삭제 → 빈 상태
    await tester.tap(find.byTooltip('삭제'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 등록한 카드가 없어요'), findsOneWidget);
  });

  test('실적·해지 가능일·연회비 계산이 맞다', () {
    final card = CardEntry(
      id: '1',
      name: '테스트 카드',
      monthlyTargetWon: 100000,
      issuedAt: DateTime(2026, 1, 15),
      minHoldMonths: 6,
      annualFeeWon: 15000,
      spentWon: 50000,
      spentYearMonth: '2026-06',
    );

    // 입력한 달(6월) 기준으로는 사용액이 유효, 달이 바뀌면 0으로 리셋
    expect(card.effectiveSpentWon(DateTime(2026, 6, 20)), 50000);
    expect(card.remainingWon(DateTime(2026, 6, 20)), 50000);
    expect(card.effectiveSpentWon(DateTime(2026, 7, 13)), 0);
    expect(card.remainingWon(DateTime(2026, 7, 13)), 100000);

    // 해지 가능일 = 발급일 + 의무 유지 6개월
    expect(card.cancellableOn, DateTime(2026, 7, 15));

    // 다음 연회비 = 발급일 기준 다음 기념일
    expect(card.nextAnnualFeeDate(DateTime(2026, 7, 13)), DateTime(2027, 1, 15));
    expect(card.nextAnnualFeeDate(DateTime(2026, 1, 10)), DateTime(2026, 1, 15));
  });

  test('저장 후 새 컨테이너에서 로드해도 카드가 유지된다', () async {
    final prefs = await freshPrefs();
    final overrides = [sharedPreferencesProvider.overrideWithValue(prefs)];

    final first = ProviderContainer(overrides: overrides);
    first.read(cardsProvider.notifier).add(
          name: '내 카드',
          monthlyTargetWon: 300000,
          issuedAt: DateTime(2026, 3, 1),
          minHoldMonths: 6,
        );
    final id = first.read(cardsProvider).single.id;
    first.read(cardsProvider.notifier).updateSpent(id, 90000);
    first.dispose();

    final second = ProviderContainer(overrides: overrides);
    final loaded = second.read(cardsProvider).single;
    expect(loaded.name, '내 카드');
    expect(loaded.monthlyTargetWon, 300000);
    expect(loaded.spentWon, 90000);
    expect(loaded.effectiveSpentWon(DateTime.now()), 90000);
    second.dispose();
  });
}
