import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../domain/entities/producto.dart';

class ProductosPage extends ConsumerStatefulWidget {
  const ProductosPage({super.key});

  @override
  ConsumerState<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends ConsumerState<ProductosPage> {
  final _productos = [
    Producto(id: '1', empresaId: '1', codigoBarras: '75010001', nombre: 'Arroz Diana x1kg', costoPromedio: 2800, precioVenta: 3200, stockActual: 50, stockMinimo: 10),
    Producto(id: '2', empresaId: '1', codigoBarras: '75010002', nombre: 'Aceite Gourmet x900ml', costoPromedio: 8500, precioVenta: 9800, stockActual: 20, stockMinimo: 5),
    Producto(id: '3', empresaId: '1', codigoBarras: '75010003', nombre: 'Pan Bimbo Grande', costoPromedio: 4200, precioVenta: 5200, stockActual: 15, stockMinimo: 8),
    Producto(id: '4', empresaId: '1', codigoBarras: '75010004', nombre: 'Leche Colanta x1L', costoPromedio: 3100, precioVenta: 3800, stockActual: 30, stockMinimo: 12),
    Producto(id: '5', empresaId: '1', codigoBarras: '75010005', nombre: 'Huevos Santa Reyes x30', costoPromedio: 12000, precioVenta: 14500, stockActual: 10, stockMinimo: 3),
    Producto(id: '6', empresaId: '1', codigoBarras: '75010006', nombre: 'Jabón Ariel x500g', costoPromedio: 4500, precioVenta: 5600, stockActual: 25, stockMinimo: 6),
    Producto(id: '7', empresaId: '1', codigoBarras: '75010007', nombre: 'Coca-Cola x2L', costoPromedio: 4200, precioVenta: 5000, stockActual: 40, stockMinimo: 15),
    Producto(id: '8', empresaId: '1', codigoBarras: '75010008', nombre: 'Papel Higiénico x4', costoPromedio: 3800, precioVenta: 4800, stockActual: 18, stockMinimo: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showProductForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productos.length,
      itemBuilder: (context, index) {
        final p = _productos[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: p.stockBajo ? Colors.red.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
              child: Icon(p.stockBajo ? Icons.warning_amber : Icons.inventory_2, size: 20),
            ),
            title: Text(p.nombre),
            subtitle: Text('Cód: ${p.codigoBarras} • Stock: ${p.stockActual.toStringAsFixed(1)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatCurrency(p.precioVenta), style: const TextStyle(fontWeight: FontWeight.bold)),
                if (p.stockBajo)
                  const Text('STOCK BAJO', style: TextStyle(color: Colors.red, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ProductoForm(),
    );
  }
}

class _ProductoForm extends StatefulWidget {
  const _ProductoForm();

  @override
  State<_ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<_ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _stockMinCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _costoCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _stockMinCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nuevo Producto',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código de barras *',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costoCtrl,
                      decoration: const InputDecoration(labelText: 'Costo'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      decoration: const InputDecoration(labelText: 'Precio venta *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock actual'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockMinCtrl,
                      decoration: const InputDecoration(labelText: 'Stock mínimo'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ubicacionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
