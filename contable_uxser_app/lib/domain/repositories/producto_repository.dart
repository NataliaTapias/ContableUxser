import '../entities/producto.dart';

abstract class ProductoRepository {
  Stream<List<Producto>> watchProductos();
  Future<List<Producto>> getProductos({bool? stockBajo});
  Future<Producto?> getProducto(String id);
  Future<Producto?> getProductoByCodigo(String codigoBarras);
  Future<void> saveProducto(Producto producto);
  Future<void> updateProducto(Producto producto);
  Future<void> syncProductos(List<Producto> productos);
}
