import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/providers.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/enums/rol_usuario.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepositoryImpl _authRepository;

  AuthNotifier(this._authRepository) : super(const AsyncLoading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final authenticated = await _authRepository.isAuthenticated();
      if (authenticated) {
        final token = await _authRepository.getTokenAsync();
        if (token != null) {
          final nombre = await _authRepository.getUsuarioNombreAsync();
          final email = await _authRepository.getUsuarioEmailAsync();
          final rolStr = await _authRepository.getUsuarioRolAsync();
          final id = await _authRepository.getUsuarioIdAsync();
          state = AsyncData(User(
            id: id ?? '',
            nombre: nombre ?? '',
            email: email ?? '',
            rol: _parseRol(rolStr),
          ));
          return;
        }
      }
      state = const AsyncData(null);
    } catch (_) {
      state = const AsyncData(null);
    }
  }

  RolUsuario _parseRol(String? rol) {
    switch (rol?.toLowerCase()) {
      case 'administrador':
        return RolUsuario.administrador;
      case 'cajero':
        return RolUsuario.cajero;
      default:
        return RolUsuario.cajero;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _authRepository.login(email, password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepo);
});
