import '../enums/rol_usuario.dart';

class User {
  final String id;
  final String nombre;
  final String email;
  final RolUsuario rol;

  const User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });
}
