using System.Security.Claims;
using ContableUxser.Domain.Interfaces;
using Microsoft.AspNetCore.Http;

namespace ContableUxser.Infrastructure.Services;

public class TenantProvider : ITenantProvider
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public TenantProvider(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid EmpresaId
    {
        get
        {
            var claim = _httpContextAccessor.HttpContext?.User?.FindFirst(AuthClaimTypes.EmpresaId)?.Value;
            return Guid.TryParse(claim, out var empresaId) ? empresaId : Guid.Empty;
        }
    }

    public Guid UsuarioId
    {
        get
        {
            var claim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return Guid.TryParse(claim, out var usuarioId) ? usuarioId : Guid.Empty;
        }
    }
}
