import '../../domain/entities/producto.dart';

class ProductoModel {
  final String id;
  final String empresaId;
  final String codigoBarras;
  final String nombre;
  final double costoPromedio;
  final double precioVenta;
  final double stockActual;
  final double stockMinimo;
  final String? ubicacion;
  final String? imagenUrl;

  ProductoModel({
    required this.id,
    required this.empresaId,
    required this.codigoBarras,
    required this.nombre,
    required this.costoPromedio,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    this.ubicacion,
    this.imagenUrl,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'] as String,
      empresaId: json['empresaId'] as String? ?? '',
      codigoBarras: json['codigoBarras'] as String,
      nombre: json['nombre'] as String,
      costoPromedio: (json['costoPromedio'] as num).toDouble(),
      precioVenta: (json['precioVenta'] as num).toDouble(),
      stockActual: (json['stockActual'] as num).toDouble(),
      stockMinimo: (json['stockMinimo'] as num).toDouble(),
      ubicacion: json['ubicacion'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,
      'codigoBarras': codigoBarras,
      'nombre': nombre,
      'costoPromedio': costoPromedio,
      'precioVenta': precioVenta,
      'stockActual': stockActual,
      'stockMinimo': stockMinimo,
      'ubicacion': ubicacion,
      'imagenUrl': imagenUrl,
    };
  }

  Map<String, dynamic> toLocalDb() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'codigo_barras': codigoBarras,
      'nombre': nombre,
      'costo_promedio': costoPromedio,
      'precio_venta': precioVenta,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'ubicacion': ubicacion,
    };
  }

  factory ProductoModel.fromLocalDb(Map<String, dynamic> map) {
    return ProductoModel(
      id: map['id'] as String,
      empresaId: map['empresa_id'] as String? ?? '',
      codigoBarras: map['codigo_barras'] as String,
      nombre: map['nombre'] as String,
      costoPromedio: (map['costo_promedio'] as num).toDouble(),
      precioVenta: (map['precio_venta'] as num).toDouble(),
      stockActual: (map['stock_actual'] as num).toDouble(),
      stockMinimo: (map['stock_minimo'] as num).toDouble(),
      ubicacion: map['ubicacion'] as String?,
    );
  }

  Producto toEntity() {
    return Producto(
      id: id,
      empresaId: empresaId,
      codigoBarras: codigoBarras,
      nombre: nombre,
      costoPromedio: costoPromedio,
      precioVenta: precioVenta,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      ubicacion: ubicacion,
      imagenUrl: imagenUrl,
    );
  }

  factory ProductoModel.fromEntity(Producto entity) {
    return ProductoModel(
      id: entity.id,
      empresaId: entity.empresaId,
      codigoBarras: entity.codigoBarras,
      nombre: entity.nombre,
      costoPromedio: entity.costoPromedio,
      precioVenta: entity.precioVenta,
      stockActual: entity.stockActual,
      stockMinimo: entity.stockMinimo,
      ubicacion: entity.ubicacion,
      imagenUrl: entity.imagenUrl,
    );
  }
}
