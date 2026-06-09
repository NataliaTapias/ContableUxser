using ContableUxser.Application.Common;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Entities;
using ContableUxser.Domain.Enums;
using ContableUxser.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ContableUxser.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProductosController : ControllerBase
{
    private readonly IApplicationDbContext _context;
    private readonly ITenantProvider _tenant;

    public ProductosController(IApplicationDbContext context, ITenantProvider tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? search, [FromQuery] bool? stockBajo)
    {
        var query = _context.Productos.AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
            query = query.Where(p =>
                p.Nombre.Contains(search) || p.CodigoBarras.Contains(search));

        if (stockBajo == true)
            query = query.Where(p => p.StockActual <= p.StockMinimo);

        var productos = await query
            .OrderBy(p => p.Nombre)
            .Select(p => new
            {
                p.Id,
                p.CodigoBarras,
                p.Nombre,
                p.CostoPromedio,
                p.PrecioVenta,
                p.StockActual,
                p.StockMinimo,
                p.Ubicacion,
                StockBajo = p.StockActual <= p.StockMinimo
            })
            .ToListAsync();

        return Ok(BaseResponse<object>.Success(productos));
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var producto = await _context.Productos.FindAsync(id);
        if (producto == null)
            return NotFound(BaseResponse<object>.Failure("Producto no encontrado"));

        return Ok(BaseResponse<object>.Success(producto));
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateProductoRequest request)
    {
        var existe = await _context.Productos
            .AnyAsync(p => p.EmpresaId == _tenant.EmpresaId && p.CodigoBarras == request.CodigoBarras);

        if (existe)
            return Conflict(BaseResponse<Guid>.Failure("Ya existe un producto con este código de barras"));

        var producto = new Producto
        {
            EmpresaId = _tenant.EmpresaId,
            CodigoBarras = request.CodigoBarras,
            Nombre = request.Nombre,
            CostoPromedio = request.CostoPromedio,
            PrecioVenta = request.PrecioVenta,
            StockActual = request.StockActual,
            StockMinimo = request.StockMinimo,
            Ubicacion = request.Ubicacion
        };

        _context.Productos.Add(producto);
        await _context.SaveChangesAsync();

        return Ok(BaseResponse<Guid>.Success(producto.Id, "Producto creado exitosamente"));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateProductoRequest request)
    {
        var producto = await _context.Productos.FindAsync(id);
        if (producto == null)
            return NotFound(BaseResponse<object>.Failure("Producto no encontrado"));

        producto.Nombre = request.Nombre;
        producto.PrecioVenta = request.PrecioVenta;
        producto.StockMinimo = request.StockMinimo;
        producto.Ubicacion = request.Ubicacion;

        await _context.SaveChangesAsync();

        return Ok(BaseResponse<object>.Success(new { producto.Id }, "Producto actualizado exitosamente"));
    }
}

public record CreateProductoRequest(
    string CodigoBarras,
    string Nombre,
    decimal CostoPromedio,
    decimal PrecioVenta,
    decimal StockActual,
    decimal StockMinimo,
    string? Ubicacion
);

public record UpdateProductoRequest(
    string Nombre,
    decimal PrecioVenta,
    decimal StockMinimo,
    string? Ubicacion
);
