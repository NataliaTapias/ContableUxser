using ContableUxser.Domain.Common;
using ContableUxser.Domain.Enums;

namespace ContableUxser.Domain.Entities;

public class Venta : BaseEntity
{
    public Guid EmpresaId { get; set; }
    public Guid SesionCajaId { get; set; }
    public Guid UsuarioId { get; set; }
    public DateTime FechaVenta { get; set; } = DateTime.UtcNow;
    public decimal Total { get; set; }
    public MetodoPago MetodoPago { get; set; }
    public string? ReferenciaTransferencia { get; set; }
    public bool SincronizadoNube { get; set; }

    public Empresa Empresa { get; set; } = null!;
    public SesionCaja SesionCaja { get; set; } = null!;
    public Usuario Usuario { get; set; } = null!;
    public ICollection<VentaDetalle> VentaDetalles { get; set; } = new List<VentaDetalle>();
}
