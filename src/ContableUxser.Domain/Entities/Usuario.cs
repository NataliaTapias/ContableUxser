using ContableUxser.Domain.Common;
using ContableUxser.Domain.Enums;

namespace ContableUxser.Domain.Entities;

public class Usuario : BaseEntity
{
    public Guid EmpresaId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public RolUsuario Rol { get; set; }
    public bool Activo { get; set; } = true;

    public Empresa Empresa { get; set; } = null!;
    public ICollection<SesionCaja> SesionesCaja { get; set; } = new List<SesionCaja>();
    public ICollection<Venta> Ventas { get; set; } = new List<Venta>();
}
