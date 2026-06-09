using ContableUxser.Domain.Common;
using ContableUxser.Domain.Enums;

namespace ContableUxser.Domain.Entities;

public class MovimientoInventario : BaseEntity
{
    public Guid EmpresaId { get; set; }
    public Guid ProductoId { get; set; }
    public TipoMovimiento TipoMovimiento { get; set; }
    public decimal Cantidad { get; set; }
    public decimal CostoUnitario { get; set; }
    public string? Notas { get; set; }

    public Empresa Empresa { get; set; } = null!;
    public Producto Producto { get; set; } = null!;
}
