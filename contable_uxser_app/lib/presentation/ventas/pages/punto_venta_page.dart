import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../domain/entities/producto.dart';
import '../../../domain/enums/metodo_pago.dart';

class PuntoVentaPage extends ConsumerStatefulWidget {
  const PuntoVentaPage({super.key});

  @override
  ConsumerState<PuntoVentaPage> createState() => _PuntoVentaPageState();
}

class _PuntoVentaPageState extends ConsumerState<PuntoVentaPage> {
  final _carrito = <_ItemCarrito>[];
  final _searchController = TextEditingController();
  MetodoPago _metodoPago = MetodoPago.efectivo;
  final _referenciaCtrl = TextEditingController();
  String _searchQuery = '';

  final _productosMock = [
    Producto(id: '1', empresaId: '1', codigoBarras: '75010001', nombre: 'Arroz Diana x1kg', costoPromedio: 2800, precioVenta: 3200, stockActual: 50, stockMinimo: 10),
    Producto(id: '2', empresaId: '1', codigoBarras: '75010002', nombre: 'Aceite Gourmet x900ml', costoPromedio: 8500, precioVenta: 9800, stockActual: 20, stockMinimo: 5),
    Producto(id: '3', empresaId: '1', codigoBarras: '75010003', nombre: 'Pan Bimbo Grande', costoPromedio: 4200, precioVenta: 5200, stockActual: 15, stockMinimo: 8),
    Producto(id: '4', empresaId: '1', codigoBarras: '75010004', nombre: 'Leche Colanta x1L', costoPromedio: 3100, precioVenta: 3800, stockActual: 30, stockMinimo: 12),
    Producto(id: '5', empresaId: '1', codigoBarras: '75010005', nombre: 'Huevos Santa Reyes x30', costoPromedio: 12000, precioVenta: 14500, stockActual: 10, stockMinimo: 3),
    Producto(id: '6', empresaId: '1', codigoBarras: '75010006', nombre: 'Jabón Ariel x500g', costoPromedio: 4500, precioVenta: 5600, stockActual: 25, stockMinimo: 6),
    Producto(id: '7', empresaId: '1', codigoBarras: '75010007', nombre: 'Coca-Cola x2L', costoPromedio: 4200, precioVenta: 5000, stockActual: 40, stockMinimo: 15),
    Producto(id: '8', empresaId: '1', codigoBarras: '75010008', nombre: 'Papel Higiénico x4', costoPromedio: 3800, precioVenta: 4800, stockActual: 18, stockMinimo: 5),
  ];

  double get _subtotal =>
      _carrito.fold(0, (sum, item) => sum + item.subtotal);

  double get _total => _subtotal;

  void _removerItem(int index) {
    setState(() => _carrito.removeAt(index));
  }

  Future<void> _finalizarVenta() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue productos al carrito')),
      );
      return;
    }

    if (_metodoPago == MetodoPago.transferencia &&
        _referenciaCtrl.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese los últimos 4 dígitos del comprobante')),
      );
      return;
    }

    // TODO: Save venta locally and sync
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _referenciaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
      ),
      body: Row(
        children: [
          // Left side: Products
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o código de barras...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () {},
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  ),
                ),
                Expanded(
                  child: _buildProductList(),
                ),
              ],
            ),
          ),
          // Right side: Cart
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(left: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  Expanded(child: _buildCartList()),
                  _buildPaymentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    final filtered = _productosMock.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.nombre.toLowerCase().contains(_searchQuery) ||
          p.codigoBarras.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('Sin resultados', style: TextStyle(color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final p = filtered[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.inventory_2, size: 20),
            ),
            title: Text(p.nombre, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              'Cód: ${p.codigoBarras} • Stock: ${p.stockActual.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatCurrency(p.precioVenta),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (p.stockBajo)
                  const Text('STOCK BAJO',
                      style: TextStyle(color: Colors.red, fontSize: 9)),
              ],
            ),
            onTap: () => _agregarProducto(p),
          ),
        );
      },
    );
  }

  void _agregarProducto(Producto producto) {
    setState(() {
      final idx = _carrito.indexWhere((i) => i.producto.id == producto.id);
      if (idx >= 0) {
        final item = _carrito[idx];
        _carrito[idx] = _ItemCarrito(
          producto: item.producto,
          cantidad: item.cantidad + 1,
        );
      } else {
        _carrito.add(_ItemCarrito(producto: producto, cantidad: 1));
      }
    });
  }

  Widget _buildCartList() {
    if (_carrito.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Carrito vacío', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _carrito.length,
      itemBuilder: (context, index) {
        final item = _carrito[index];
        return Card(
          child: ListTile(
            title: Text(item.producto.nombre, maxLines: 1),
            subtitle: Text('${formatCurrency(item.producto.precioVenta)} x ${item.cantidad}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(item.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                  onPressed: () => _removerItem(index),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(formatCurrency(_total),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MetodoPago>(
            initialValue: _metodoPago,
            decoration: const InputDecoration(labelText: 'Método de pago'),
            items: MetodoPago.values.map((m) {
              return DropdownMenuItem(value: m, child: Text(m.displayName));
            }).toList(),
            onChanged: (v) => setState(() => _metodoPago = v!),
          ),
          if (_metodoPago == MetodoPago.transferencia) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _referenciaCtrl,
              decoration: const InputDecoration(
                labelText: 'Últimos 4 dígitos del comprobante',
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _finalizarVenta,
            icon: const Icon(Icons.check),
            label: const Text('Finalizar Venta'),
          ),
        ],
      ),
    );
  }
}

class _ItemCarrito {
  final Producto producto;
  final double cantidad;

  _ItemCarrito({required this.producto, required this.cantidad});

  double get subtotal => producto.precioVenta * cantidad;
}
