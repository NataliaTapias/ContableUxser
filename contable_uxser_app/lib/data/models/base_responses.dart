class BaseResponse {
  final bool exitoso;
  final String? mensaje;
  final dynamic datos;
  final List<String> errores;

  BaseResponse({
    required this.exitoso,
    this.mensaje,
    this.datos,
    this.errores = const [],
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      exitoso: json['exitoso'] ?? false,
      mensaje: json['mensaje'],
      datos: json['datos'],
      errores: List<String>.from(json['errores'] ?? []),
    );
  }
}

class PagedResponse<T> {
  final List<T> items;
  final int total;
  final int pagina;
  final int tamanoPagina;

  PagedResponse({
    required this.items,
    required this.total,
    required this.pagina,
    required this.tamanoPagina,
  });

  int get totalPaginas => (total / tamanoPagina).ceil();
}
