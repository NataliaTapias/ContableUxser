import 'package:sqflite/sqflite.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/producto_repository.dart';
import '../database/local_database.dart';
import '../models/producto_model.dart';
import 'dart:async';

class ProductoRepositoryImpl implements ProductoRepository {
  final DioClient _dioClient;

  ProductoRepositoryImpl(this._dioClient);

  @override
  Stream<List<Producto>> watchProductos() {
    final controller = StreamController<List<Producto>>();

    _emitProductos(controller);

    timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _emitProductos(controller);
    });

    controller.onCancel = () => timer?.cancel();

    return controller.stream;
  }

  Timer? timer;

  Future<void> _emitProductos(StreamController<List<Producto>> controller) async {
    try {
      final productos = await getProductos();
      controller.add(productos);
    } catch (_) {}
  }

  @override
  Future<List<Producto>> getProductos({bool? stockBajo}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (stockBajo == true) {
        queryParams['stockBajo'] = true;
      }
      final response = await _dioClient.get(
        ApiConstants.productos,
        queryParameters: queryParams,
      );
      final data = response.data as Map<String, dynamic>;
      final list = (data['datos'] as List)
          .map((e) => ProductoModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      await _cacheProductosLocal(list);
      return list;
    } catch (_) {
      return _getProductosLocales(stockBajo: stockBajo);
    }
  }

  @override
  Future<Producto?> getProducto(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.productosById}$id');
      final data = response.data as Map<String, dynamic>;
      return ProductoModel.fromJson(data['datos'] as Map<String, dynamic>).toEntity();
    } catch (_) {
      final db = await LocalDatabase.instance;
      final maps = await db.query('productos', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return ProductoModel.fromLocalDb(maps.first).toEntity();
    }
  }

  @override
  Future<Producto?> getProductoByCodigo(String codigoBarras) async {
    try {
      final productos = await getProductos();
      return productos.where((p) => p.codigoBarras == codigoBarras).firstOrNull;
    } catch (_) {
      final db = await LocalDatabase.instance;
      final maps = await db.query(
        'productos',
        where: 'codigo_barras = ?',
        whereArgs: [codigoBarras],
      );
      if (maps.isEmpty) return null;
      return ProductoModel.fromLocalDb(maps.first).toEntity();
    }
  }

  @override
  Future<void> saveProducto(Producto producto) async {
    final db = await LocalDatabase.instance;
    final model = ProductoModel.fromEntity(producto);
    await db.insert(
      'productos',
      model.toLocalDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateProducto(Producto producto) async {
    await saveProducto(producto);
  }

  @override
  Future<void> syncProductos(List<Producto> productos) async {
    final db = await LocalDatabase.instance;
    final batch = db.batch();

    for (final producto in productos) {
      final model = ProductoModel.fromEntity(producto);
      batch.insert('productos', model.toLocalDb(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<List<Producto>> _getProductosLocales({bool? stockBajo}) async {
    final db = await LocalDatabase.instance;
    final where = stockBajo == true ? 'stock_actual <= stock_minimo' : null;
    final maps = await db.query('productos', where: where);
    return maps.map((m) => ProductoModel.fromLocalDb(m).toEntity()).toList();
  }

  Future<void> _cacheProductosLocal(List<Producto> productos) async {
    final db = await LocalDatabase.instance;
    final batch = db.batch();
    batch.delete('productos');

    for (final producto in productos) {
      final model = ProductoModel.fromEntity(producto);
      batch.insert('productos', model.toLocalDb(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }
}
