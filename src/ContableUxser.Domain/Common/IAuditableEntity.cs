namespace ContableUxser.Domain.Common;

public interface IAuditableEntity
{
    DateTime FechaRegistro { get; set; }
    DateTime? FechaActualizacion { get; set; }
}
