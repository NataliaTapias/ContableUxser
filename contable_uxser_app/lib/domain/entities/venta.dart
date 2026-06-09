import '../enums/metodo_pago.dart';

class Venta {
  final String id;
  final String empresaId;
  final String sesionCajaId;
  final String usuarioId;
  final DateTime fechaVenta;
  final double total;
  final MetodoPago metodoPago;
  final String? referenciaTransferencia;
  final bool sincronizadoNube;
  final List<VentaDetalle> detalles;

  Venta({
    required this.id,
    required this.empresaId,
    required this.sesionCajaId,
    required this.usuarioId,
    required this.fechaVenta,
    required this.total,
    required this.metodoPago,
    this.referenciaTransferencia,
    this.sincronizadoNube = false,
    this.detalles = const [],
  });
}

class VentaDetalle {
  final String id;
  final String ventaId;
  final String productoId;
  final String? productoNombre;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  VentaDetalle({
    required this.id,
    required this.ventaId,
    required this.productoId,
    this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });
}
