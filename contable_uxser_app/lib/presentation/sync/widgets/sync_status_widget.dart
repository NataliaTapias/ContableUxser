import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class SyncStatusWidget extends ConsumerStatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  ConsumerState<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends ConsumerState<SyncStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sincronización',
      child: IconButton(
        icon: const Icon(
          Icons.sync,
          color: AppColors.success,
        ),
        onPressed: () {},
      ),
    );
  }
}
