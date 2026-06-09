namespace ContableUxser.Domain.Interfaces;

public interface ITenantProvider
{
    Guid EmpresaId { get; }
    Guid UsuarioId { get; }
}
