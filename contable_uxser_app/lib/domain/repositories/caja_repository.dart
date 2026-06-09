import '../entities/sesion_caja.dart';

abstract class CajaRepository {
  Future<SesionCaja> abrirCaja(double valorApertura);
  Future<SesionCaja> cerrarCaja(String sesionId, double valorCierreReal);
  Future<SesionCaja?> getSesionAbierta();
  Future<String?> getSesionActivaId();
}
