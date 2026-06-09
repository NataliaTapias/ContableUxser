using ContableUxser.Application.Common;
using MediatR;

namespace ContableUxser.Application.Features.Ventas.Commands;

public record CreateVentaCommand(
    Guid SesionCajaId,
    decimal Total,
    int MetodoPago,
    string? ReferenciaTransferencia,
    bool SincronizadoNube,
    List<CreateVentaDetalleDto> Detalles
) : IRequest<BaseResponse<Guid>>;

public record CreateVentaDetalleDto(
    Guid ProductoId,
    decimal Cantidad,
    decimal PrecioUnitario,
    decimal Subtotal
);
