import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/dashboard/pages/dashboard_page.dart';
import '../../presentation/ventas/pages/punto_venta_page.dart';
import '../../presentation/productos/pages/productos_page.dart';
import '../../presentation/caja/pages/apertura_caja_page.dart';
import '../../presentation/caja/pages/cierre_caja_page.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigator = GlobalKey<NavigatorState>();

  static GoRouter router(bool isAuthenticated) {
    return GoRouter(
      navigatorKey: _rootNavigator,
      initialLocation: isAuthenticated ? '/dashboard' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/ventas',
          builder: (context, state) => const PuntoVentaPage(),
        ),
        GoRoute(
          path: '/productos',
          builder: (context, state) => const ProductosPage(),
        ),
        GoRoute(
          path: '/caja/apertura',
          builder: (context, state) => const AperturaCajaPage(),
        ),
        GoRoute(
          path: '/caja/cierre',
          builder: (context, state) => const CierreCajaPage(),
        ),
      ],
    );
  }
}
