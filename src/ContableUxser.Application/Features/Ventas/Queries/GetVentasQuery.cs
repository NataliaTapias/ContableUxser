using ContableUxser.Application.Common;
using MediatR;

namespace ContableUxser.Application.Features.Ventas.Queries;

public record GetVentasQuery(
    int Pagina = 1,
    int TamanoPagina = 20,
    Guid? SesionCajaId = null,
    DateTime? Desde = null,
    DateTime? Hasta = null
) : IRequest<BaseResponse<PagedResult<VentaDto>>>;

public record VentaDto(
    Guid Id,
    DateTime FechaVenta,
    decimal Total,
    string MetodoPago,
    string? ReferenciaTransferencia,
    string UsuarioNombre,
    bool SincronizadoNube,
    List<VentaDetalleDto> Detalles
);

public record VentaDetalleDto(
    Guid Id,
    string ProductoNombre,
    decimal Cantidad,
    decimal PrecioUnitario,
    decimal Subtotal
);
