import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'di/injection_container.dart';
import 'presentation/auth/providers/auth_provider.dart';

class ContableUxserApp extends ConsumerStatefulWidget {
  const ContableUxserApp({super.key});

  @override
  ConsumerState<ContableUxserApp> createState() => _ContableUxserAppState();
}

class _ContableUxserAppState extends ConsumerState<ContableUxserApp> {
  @override
  void initState() {
    super.initState();
    InjectionContainer.syncService.startAutoSync();
  }

  @override
  void dispose() {
    InjectionContainer.syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState.valueOrNull != null;

    return MaterialApp.router(
      title: 'ContableUxser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(isAuthenticated),
    );
  }
}
