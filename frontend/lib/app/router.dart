import 'package:go_router/go_router.dart';

import '../features/challenge/challenge_detail_screen.dart';
import '../features/challenge/completion_reaction_screen.dart';
import '../features/gains/gain_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';

/// 앱 인스턴스마다 새 라우터를 만든다 (테스트 격리를 위해 전역 상태 금지).
///
/// 라우트는 홈을 루트로 중첩한다. 이렇게 해야 하위 화면으로 갈 때는
/// push(오른쪽에서 등장), 뒤로 갈 때는 pop(오른쪽으로 퇴장 + 이전 화면이
/// 왼쪽에서 복귀) 애니메이션이 방향에 맞게 적용된다.
GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'map',
            builder: (context, state) => const MapScreen(),
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
    ],
  );
}
