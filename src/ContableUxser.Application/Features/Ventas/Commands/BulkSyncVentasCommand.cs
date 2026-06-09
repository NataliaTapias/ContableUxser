using ContableUxser.Application.Common;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Entities;
using ContableUxser.Domain.Enums;
using ContableUxser.Domain.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace ContableUxser.Application.Features.Ventas.Commands;

public record BulkSyncVentasCommand(
    List<CreateVentaCommand> Ventas
) : IRequest<BaseResponse<int>>;

public class BulkSyncVentasCommandHandler : IRequestHandler<BulkSyncVentasCommand, BaseResponse<int>>
{
    private readonly IApplicationDbContext _context;
    private readonly ITenantProvider _tenant;

    public BulkSyncVentasCommandHandler(IApplicationDbContext context, ITenantProvider tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    public async Task<BaseResponse<int>> Handle(BulkSyncVentasCommand request, CancellationToken cancellationToken)
    {
        using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

        try
        {
            var sincronizadas = 0;

            foreach (var cmd in request.Ventas)
            {
                var venta = new Venta
                {
                    EmpresaId = _tenant.EmpresaId,
                    SesionCajaId = cmd.SesionCajaId,
                    UsuarioId = _tenant.UsuarioId,
                    FechaVenta = DateTime.UtcNow,
                    Total = cmd.Total,
                    MetodoPago = (MetodoPago)cmd.MetodoPago,
                    ReferenciaTransferencia = cmd.ReferenciaTransferencia,
                    SincronizadoNube = true
                };

                _context.Ventas.Add(venta);
                await _context.SaveChangesAsync(cancellationToken);

                foreach (var detalle in cmd.Detalles)
                {
                    var producto = await _context.Productos.FindAsync(detalle.ProductoId);
                    if (producto == null) continue;

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
                        Notas = $"Sincronización offline - Venta #{venta.Id}"
                    });
                }

                sincronizadas++;
            }

            await _context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);

            return BaseResponse<int>.Success(sincronizadas, $"{sincronizadas} ventas sincronizadas exitosamente");
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }
}
