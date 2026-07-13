import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 웹 전용 셸. 무신사 웹의 상단 바 구조(로고 + 글로벌 메뉴 + 하단 카테고리
/// 탭)를 따르되, 색은 서비스 브랜드 그린을 쓴다. 앱(모바일)에서는 사용하지
/// 않는다.
class WebShell extends StatelessWidget {
  const WebShell({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _WebHeader(currentPath: currentPath),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _WebHeader extends StatelessWidget {
  const _WebHeader({required this.currentPath});

  final String currentPath;

  /// 브랜드 그린 (main.dart 테마 시드 색과 동일).
  static const _brandGreen = Color(0xFF2F6B4F);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _brandGreen,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.go('/'),
                      child: const Text(
                        '디딤',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    // 메뉴는 로고 옆 왼쪽 정렬. 로고와는 한 뼘 띄운다.
                    const SizedBox(width: 36),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        final menu = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 홈은 로고가 대신한다 (중복 메뉴 제거).
                            // 키는 테스트에서 Footer 링크와 같은 라벨을
                            // 구분하기 위한 식별자다.
                            _NavItem(
                              key: const ValueKey('nav:/challenges'),
                              label: '챌린지',
                              path: '/challenges',
                              active: currentPath.startsWith('/challenge'),
                            ),
                            _NavItem(
                              key: const ValueKey('nav:/map'),
                              label: '여정 지도',
                              path: '/map',
                              active: currentPath.startsWith('/map'),
                            ),
                            _NavItem(
                              key: const ValueKey('nav:/ledger'),
                              label: '가계부',
                              path: '/ledger',
                              active: currentPath.startsWith('/ledger'),
                            ),
                            _NavItem(
                              key: const ValueKey('nav:/subscriptions'),
                              label: '디지털 월세',
                              path: '/subscriptions',
                              active:
                                  currentPath.startsWith('/subscriptions'),
                            ),
                            _NavItem(
                              key: const ValueKey('nav:/cards'),
                              label: '카드 재테크',
                              path: '/cards',
                              active: currentPath.startsWith('/cards'),
                            ),
                            _NavItem(
                              key: const ValueKey('nav:/about'),
                              label: '서비스 소개',
                              path: '/about',
                              active: currentPath.startsWith('/about'),
                            ),
                          ],
                        );
                        // 좁은 창에서만 가로 스크롤로 전환한다. 평소에는 일반
                        // Row를 유지해 페이지 세로 스크롤 동작(테스트 포함)을
                        // 방해하지 않는다.
                        if (constraints.maxWidth < 600) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: menu,
                          );
                        }
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: menu,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.label,
    required this.path,
    required this.active,
  });

  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(path),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white60,
            fontSize: 15,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
