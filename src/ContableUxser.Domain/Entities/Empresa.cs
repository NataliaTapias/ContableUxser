using ContableUxser.Domain.Common;

namespace ContableUxser.Domain.Entities;

public class Empresa : BaseEntity
{
    public string Nombre { get; set; } = string.Empty;
    public string NIT { get; set; } = string.Empty;
    public bool Activo { get; set; } = true;

    public ICollection<Usuario> Usuarios { get; set; } = new List<Usuario>();
    public ICollection<Producto> Productos { get; set; } = new List<Producto>();
    public ICollection<SesionCaja> SesionesCaja { get; set; } = new List<SesionCaja>();
    public ICollection<Venta> Ventas { get; set; } = new List<Venta>();
    public ICollection<MovimientoInventario> MovimientosInventario { get; set; } = new List<MovimientoInventario>();
}
