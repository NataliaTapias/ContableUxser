import '../enums/estado_sesion_caja.dart';

class SesionCaja {
  final String id;
  final String empresaId;
  final String usuarioId;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final double valorApertura;
  final double? valorCierreReal;
  final double? valorCierreCalculado;
  final double? diferencia;
  final EstadoSesionCaja estado;

  SesionCaja({
    required this.id,
    required this.empresaId,
    required this.usuarioId,
    required this.fechaApertura,
    this.fechaCierre,
    required this.valorApertura,
    this.valorCierreReal,
    this.valorCierreCalculado,
    this.diferencia,
    required this.estado,
  });

  bool get estaAbierta => estado == EstadoSesionCaja.abierta;
}
