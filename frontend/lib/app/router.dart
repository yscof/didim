import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../features/challenge/challenge_detail_screen.dart';
import '../features/challenge/completion_reaction_screen.dart';
import '../features/challenges/challenge_list_screen.dart';
import '../features/gains/gain_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/home/web_home_screen.dart';
import '../features/ledger/ledger_screen.dart';
import '../features/map/map_screen.dart';
import 'web_shell.dart';

/// 앱 인스턴스마다 새 라우터를 만든다 (테스트 격리를 위해 전역 상태 금지).
///
/// 라우트는 홈을 루트로 중첩한다. 이렇게 해야 하위 화면으로 갈 때는
/// push(오른쪽에서 등장), 뒤로 갈 때는 pop(오른쪽으로 퇴장 + 이전 화면이
/// 왼쪽에서 복귀) 애니메이션이 방향에 맞게 적용된다.
///
/// 웹/앱 분리: [webLayout]이 true면(기본값 kIsWeb) 모든 화면을 무신사
/// 스타일 상단 메뉴바가 있는 [WebShell]로 감싼다. 앱은 기존 화면 그대로다.
GoRouter createRouter({bool? webLayout}) {
  final isWeb = webLayout ?? kIsWeb;

  final routes = [
    GoRoute(
      path: '/',
      // 웹은 넓은 화면용 대시보드형 홈, 앱은 모바일 홈을 쓴다.
      builder: (context, state) =>
          isWeb ? const WebHomeScreen() : const HomeScreen(),
      routes: [
        GoRoute(
          path: 'challenges',
          builder: (context, state) => ChallengeListScreen(
            category: ChallengeCategory.values
                .asNameMap()[state.uri.queryParameters['category']],
            showAppBar: !isWeb,
          ),
        ),
        GoRoute(
          path: 'map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: 'ledger',
          builder: (context, state) => LedgerScreen(showAppBar: !isWeb),
        ),
        GoRoute(
          path: 'gains/:track',
          builder: (context, state) =>
              GainDetailScreen(track: state.pathParameters['track']!),
        ),
        GoRoute(
          path: 'challenge/:id',
          builder: (context, state) =>
              ChallengeDetailScreen(challengeId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'reaction',
              builder: (context, state) => CompletionReactionScreen(
                  challengeId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
  ];

  return GoRouter(
    routes: isWeb
        ? [
            ShellRoute(
              builder: (context, state, child) =>
                  WebShell(currentPath: state.uri.path, child: child),
              routes: routes,
            ),
          ]
        : routes,
  );
}
