import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didim/app/web_footer.dart';
import 'package:didim/main.dart';

void main() {
  testWidgets('웹 홈 하단에 Footer가 있고 법적 고지 페이지로 이동한다', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: DidimApp(webLayout: true)));
    await tester.pumpAndSettle();

    // 페이지 끝까지 스크롤하면 Footer와 면책 문구가 보인다
    await tester.scrollUntilVisible(find.byType(WebFooter), 200);
    await tester.scrollUntilVisible(
        find.text('© 2026 didim. All rights reserved.'), 100);
    expect(find.textContaining('특정 금융상품의 추천·권유·중개'), findsOneWidget);
    expect(find.text('운영: 디딤 팀 · 문의 채널 준비 중'), findsOneWidget);

    // 면책 고지 페이지
    await tester.ensureVisible(find.text('면책 고지'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('면책 고지'));
    await tester.pumpAndSettle();
    expect(find.text('금융상품 추천이 아닙니다'), findsOneWidget);
    expect(find.text('모든 금액은 추정치입니다'), findsOneWidget);

    // 뒤로 → 개인정보처리방침
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('개인정보처리방침'), 100);
    await tester.ensureVisible(find.text('개인정보처리방침'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('개인정보처리방침'));
    await tester.pumpAndSettle();
    expect(find.text('수집하는 개인정보'), findsOneWidget);
    expect(find.textContaining('localStorage'), findsOneWidget);

    // 뒤로 → 이용약관
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('이용약관'), 100);
    await tester.ensureVisible(find.text('이용약관'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이용약관'));
    await tester.pumpAndSettle();
    expect(find.text('제1조 (서비스의 성격)'), findsOneWidget);
  });

  testWidgets('앱 레이아웃(모바일)에는 Footer가 없다', (tester) async {
    await tester.pumpWidget(
        const ProviderScope(child: DidimApp(webLayout: false)));
    await tester.pumpAndSettle();

    expect(find.byType(WebFooter), findsNothing);
  });
}
