import '../entities/venta.dart';

abstract class VentaRepository {
  Stream<List<Venta>> watchVentasPendientes();
  Future<List<Venta>> getVentasPendientes();
  Future<void> saveVentaLocal(Venta venta);
  Future<void> marcarSincronizada(String ventaId);
  Future<int> syncVentasPendientes();
}
