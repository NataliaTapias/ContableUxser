using ContableUxser.Application.Common;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace ContableUxser.Application.Features.Ventas.Queries;

public class GetVentasQueryHandler : IRequestHandler<GetVentasQuery, BaseResponse<PagedResult<VentaDto>>>
{
    private readonly IApplicationDbContext _context;
    private readonly ITenantProvider _tenant;

    public GetVentasQueryHandler(IApplicationDbContext context, ITenantProvider tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    public async Task<BaseResponse<PagedResult<VentaDto>>> Handle(GetVentasQuery request, CancellationToken cancellationToken)
    {
        var query = _context.Ventas
            .Include(v => v.Usuario)
            .Include(v => v.VentaDetalles)
                .ThenInclude(d => d.Producto)
            .AsQueryable();

        if (request.SesionCajaId.HasValue)
            query = query.Where(v => v.SesionCajaId == request.SesionCajaId.Value);

        if (request.Desde.HasValue)
            query = query.Where(v => v.FechaVenta >= request.Desde.Value);

        if (request.Hasta.HasValue)
            query = query.Where(v => v.FechaVenta <= request.Hasta.Value);

        var total = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(v => v.FechaVenta)
            .Skip((request.Pagina - 1) * request.TamanoPagina)
            .Take(request.TamanoPagina)
            .Select(v => new VentaDto(
                v.Id,
                v.FechaVenta,
                v.Total,
                v.MetodoPago.ToString(),
                v.ReferenciaTransferencia,
                v.Usuario.Nombre,
                v.SincronizadoNube,
                v.VentaDetalles.Select(d => new VentaDetalleDto(
                    d.Id,
                    d.Producto.Nombre,
                    d.Cantidad,
                    d.PrecioUnitario,
                    d.Subtotal
                )).ToList()
            ))
            .ToListAsync(cancellationToken);

        return BaseResponse<PagedResult<VentaDto>>.Success(new PagedResult<VentaDto>
        {
            Items = items,
            Total = total,
            Pagina = request.Pagina,
            TamanoPagina = request.TamanoPagina
        });
    }
}
