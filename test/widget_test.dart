// 앱 스모크 테스트: 첫 화면(Engage)이 정상 렌더링되는지 확인.
import 'package:didim/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Engage 화면이 렌더링되고 도전하기 버튼이 보인다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    expect(find.text('도전하기'), findsOneWidget);
    expect(find.textContaining('라떼 팩터'), findsWidgets);
  });

  testWidgets('CBL 4단계 흐름을 끝까지 통과해 챌린지를 완료한다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DidimApp()));
    await tester.pumpAndSettle();

    // ① Engage → Investigate
    await tester.tap(find.text('도전하기'));
    await tester.pumpAndSettle();
    expect(find.text('라떼 팩터란?'), findsOneWidget);

    // ② Investigate → Act
    await tester.tap(find.text('내 라떼 팩터 계산하기'));
    await tester.pumpAndSettle();
    // 입력 폼이 보인다.
    expect(find.text('무엇에 쓰나요?'), findsOneWidget);

    // ③ Act → Reflect (버튼이 ListView 하단이라 스크롤 후 탭)
    await tester.scrollUntilVisible(
      find.text('회고하기'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('회고하기'));
    await tester.pumpAndSettle();
    expect(find.text('스스로에게 물어보기'), findsOneWidget);

    // ④ 자가 체크 후 완료 (완료 버튼은 체크 전엔 비활성)
    await tester.scrollUntilVisible(
      find.byType(Checkbox),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('챌린지 완료'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('챌린지 완료'));
    await tester.pumpAndSettle();
    expect(find.text('✅ 챌린지 완료'), findsOneWidget);
  });
}
