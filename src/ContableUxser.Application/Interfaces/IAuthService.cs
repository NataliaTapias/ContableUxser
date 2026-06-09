namespace ContableUxser.Application.Interfaces;

public interface IAuthService
{
    Task<string> LoginAsync(string email, string password);
    Task RegisterAsync(string email, string password, string nombre, Guid empresaId);
    Task<Guid> GetEmpresaIdFromTokenAsync(string token);
    Task<Guid> GetUsuarioIdFromTokenAsync(string token);
}
