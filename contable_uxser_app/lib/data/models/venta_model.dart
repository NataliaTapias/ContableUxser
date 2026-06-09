import '../../domain/entities/venta.dart';
import '../../domain/enums/metodo_pago.dart';

class VentaModel {
  final String id;
  final String empresaId;
  final String sesionCajaId;
  final String usuarioId;
  final DateTime fechaVenta;
  final double total;
  final String metodoPago;
  final String? referenciaTransferencia;
  final bool sincronizadoNube;
  final List<VentaDetalleModel> detalles;

  VentaModel({
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

  factory VentaModel.fromEntity(Venta venta) {
    return VentaModel(
      id: venta.id,
      empresaId: venta.empresaId,
      sesionCajaId: venta.sesionCajaId,
      usuarioId: venta.usuarioId,
      fechaVenta: venta.fechaVenta,
      total: venta.total,
      metodoPago: venta.metodoPago.name,
      referenciaTransferencia: venta.referenciaTransferencia,
      sincronizadoNube: false,
      detalles: venta.detalles
          .map((d) => VentaDetalleModel.fromEntity(d))
          .toList(),
    );
  }

  Map<String, dynamic> toLocalDb() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'sesion_caja_id': sesionCajaId,
      'usuario_id': usuarioId,
      'fecha_venta': fechaVenta.toIso8601String(),
      'total': total,
      'metodo_pago': metodoPago,
      'referencia_transferencia': referenciaTransferencia,
      'sincronizado_nube': sincronizadoNube ? 1 : 0,
    };
  }

  factory VentaModel.fromLocalDb(Map<String, dynamic> map, List<Map<String, dynamic>> detallesMap) {
    return VentaModel(
      id: map['id'] as String,
      empresaId: map['empresa_id'] as String,
      sesionCajaId: map['sesion_caja_id'] as String,
      usuarioId: map['usuario_id'] as String,
      fechaVenta: DateTime.parse(map['fecha_venta'] as String),
      total: (map['total'] as num).toDouble(),
      metodoPago: map['metodo_pago'] as String,
      referenciaTransferencia: map['referencia_transferencia'] as String?,
      sincronizadoNube: (map['sincronizado_nube'] as int) == 1,
      detalles: detallesMap.map((d) => VentaDetalleModel.fromLocalDb(d)).toList(),
    );
  }

  Venta toEntity() {
    return Venta(
      id: id,
      empresaId: empresaId,
      sesionCajaId: sesionCajaId,
      usuarioId: usuarioId,
      fechaVenta: fechaVenta,
      total: total,
      metodoPago: MetodoPago.values.firstWhere((m) => m.name == metodoPago),
      referenciaTransferencia: referenciaTransferencia,
      detalles: detalles.map((d) => d.toEntity(ventaId: id)).toList(),
    );
  }
}

class VentaDetalleModel {
  final String id;
  final String ventaId;
  final String productoId;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  VentaDetalleModel({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory VentaDetalleModel.fromEntity(VentaDetalle detalle) {
    return VentaDetalleModel(
      id: detalle.id,
      ventaId: detalle.ventaId,
      productoId: detalle.productoId,
      cantidad: detalle.cantidad,
      precioUnitario: detalle.precioUnitario,
      subtotal: detalle.subtotal,
    );
  }

  factory VentaDetalleModel.fromLocalDb(Map<String, dynamic> map) {
    return VentaDetalleModel(
      id: map['id'] as String,
      ventaId: map['venta_id'] as String,
      productoId: map['producto_id'] as String,
      cantidad: (map['cantidad'] as num).toDouble(),
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  VentaDetalle toEntity({String? ventaId}) {
    return VentaDetalle(
      id: id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      subtotal: subtotal,
    );
  }
}
