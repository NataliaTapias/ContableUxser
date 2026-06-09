using ContableUxser.Domain.Common;
using ContableUxser.Domain.Enums;

namespace ContableUxser.Domain.Entities;

public class SesionCaja : BaseEntity
{
    public Guid EmpresaId { get; set; }
    public Guid UsuarioId { get; set; }
    public DateTime FechaApertura { get; set; } = DateTime.UtcNow;
    public DateTime? FechaCierre { get; set; }
    public decimal ValorApertura { get; set; }
    public decimal? ValorCierreReal { get; set; }
    public decimal? ValorCierreCalculado { get; set; }
    public decimal? Diferencia { get; set; }
    public EstadoSesionCaja Estado { get; set; } = EstadoSesionCaja.Abierta;

    public Empresa Empresa { get; set; } = null!;
    public Usuario Usuario { get; set; } = null!;
    public ICollection<Venta> Ventas { get; set; } = new List<Venta>();
}
