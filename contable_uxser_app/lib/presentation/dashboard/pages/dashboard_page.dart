import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../sync/widgets/sync_status_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ContableUxser'),
        actions: [
          const SyncStatusWidget(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    icon: Icons.point_of_sale,
                    label: 'Punto de Venta',
                    color: AppColors.primary,
                    onTap: () => context.push('/ventas'),
                  ),
                  _DashboardCard(
                    icon: Icons.inventory_2,
                    label: 'Productos',
                    color: AppColors.secondary,
                    onTap: () => context.push('/productos'),
                  ),
                  _DashboardCard(
                    icon: Icons.monetization_on,
                    label: 'Abrir Caja',
                    color: AppColors.success,
                    onTap: () => context.push('/caja/apertura'),
                  ),
                  _DashboardCard(
                    icon: Icons.payments,
                    label: 'Cerrar Caja',
                    color: AppColors.warning,
                    onTap: () => context.push('/caja/cierre'),
                  ),
                  _DashboardCard(
                    icon: Icons.assignment,
                    label: 'Historial',
                    color: Colors.purple,
                    onTap: () {},
                  ),
                  _DashboardCard(
                    icon: Icons.sync,
                    label: 'Sincronizar',
                    color: Colors.teal,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
