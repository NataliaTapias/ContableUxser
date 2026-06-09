using ContableUxser.Domain.Common;

namespace ContableUxser.Domain.Entities;

public class VentaDetalle : BaseEntity
{
    public Guid VentaId { get; set; }
    public Guid ProductoId { get; set; }
    public decimal Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    public decimal Subtotal { get; set; }

    public Venta Venta { get; set; } = null!;
    public Producto Producto { get; set; } = null!;
}
