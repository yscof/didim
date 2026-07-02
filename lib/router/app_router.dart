import 'package:go_router/go_router.dart';

import '../features/latte_factor/presentation/act_screen.dart';
import '../features/latte_factor/presentation/engage_screen.dart';
import '../features/latte_factor/presentation/investigate_screen.dart';
import '../features/latte_factor/presentation/reflect_screen.dart';

/// CBL 흐름을 따르는 라우트: Engage → Investigate → Act → Reflect.
final appRouter = GoRouter(
  initialLocation: '/engage',
  routes: [
    GoRoute(
      path: '/engage',
      builder: (context, state) => const EngageScreen(),
    ),
    GoRoute(
      path: '/investigate',
      builder: (context, state) => const InvestigateScreen(),
    ),
    GoRoute(
      path: '/act',
      builder: (context, state) => const ActScreen(),
    ),
    GoRoute(
      path: '/reflect',
      builder: (context, state) => const ReflectScreen(),
    ),
  ],
);
