import 'package:go_router/go_router.dart';

import '../features/challenge/challenge_detail_screen.dart';
import '../features/challenge/completion_reaction_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';

/// 앱 인스턴스마다 새 라우터를 만든다 (테스트 격리를 위해 전역 상태 금지).
GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
      GoRoute(
        path: '/challenge/:id',
        builder: (context, state) =>
            ChallengeDetailScreen(challengeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/challenge/:id/reaction',
        builder: (context, state) =>
            CompletionReactionScreen(challengeId: state.pathParameters['id']!),
      ),
    ],
  );
}
