import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerEmpresa = '/auth/register-empresa';

  static const String productos = '/productos';
  static const String productosById = '/productos/';

  static const String ventas = '/ventas';
  static const String ventasBulkSync = '/ventas/bulk-sync';

  static const String cajaApertura = '/caja/apertura';
  static const String cajaCierre = '/caja/cierre/';

  static const Duration timeout = Duration(seconds: 30);
  static const Duration syncTimeout = Duration(seconds: 60);
}
