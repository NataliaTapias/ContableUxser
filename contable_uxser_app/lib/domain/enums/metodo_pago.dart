enum MetodoPago {
  efectivo,
  transferencia;

  String get displayName {
    switch (this) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.transferencia:
        return 'Transferencia';
    }
  }
}
