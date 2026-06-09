import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  @override
  Future<User> login(String email, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final datos = data['datos'] as Map<String, dynamic>;
    final token = datos['token'] as String;
    final usuarioJson = datos['usuario'] as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.usuarioIdKey, usuarioJson['id'] as String);
    await prefs.setString(AppConstants.usuarioNombreKey, usuarioJson['nombre'] as String);
    await prefs.setString(AppConstants.usuarioRolKey, usuarioJson['rol'] as String);
    await prefs.setString(AppConstants.usuarioEmailKey, usuarioJson['email'] as String);

    return UserModel.fromJson(usuarioJson).toEntity();
  }

  @override
  Future<void> register(String email, String password, String nombre) async {
    await _dioClient.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'nombre': nombre,
      },
    );
  }

  @override
  Future<void> registerEmpresa(String empresaNombre, String nit, String nombre, String email, String password) async {
    await _dioClient.post(
      ApiConstants.registerEmpresa,
      data: {
        'empresaNombre': empresaNombre,
        'nit': nit,
        'nombre': nombre,
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.empresaIdKey);
    await prefs.remove(AppConstants.usuarioIdKey);
    await prefs.remove(AppConstants.usuarioNombreKey);
    await prefs.remove(AppConstants.usuarioEmailKey);
    await prefs.remove(AppConstants.usuarioRolKey);
    await prefs.remove(AppConstants.sesionCajaIdKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey) != null;
  }

  @override
  String? getToken() {
    return null;
  }

  Future<String?> getTokenAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  @override
  String? getEmpresaId() {
    return null;
  }

  @override
  String? getUsuarioId() {
    return null;
  }

  Future<String?> getUsuarioIdAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.usuarioIdKey);
  }

  Future<String?> getUsuarioNombreAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.usuarioNombreKey);
  }

  Future<String?> getUsuarioEmailAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.usuarioEmailKey);
  }

  Future<String?> getUsuarioRolAsync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.usuarioRolKey);
  }
}
