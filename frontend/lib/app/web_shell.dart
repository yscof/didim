import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 웹 전용 셸. 무신사 웹처럼 검은 상단 바(왼쪽 로고 + 오른쪽 글로벌 메뉴)를
/// 모든 화면 위에 고정한다. 앱(모바일)에서는 사용하지 않는다.
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
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
                    const Spacer(),
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
