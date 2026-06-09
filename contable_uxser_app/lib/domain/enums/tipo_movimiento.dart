enum TipoMovimiento {
  entradaCompra,
  venta,
  ajustePerdida;

  String get displayName {
    switch (this) {
      case TipoMovimiento.entradaCompra:
        return 'Entrada por Compra';
      case TipoMovimiento.venta:
        return 'Venta';
      case TipoMovimiento.ajustePerdida:
        return 'Ajuste por Pérdida';
    }
  }
}
