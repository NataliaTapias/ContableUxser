import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';

class CierreCajaPage extends ConsumerStatefulWidget {
  const CierreCajaPage({super.key});

  @override
  ConsumerState<CierreCajaPage> createState() => _CierreCajaPageState();
}

class _CierreCajaPageState extends ConsumerState<CierreCajaPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _cerrarCaja() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Cierre'),
        content: Text(
          'Va a cerrar la caja con un valor real de ${formatCurrency(double.parse(_valorCtrl.text))}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar Cierre'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de Caja')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payments, size: 80, color: AppColors.warning),
                const SizedBox(height: 24),
                Text(
                  'Cierre de Caja',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingrese el valor real en efectivo',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _valorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Valor real en efectivo',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Ingrese un valor';
                    if (double.tryParse(v!) == null) return 'Valor inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _cerrarCaja,
                  icon: const Icon(Icons.lock),
                  label: const Text('Cerrar Caja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
