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
      ),
      routerConfig: _router,
    );
  }
}
