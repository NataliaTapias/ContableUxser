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
public class AuthController : ControllerBase
{
    private readonly IApplicationDbContext _context;
    private readonly ITokenService _tokenService;
    private readonly IPasswordHasher _passwordHasher;

    public AuthController(
        IApplicationDbContext context,
        ITokenService tokenService,
        IPasswordHasher passwordHasher)
    {
        _context = context;
        _tokenService = tokenService;
        _passwordHasher = passwordHasher;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var usuario = await _context.Usuarios
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(u => u.Email == request.Email && u.Activo);

        if (usuario == null)
            return Unauthorized(BaseResponse<string>.Failure("Usuario no encontrado"));

        if (!_passwordHasher.Verify(request.Password, usuario.PasswordHash))
            return Unauthorized(BaseResponse<string>.Failure("Contraseña incorrecta"));

        var token = _tokenService.GenerateToken(
            usuario.Id,
            usuario.Email,
            usuario.EmpresaId,
            usuario.Rol.ToString()
        );

        return Ok(BaseResponse<object>.Success(new
        {
            Token = token,
            Usuario = new
            {
                usuario.Id,
                usuario.Nombre,
                usuario.Email,
                Rol = usuario.Rol.ToString()
            }
        }, "Inicio de sesión exitoso"));
    }

    [HttpPost("register")]
    [Authorize(Roles = "Administrador")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        var existe = await _context.Usuarios
            .IgnoreQueryFilters()
            .AnyAsync(u => u.Email == request.Email);

        if (existe)
            return Conflict(BaseResponse<Guid>.Failure("El email ya está registrado"));

        var usuario = new Usuario
        {
            EmpresaId = request.EmpresaId,
            Nombre = request.Nombre,
            Email = request.Email,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Rol = Enum.Parse<RolUsuario>(request.Rol),
            Activo = true
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        return Ok(BaseResponse<Guid>.Success(usuario.Id, "Usuario registrado exitosamente"));
    }

    [HttpPost("register-empresa")]
    [AllowAnonymous]
    public async Task<IActionResult> RegisterEmpresa([FromBody] RegisterEmpresaRequest request)
    {
        var empresa = new Empresa
        {
            Nombre = request.EmpresaNombre,
            NIT = request.NIT,
            Activo = true
        };

        _context.Empresas.Add(empresa);
        await _context.SaveChangesAsync();

        var usuario = new Usuario
        {
            EmpresaId = empresa.Id,
            Nombre = request.Nombre,
            Email = request.Email,
            PasswordHash = _passwordHasher.Hash(request.Password),
            Rol = RolUsuario.Administrador,
            Activo = true
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        return Ok(BaseResponse<object>.Success(new
        {
            EmpresaId = empresa.Id,
            UsuarioId = usuario.Id
        }, "Empresa y administrador creados exitosamente"));
    }

    [AllowAnonymous]
    [HttpGet("debug")]
    public IActionResult Debug()
    {
        return Ok(new { message = "debug works" });
    }

    [AllowAnonymous]
    [HttpPost("debug/force-seed")]
    public async Task<IActionResult> ForceSeed([FromServices] IPasswordHasher passwordHasher)
    {
        try
        {
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"VentaDetalles\"");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"Ventas\"");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"MovimientosInventario\"");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"SesionesCaja\"");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"Productos\"");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"Usuarios\"");
            await _context.Database.ExecuteSqlRawAsync("DELETE FROM \"Empresas\"");

            var empresa = new Empresa { Nombre = "Demo Empresa", NIT = "900000000-1", Activo = true };
            _context.Empresas.Add(empresa);
            await _context.SaveChangesAsync();

            var admin = new Usuario
            {
                EmpresaId = empresa.Id,
                Nombre = "Admin Demo",
                Email = "admin@demo.com",
                PasswordHash = passwordHasher.Hash("admin123"),
                Rol = RolUsuario.Administrador,
                Activo = true
            };
            _context.Usuarios.Add(admin);
            await _context.SaveChangesAsync();

            return Ok(new { status = "ok", message = "Seed forced" });
        }
        catch (Exception ex)
        {
            return Ok(new { status = "error", message = ex.Message });
        }
    }
}

public record LoginRequest(string Email, string Password);
public record RegisterRequest(string Nombre, string Email, string Password, string Rol, Guid EmpresaId);
public record RegisterEmpresaRequest(string EmpresaNombre, string NIT, string Nombre, string Email, string Password);
