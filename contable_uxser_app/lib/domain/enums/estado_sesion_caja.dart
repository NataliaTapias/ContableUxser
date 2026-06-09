enum EstadoSesionCaja {
  abierta,
  cerrada;

  String get displayName {
    switch (this) {
      case EstadoSesionCaja.abierta:
        return 'Abierta';
      case EstadoSesionCaja.cerrada:
        return 'Cerrada';
    }
  }
}
