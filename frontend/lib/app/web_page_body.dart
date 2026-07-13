import 'package:flutter/material.dart';

import 'web_footer.dart';

/// 페이지 본문 공통 골격.
///
/// 웹다운 화면을 위해 스크롤 영역을 화면 전체 폭으로 깔아 스크롤바가
/// 브라우저 오른쪽 끝에 붙게 하고, 콘텐츠만 가운데 [maxWidth]로 제한한다.
/// (기존 `Center > ConstrainedBox > ListView` 구조는 스크롤바가 콘텐츠
/// 컬럼 안쪽에 떠서 모바일처럼 보였다.)
///
/// [footer]가 true면(웹 레이아웃) 페이지 맨 아래에 전체 폭 [WebFooter]를
/// 붙인다. 콘텐츠가 짧아도 Footer는 화면 하단에 고정된다.
///
/// 앱(모바일)에서 써도 무해하다 — 화면 폭이 [maxWidth]보다 좁으면
/// 기존 ListView와 동일하게 보인다.
class WebPageBody extends StatelessWidget {
  const WebPageBody({
    super.key,
    required this.children,
    this.maxWidth = 960,
    this.padding,
    this.footer = false,
  });

  final List<Widget> children;
  final double maxWidth;

  /// 콘텐츠 패딩. null이면 웹 기본값을 쓴다.
  final EdgeInsetsGeometry? padding;
  final bool footer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            // 콘텐츠가 짧아도 Footer가 화면 하단에 붙도록 최소 높이를
            // 뷰포트 높이로 잡는다 (스티키 푸터 패턴).
            constraints: BoxConstraints(minHeight: viewport.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: padding ??
                          const EdgeInsets.fromLTRB(24, 28, 24, 48),
                      child: Column(
                        // ListView와 동일하게 자식을 가로로 꽉 채운다.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ),
                if (footer) const WebFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
