namespace ContableUxser.Application.Common;

public class BaseResponse<T>
{
    public bool Exitoso { get; set; }
    public string? Mensaje { get; set; }
    public T? Datos { get; set; }
    public List<string> Errores { get; set; } = new();

    public static BaseResponse<T> Success(T data, string? mensaje = null) =>
        new() { Exitoso = true, Datos = data, Mensaje = mensaje };

    public static BaseResponse<T> Failure(string error) =>
        new() { Exitoso = false, Errores = new List<string> { error } };

    public static BaseResponse<T> Failure(List<string> errores) =>
        new() { Exitoso = false, Errores = errores };
}
