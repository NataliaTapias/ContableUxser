import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<void> register(String email, String password, String nombre);
  Future<void> registerEmpresa(String empresaNombre, String nit, String nombre, String email, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
  String? getToken();
  String? getEmpresaId();
  String? getUsuarioId();
}
