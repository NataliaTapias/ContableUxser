using ContableUxser.Application.Common;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Entities;
using ContableUxser.Domain.Enums;
using ContableUxser.Domain.Interfaces;
using MediatR;

namespace ContableUxser.Application.Features.Ventas.Commands;

public class CreateVentaCommandHandler : IRequestHandler<CreateVentaCommand, BaseResponse<Guid>>
{
    private readonly IApplicationDbContext _context;
    private readonly ITenantProvider _tenant;

    public CreateVentaCommandHandler(IApplicationDbContext context, ITenantProvider tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    public async Task<BaseResponse<Guid>> Handle(CreateVentaCommand request, CancellationToken cancellationToken)
    {
        using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

        try
        {
            var venta = new Venta
            {
                EmpresaId = _tenant.EmpresaId,
                SesionCajaId = request.SesionCajaId,
                UsuarioId = _tenant.UsuarioId,
                Total = request.Total,
                MetodoPago = (MetodoPago)request.MetodoPago,
                ReferenciaTransferencia = request.ReferenciaTransferencia,
                SincronizadoNube = request.SincronizadoNube
            };

            _context.Ventas.Add(venta);
            await _context.SaveChangesAsync(cancellationToken);

            foreach (var detalle in request.Detalles)
            {
                var producto = await _context.Productos.FindAsync(detalle.ProductoId);
                if (producto == null)
                    return BaseResponse<Guid>.Failure($"Producto {detalle.ProductoId} no encontrado");

                producto.StockActual -= detalle.Cantidad;

                _context.VentaDetalles.Add(new VentaDetalle
                {
                    VentaId = venta.Id,
                    ProductoId = detalle.ProductoId,
                    Cantidad = detalle.Cantidad,
                    PrecioUnitario = detalle.PrecioUnitario,
                    Subtotal = detalle.Subtotal
                });

                _context.MovimientosInventario.Add(new MovimientoInventario
                {
                    EmpresaId = _tenant.EmpresaId,
                    ProductoId = detalle.ProductoId,
                    TipoMovimiento = TipoMovimiento.Venta,
                    Cantidad = detalle.Cantidad,
                    CostoUnitario = producto.CostoPromedio,
                    Notas = $"Venta #{venta.Id}"
                });
            }

            await _context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            return BaseResponse<Guid>.Success(venta.Id, "Venta registrada exitosamente");
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }
}
