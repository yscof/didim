import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';

void main() {
  runApp(const ProviderScope(child: DidimApp()));
}

class DidimApp extends StatefulWidget {
  const DidimApp({super.key});

  @override
  State<DidimApp> createState() => _DidimAppState();
}

class _DidimAppState extends State<DidimApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '디딤',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6B4F)),
        useMaterial3: true,
        // 모든 플랫폼에서 좌우 슬라이드 전환으로 통일한다.
        // push: 새 화면이 오른쪽에서 등장 / pop: 현재 화면이 오른쪽으로
        // 퇴장하고 이전 화면이 왼쪽에서 복귀.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: _router,
    );
  }
}
