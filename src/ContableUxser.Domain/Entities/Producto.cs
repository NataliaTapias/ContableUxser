using ContableUxser.Domain.Common;

namespace ContableUxser.Domain.Entities;

public class Producto : BaseEntity
{
    public Guid EmpresaId { get; set; }
    public string CodigoBarras { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public decimal CostoPromedio { get; set; }
    public decimal PrecioVenta { get; set; }
    public decimal StockActual { get; set; }
    public decimal StockMinimo { get; set; }
    public string? Ubicacion { get; set; }
    public string? ImagenUrl { get; set; }

    public Empresa Empresa { get; set; } = null!;
    public ICollection<VentaDetalle> VentaDetalles { get; set; } = new List<VentaDetalle>();
    public ICollection<MovimientoInventario> MovimientosInventario { get; set; } = new List<MovimientoInventario>();
}
