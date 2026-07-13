import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:didim/data/ledger.dart';
import 'package:didim/main.dart';

Future<SharedPreferences> freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('메뉴바에서 가계부로 들어가 기록을 추가·삭제할 수 있다', (tester) async {
    final prefs = await freshPrefs();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const DidimApp(webLayout: true),
    ));
    await tester.pumpAndSettle();

    // 웹 메뉴바 → 가계부 (빈 상태)
    await tester.tap(find.text('가계부'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 기록이 없어요'), findsOneWidget);

    // 기록하기 → 금액 4,500 + 카테고리 카페·간식 → 저장
    await tester.tap(find.text('기록하기'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('ledger-amount-input')), '4500');
    await tester.pumpAndSettle();
    await tester.tap(find.text('카페·간식'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('저장'));
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    // 요약(지출)과 내역에 반영. 메모가 없으면 카테고리명이 제목이 된다.
    expect(find.text('4,500원'), findsWidgets);
    expect(find.text('−4,500원'), findsOneWidget);
    expect(find.textContaining('아직 기록이 없어요'), findsNothing);

    // 삭제하면 다시 빈 상태
    await tester.tap(find.byTooltip('삭제'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 기록이 없어요'), findsOneWidget);
  });

  test('저장 후 새 컨테이너에서 로드해도 기록이 유지된다', () async {
    final prefs = await freshPrefs();
    final overrides = [sharedPreferencesProvider.overrideWithValue(prefs)];

    final first = ProviderContainer(overrides: overrides);
    first.read(ledgerProvider.notifier).add(
          kind: LedgerEntryKind.expense,
          amountWon: 12000,
          category: LedgerCategory.food,
          memo: '점심',
        );
    first.dispose();

    // 새 컨테이너 = 앱 재시작(새로고침) 시뮬레이션
    final second = ProviderContainer(overrides: overrides);
    final loaded = second.read(ledgerProvider);
    expect(loaded, hasLength(1));
    expect(loaded.single.amountWon, 12000);
    expect(loaded.single.memo, '점심');
    expect(loaded.single.category, LedgerCategory.food);
    second.dispose();
  });

  test('이번 달 합계는 지출과 수입을 구분해 계산한다', () async {
    final prefs = await freshPrefs();
    final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    final notifier = container.read(ledgerProvider.notifier);
    notifier.add(
        kind: LedgerEntryKind.expense,
        amountWon: 30000,
        category: LedgerCategory.food);
    notifier.add(
        kind: LedgerEntryKind.expense,
        amountWon: 9900,
        category: LedgerCategory.subscription);
    notifier.add(
        kind: LedgerEntryKind.income,
        amountWon: 2000000,
        category: LedgerCategory.salary);

    expect(container.read(monthlyExpenseTotalProvider), 39900);
    expect(container.read(monthlyIncomeTotalProvider), 2000000);
    final byCategory = container.read(monthlyExpenseByCategoryProvider);
    expect(byCategory.first, (LedgerCategory.food, 30000));
    container.dispose();
  });
}
