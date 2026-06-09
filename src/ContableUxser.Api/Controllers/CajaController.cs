using ContableUxser.Application.Common;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Entities;
using ContableUxser.Domain.Enums;
using ContableUxser.Domain.Interfaces;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ContableUxser.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CajaController : ControllerBase
{
    private readonly IApplicationDbContext _context;
    private readonly ITenantProvider _tenant;

    public CajaController(IApplicationDbContext context, ITenantProvider tenant)
    {
        _context = context;
        _tenant = tenant;
    }

    [HttpPost("apertura")]
    public async Task<IActionResult> AbrirCaja([FromBody] AbrirCajaRequest request)
    {
        var sesionAbierta = await _context.SesionesCaja
            .AnyAsync(s => s.UsuarioId == _tenant.UsuarioId && s.Estado == EstadoSesionCaja.Abierta);

        if (sesionAbierta)
            return BadRequest(BaseResponse<Guid>.Failure("Ya tienes una sesión de caja abierta"));

        var sesion = new SesionCaja
        {
            EmpresaId = _tenant.EmpresaId,
            UsuarioId = _tenant.UsuarioId,
            ValorApertura = request.ValorApertura,
            Estado = EstadoSesionCaja.Abierta
        };

        _context.SesionesCaja.Add(sesion);
        await _context.SaveChangesAsync();

        return Ok(BaseResponse<Guid>.Success(sesion.Id, "Caja abierta exitosamente"));
    }

    [HttpPost("cierre/{id:guid}")]
    public async Task<IActionResult> CerrarCaja(Guid id, [FromBody] CerrarCajaRequest request)
    {
        var sesion = await _context.SesionesCaja
            .Include(s => s.Ventas)
            .FirstOrDefaultAsync(s => s.Id == id && s.Estado == EstadoSesionCaja.Abierta);

        if (sesion == null)
            return NotFound(BaseResponse<Guid>.Failure("Sesión de caja no encontrada o ya cerrada"));

        var totalEfectivoCalculado = sesion.ValorApertura +
            sesion.Ventas
                .Where(v => v.MetodoPago == MetodoPago.Efectivo)
                .Sum(v => v.Total);

        var totalTransferencias = sesion.Ventas
            .Where(v => v.MetodoPago == MetodoPago.Transferencia)
            .Sum(v => v.Total);

        sesion.ValorCierreReal = request.ValorCierreReal;
        sesion.ValorCierreCalculado = totalEfectivoCalculado;
        sesion.Diferencia = request.ValorCierreReal - totalEfectivoCalculado;
        sesion.FechaCierre = DateTime.UtcNow;
        sesion.Estado = EstadoSesionCaja.Cerrada;

        await _context.SaveChangesAsync();

        return Ok(BaseResponse<object>.Success(new
        {
            sesion.Id,
            sesion.ValorApertura,
            EfectivoCalculado = totalEfectivoCalculado,
            TotalTransferencias = totalTransferencias,
            sesion.ValorCierreReal,
            sesion.Diferencia
        }, "Caja cerrada exitosamente"));
    }
}

public record AbrirCajaRequest(decimal ValorApertura);
public record CerrarCajaRequest(decimal ValorCierreReal);
