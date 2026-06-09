import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class AperturaCajaPage extends ConsumerStatefulWidget {
  const AperturaCajaPage({super.key});

  @override
  ConsumerState<AperturaCajaPage> createState() => _AperturaCajaPageState();
}

class _AperturaCajaPageState extends ConsumerState<AperturaCajaPage> {
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();

  @override
  void dispose() {
    _valorCtrl.dispose();
    super.dispose();
  }

  Future<void> _abrirCaja() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Call repository
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apertura de Caja')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, size: 80, color: AppColors.success),
                const SizedBox(height: 24),
                Text(
                  'Apertura de Caja',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingrese el valor inicial en efectivo',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _valorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Valor de apertura',
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
                  onPressed: _abrirCaja,
                  icon: const Icon(Icons.check),
                  label: const Text('Abrir Caja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
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
