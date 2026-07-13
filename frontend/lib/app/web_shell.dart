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
                    _NavItem(
                      label: '홈',
                      path: '/',
                      active: currentPath == '/',
                    ),
                    _NavItem(
                      label: '챌린지',
                      path: '/challenges',
                      active: currentPath.startsWith('/challenge'),
                    ),
                    _NavItem(
                      label: '여정 지도',
                      path: '/map',
                      active: currentPath.startsWith('/map'),
                    ),
                    _NavItem(
                      label: '가계부',
                      path: '/ledger',
                      active: currentPath.startsWith('/ledger'),
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
