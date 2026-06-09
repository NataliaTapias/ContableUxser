import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/venta.dart';
import '../../domain/repositories/venta_repository.dart';
import '../database/local_database.dart';
import '../models/venta_model.dart';

class VentaRepositoryImpl implements VentaRepository {
  final DioClient _dioClient;

  VentaRepositoryImpl(this._dioClient);

  @override
  Stream<List<Venta>> watchVentasPendientes() {
    return Stream.periodic(
      const Duration(seconds: 10),
      (_) => _getVentasPendientesLocales(),
    ).asyncMap((ventas) async => ventas);
  }

  @override
  Future<List<Venta>> getVentasPendientes() async {
    return _getVentasPendientesLocales();
  }

  @override
  Future<void> saveVentaLocal(Venta venta) async {
    final db = await LocalDatabase.instance;
    final ventaModel = VentaModel.fromEntity(venta);

    await db.transaction((txn) async {
      await txn.insert('ventas', ventaModel.toLocalDb());

      for (final detalle in venta.detalles) {
        await txn.insert('venta_detalles', {
          'id': detalle.id,
          'venta_id': detalle.ventaId,
          'producto_id': detalle.productoId,
          'cantidad': detalle.cantidad,
          'precio_unitario': detalle.precioUnitario,
          'subtotal': detalle.subtotal,
        });
      }
    });
  }

  @override
  Future<void> marcarSincronizada(String ventaId) async {
    final db = await LocalDatabase.instance;
    await db.update(
      'ventas',
      {'sincronizado_nube': 1},
      where: 'id = ?',
      whereArgs: [ventaId],
    );
  }

  @override
  Future<int> syncVentasPendientes() async {
    final db = await LocalDatabase.instance;
    final pendientes = await db.query(
      'ventas',
      where: 'sincronizado_nube = 0',
    );

    if (pendientes.isEmpty) return 0;

    var sincronizadas = 0;

    for (final row in pendientes) {
      try {
        final detallesMap = await db.query(
          'venta_detalles',
          where: 'venta_id = ?',
          whereArgs: [row['id']],
        );

        final request = {
          'sesionCajaId': row['sesion_caja_id'],
          'total': row['total'],
          'metodoPago': row['metodo_pago'] == 'efectivo' ? 0 : 1,
          'referenciaTransferencia': row['referencia_transferencia'],
          'sincronizadoNube': true,
          'detalles': detallesMap.map((d) => {
                'productoId': d['producto_id'],
                'cantidad': d['cantidad'],
                'precioUnitario': d['precio_unitario'],
                'subtotal': d['subtotal'],
              }).toList(),
        };

        await _dioClient.post(ApiConstants.ventas, data: request);
        await marcarSincronizada(row['id'] as String);
        sincronizadas++;
      } catch (_) {
        // Will retry next sync cycle
      }
    }

    return sincronizadas;
  }

  Future<List<Venta>> _getVentasPendientesLocales() async {
    try {
      final db = await LocalDatabase.instance;
      final rows = await db.query(
        'ventas',
        where: 'sincronizado_nube = 0',
      );
      final ventas = <Venta>[];

      for (final row in rows) {
        final detalles = await db.query(
          'venta_detalles',
          where: 'venta_id = ?',
          whereArgs: [row['id']],
        );
        final venta = VentaModel.fromLocalDb(row, detalles).toEntity();
        ventas.add(venta);
      }

      return ventas;
    } catch (_) {
      return [];
    }
  }
}
