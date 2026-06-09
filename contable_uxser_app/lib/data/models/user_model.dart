import '../../domain/entities/user.dart';
import '../../domain/enums/rol_usuario.dart';

class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String rol;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
    );
  }

  User toEntity() {
    return User(
      id: id,
      nombre: nombre,
      email: email,
      rol: RolUsuario.values.firstWhere((e) => e.name == rol.toLowerCase()),
    );
  }
}
