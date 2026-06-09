enum RolUsuario {
  administrador,
  cajero;

  String get displayName {
    switch (this) {
      case RolUsuario.administrador:
        return 'Administrador';
      case RolUsuario.cajero:
        return 'Cajero';
    }
  }
}
