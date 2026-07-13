import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didim/data/evidence_picker.dart';
import 'package:didim/data/mock_challenges.dart';
import 'package:didim/data/models.dart';
import 'package:didim/features/challenge/completion_confirm_sheet.dart';
import 'package:didim/features/map/region_scene.dart';
import 'package:didim/main.dart';

/// 1x1 투명 PNG. 증빙 픽커 fake가 돌려주는 바이트.
final kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

Future<void> scrollToAndTap(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 100);
  await tester.ensureVisible(finder); // 부분적으로 가려진 경우 완전히 노출
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// 상세 화면의 스텝 체크리스트를 모두 체크한다 (실행 완료 게이트 1단).
Future<void> checkAllSteps(WidgetTester tester) async {
  for (var guard = 0; guard < 20; guard++) {
    final unchecked = find.byWidgetPredicate(
        (w) => w is CheckboxListTile && w.value == false);
    if (unchecked.evaluate().isEmpty) break;
    await tester.ensureVisible(unchecked.first);
    await tester.pumpAndSettle();
    await tester.tap(unchecked.first);
    await tester.pumpAndSettle();
  }
}

/// 실행 완료 게이트 전체를 통과한다: 스텝 전체 체크 → 완료 확인 시트에서
/// 자가체크·회고(+선택 증빙) → 확정. 확정하면 완료 리액션으로 이동한다.
Future<void> completeExecuted(WidgetTester tester,
    {bool attachEvidence = false}) async {
  await checkAllSteps(tester);
  await tester.scrollUntilVisible(find.text('실행까지 했어요'), 100);
  await tester.pumpAndSettle();
  await checkAllSteps(tester); // 스크롤로 새로 빌드된 스텝이 있으면 마저 체크
  await tester.scrollUntilVisible(find.text('실행까지 했어요'), 100);
  await tester.pumpAndSettle();

  final gateButton = find.widgetWithText(FilledButton, '실행까지 했어요');
  expect(tester.widget<FilledButton>(gateButton).onPressed, isNotNull,
      reason: '스텝을 모두 체크하면 실행 완료 버튼이 활성화되어야 한다');
  await tester.tap(gateButton);
  await tester.pumpAndSettle();

  final sheet = find.byType(CompletionConfirmSheet);
  expect(sheet, findsOneWidget);
  final sheetChecks =
      find.descendant(of: sheet, matching: find.byType(CheckboxListTile));
  for (var i = 0; i < sheetChecks.evaluate().length; i++) {
    await tester.ensureVisible(sheetChecks.at(i));
    await tester.tap(sheetChecks.at(i));
    await tester.pump();
  }

  // 금액형 챌린지면 실측값을 입력한다 (구독 기준 9,900원 → 연 118,800원)
  final impactField = find.byKey(const Key('impact-input'));
  if (impactField.evaluate().isNotEmpty) {
    await tester.enterText(impactField, '9900');
    await tester.pump();
  }

  await tester.enterText(
      find.byKey(const Key('reflection-input')), '생각보다 어렵지 않았어요');
  await tester.pump();

  if (attachEvidence) {
    await tester.ensureVisible(find.text('인증샷 첨부 (선택)'));
    await tester.tap(find.text('인증샷 첨부 (선택)'));
    await tester.pumpAndSettle();
    expect(find.text('인증샷 첨부됨'), findsOneWidget);
  }

  await tester.ensureVisible(find.text('실행 완료 확정'));
  await tester.tap(find.text('실행 완료 확정'));
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

    // 자가검증 게이트 통과 → 완료 리액션
    await completeExecuted(tester);
    expect(find.textContaining('실행 완료!'), findsOneWidget);
    expect(find.text('금융 효과'), findsOneWidget);
    expect(find.text('지도 변화'), findsOneWidget);
    expect(find.byType(RegionScene), findsOneWidget); // 지도 장면
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
    await completeExecuted(tester);
    await scrollToAndTap(tester, '다음 챌린지 확인');
    await completeExecuted(tester);
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

  testWidgets('스텝을 모두 체크해야 실행 완료 버튼이 활성화된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');

    // 스텝 미체크: 버튼 비활성 + 안내 문구
    final gateButton = find.widgetWithText(FilledButton, '실행까지 했어요');
    await tester.scrollUntilVisible(gateButton, 100);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(gateButton).onPressed, isNull);
    expect(
        find.text('위 단계를 모두 체크하면 실행 완료를 진행할 수 있어요.'), findsOneWidget);

    // 전체 체크 후 활성화
    await checkAllSteps(tester);
    await tester.scrollUntilVisible(gateButton, 100);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(gateButton).onPressed, isNotNull);
    expect(
        find.text('위 단계를 모두 체크하면 실행 완료를 진행할 수 있어요.'), findsNothing);
  });

  testWidgets('완료 확인 시트는 자가체크와 회고를 모두 채워야 확정된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await checkAllSteps(tester);
    await scrollToAndTap(tester, '실행까지 했어요');

    // 시트 초기: 확정 버튼 비활성
    final confirmButton = find.widgetWithText(FilledButton, '실행 완료 확정');
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

    // 자가체크만으로는 부족 (M-1은 질문 1개)
    final sheetCheck = find.descendant(
        of: find.byType(CompletionConfirmSheet),
        matching: find.byType(CheckboxListTile));
    await tester.tap(sheetCheck);
    await tester.pump();
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

    // 회고까지 입력하면 활성 → 확정 → 리액션 (증빙 없으면 보너스 없음)
    await tester.enterText(
        find.byKey(const Key('reflection-input')), '예상보다 작았어요');
    await tester.pump();
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNotNull);

    await tester.ensureVisible(find.text('실행 완료 확정'));
    await tester.tap(find.text('실행 완료 확정'));
    await tester.pumpAndSettle();
    expect(find.textContaining('실행 완료!'), findsOneWidget);
    expect(find.text('실행 인증 보너스'), findsNothing);
  });

  testWidgets('시트에서 아직이에요를 누르면 계획 완료로 저장된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await checkAllSteps(tester);
    await scrollToAndTap(tester, '실행까지 했어요');

    await tester.ensureVisible(find.text('아직이에요 — 계획 완료로 저장'));
    await tester.tap(find.text('아직이에요 — 계획 완료로 저장'));
    await tester.pumpAndSettle();
    expect(find.textContaining('계획 완료!'), findsOneWidget);

    // 계획 완료는 가중치 50%만 반영된다 (생존 테스트 15% → 8%)
    await scrollToAndTap(tester, '홈으로');
    await tester.scrollUntilVisible(find.text('8%'), 100);
    expect(find.text('8%'), findsOneWidget);
  });

  testWidgets('금액형 챌린지는 실측 입력이 있어야 확정되고 입력값으로 계산된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    // M-1 완료 후 다음 챌린지(구독 전수조사 = 금액형)로 이동
    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await completeExecuted(tester);
    await scrollToAndTap(tester, '다음 챌린지 확인');

    await checkAllSteps(tester);
    await scrollToAndTap(tester, '실행까지 했어요');

    // 자가체크 + 회고를 채워도 실측 금액이 없으면 확정할 수 없다
    final sheet = find.byType(CompletionConfirmSheet);
    final sheetChecks =
        find.descendant(of: sheet, matching: find.byType(CheckboxListTile));
    for (var i = 0; i < sheetChecks.evaluate().length; i++) {
      await tester.ensureVisible(sheetChecks.at(i));
      await tester.tap(sheetChecks.at(i));
      await tester.pump();
    }
    await tester.enterText(
        find.byKey(const Key('reflection-input')), '넷플릭스를 해지했어요');
    await tester.pump();
    final confirmButton = find.widgetWithText(FilledButton, '실행 완료 확정');
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

    // 월 요금을 입력하면 연 환산 계산이 보이고 확정할 수 있다
    await tester.enterText(find.byKey(const Key('impact-input')), '9900');
    await tester.pump();
    expect(find.textContaining('확보효과: 118,800원'), findsOneWidget);
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNotNull);

    await tester.ensureVisible(find.text('실행 완료 확정'));
    await tester.tap(find.text('실행 완료 확정'));
    await tester.pumpAndSettle();

    // 리액션 금융 효과에 내 입력값 기반 계산 결과가 보인다
    expect(find.textContaining('118,800원을 확보했어요'), findsOneWidget);
  });

  testWidgets('인증샷을 첨부하면 보너스 배지를 받고 금액에는 가산되지 않는다', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        evidencePickerProvider.overrideWithValue(() async => kTransparentPng),
      ],
      child: const DidimApp(),
    ));
    await tester.pumpAndSettle();

    // M-1(발견형: 금액 0원)을 증빙과 함께 실행 완료
    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await completeExecuted(tester, attachEvidence: true);

    // 보너스 카드 + 보너스 배지
    expect(find.text('실행 인증 보너스'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('기록으로 남긴 실행'), 100);
    expect(find.text('기록으로 남긴 실행'), findsOneWidget);

    // 진정성 원칙: 증빙 보너스는 지킨 돈/예약된 돈에 가산되지 않는다
    await scrollToAndTap(tester, '홈으로');
    expect(find.text('0원'), findsNWidgets(2));
  });

  testWidgets('웹 레이아웃: 메뉴바로 챌린지 리스트에 가서 카테고리별로 본다', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: DidimApp(webLayout: true)));
    await tester.pumpAndSettle();

    // 상단 메뉴바: 로고 + 왼쪽 정렬 글로벌 메뉴 (Footer 브랜드 문구와
    // 중복될 수 있어 개수 대신 존재만 확인한다)
    expect(find.text('디딤'), findsWidgets);
    expect(find.text('여정 지도'), findsOneWidget);

    // 웹 홈: 넓은 화면용 대시보드 레이아웃 (히어로 + 지역 카드 그리드)
    expect(find.text('이번 주 챌린지 시작하기'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('생활비 마을'), 100);
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

    // 성실한 보류도 스트릭 유지로 인정한다 (docs/16 6장)
    expect(find.text('이번 주는 성실한 보류로 리듬을 지켰어요.'), findsOneWidget);
  });

  testWidgets('주간 스트릭: 완료하면 3주 연속이 되고 2주 루틴 배지를 받는다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    // 목 히스토리: 쉼 → 완료 → 성실한 보류 = 과거 2주 연속 유지
    expect(find.text('이번 주 챌린지를 완료하면 3주 연속이 돼요.'), findsOneWidget);

    await scrollToAndTap(tester, '이번 주 챌린지 시작하기');
    await completeExecuted(tester);
    await scrollToAndTap(tester, '홈으로');

    expect(find.text('🔥 3주 연속 금융 루틴'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2주 금융 루틴'), 100);
    expect(find.text('2주 금융 루틴'), findsOneWidget);
  });
}
