import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/sesion_caja.dart';
import '../../domain/enums/estado_sesion_caja.dart';
import '../../domain/repositories/caja_repository.dart';

class CajaRepositoryImpl implements CajaRepository {
  final DioClient _dioClient;

  CajaRepositoryImpl(this._dioClient);

  @override
  Future<SesionCaja> abrirCaja(double valorApertura) async {
    final response = await _dioClient.post(
      ApiConstants.cajaApertura,
      data: {'valorApertura': valorApertura},
    );

    final data = response.data as Map<String, dynamic>;
    final sesionId = data['datos'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.sesionCajaIdKey, sesionId);

    return SesionCaja(
      id: sesionId,
      empresaId: '',
      usuarioId: '',
      fechaApertura: DateTime.now(),
      valorApertura: valorApertura,
      estado: EstadoSesionCaja.abierta,
    );
  }

  @override
  Future<SesionCaja> cerrarCaja(String sesionId, double valorCierreReal) async {
    final response = await _dioClient.post(
      '${ApiConstants.cajaCierre}$sesionId',
      data: {'valorCierreReal': valorCierreReal},
    );

    final data = response.data as Map<String, dynamic>;
    final result = data['datos'] as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.sesionCajaIdKey);

    return SesionCaja(
      id: result['id'] as String,
      empresaId: '',
      usuarioId: '',
      fechaApertura: DateTime.now(),
      fechaCierre: DateTime.now(),
      valorApertura: (result['valorApertura'] as num).toDouble(),
      valorCierreReal: (result['valorCierreReal'] as num).toDouble(),
      valorCierreCalculado: (result['efectivoCalculado'] as num).toDouble(),
      diferencia: (result['diferencia'] as num).toDouble(),
      estado: EstadoSesionCaja.cerrada,
    );
  }

  @override
  Future<SesionCaja?> getSesionAbierta() async {
    final sesionId = await getSesionActivaId();
    if (sesionId == null) return null;

    // In a real scenario, we'd fetch from the API
    // For now, return basic info from local prefs
    return SesionCaja(
      id: sesionId,
      empresaId: '',
      usuarioId: '',
      fechaApertura: DateTime.now(),
      valorApertura: 0,
      estado: EstadoSesionCaja.abierta,
    );
  }

  @override
  Future<String?> getSesionActivaId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.sesionCajaIdKey);
  }
}
