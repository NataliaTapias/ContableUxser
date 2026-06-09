namespace ContableUxser.Application.Interfaces;

public interface ITokenService
{
    string GenerateToken(Guid usuarioId, string email, Guid empresaId, string rol);
}
