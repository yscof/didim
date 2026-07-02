import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 원화(ko_KR) 포맷팅에 필요한 로케일 데이터를 초기화한다.
  await initializeDateFormatting('ko_KR');
  runApp(const ProviderScope(child: DidimApp()));
}

class DidimApp extends StatelessWidget {
  const DidimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '디딤 · 라떼 팩터',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
