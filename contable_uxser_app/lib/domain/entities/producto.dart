class Producto {
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

  Producto({
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

  bool get stockBajo => stockActual <= stockMinimo;
}
