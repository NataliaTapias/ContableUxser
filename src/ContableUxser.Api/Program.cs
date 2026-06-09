using System.Text;
using ContableUxser.Application;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Entities;
using ContableUxser.Domain.Enums;
using ContableUxser.Domain.Interfaces;
using ContableUxser.Infrastructure;
using ContableUxser.Infrastructure.Data;
using ContableUxser.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// ── Services ──────────────────────────────────────────────────────────
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

builder.Services.AddHttpContextAccessor();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

var showSwagger = builder.Configuration.GetValue<bool>("EnableSwagger");
if (showSwagger)
{
    builder.Services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo
        {
            Title = "ContableUxser API",
            Version = "v1",
            Description = "SaaS Multi-tenant Accounting & Inventory API"
        });

        options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
        {
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT",
            In = ParameterLocation.Header,
            Description = "Ingrese su token JWT"
        });

        options.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                Array.Empty<string>()
            }
        });
    });
}

// ── Authentication (JWT) ────────────────────────────────────────────
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Secret"]!))
    };
});

builder.Services.AddAuthorization();

// ── CORS ─────────────────────────────────────────────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// ── Middleware pipeline ──────────────────────────────────────────────
if (showSwagger)
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();



app.MapControllers();

// ── Apply migrations on startup (after app is listening) ───────────
app.Lifetime.ApplicationStarted.Register(async () =>
{
    if (!builder.Configuration.GetValue<bool>("RUN_MIGRATIONS")) return;

    await Task.Delay(1000);
    Console.WriteLine("[INFO] Starting database setup...");

    try
    {
        var connStr = builder.Configuration.GetConnectionString("DefaultConnection");
        using var conn = new NpgsqlConnection { ConnectionString = connStr, Pooling = false };
        await conn.OpenAsync();
        using var cmd = conn.CreateCommand();

        // Ensure tables exist
        cmd.CommandText = @"
            CREATE TABLE IF NOT EXISTS ""Empresas"" (
                ""Id"" UUID PRIMARY KEY, ""Nombre"" VARCHAR(200) NOT NULL, ""NIT"" VARCHAR(50) NOT NULL,
                ""Activo"" BOOLEAN DEFAULT TRUE, ""FechaRegistro"" TIMESTAMPTZ NOT NULL DEFAULT NOW(), ""FechaActualizacion"" TIMESTAMPTZ);
            CREATE TABLE IF NOT EXISTS ""Usuarios"" (
                ""Id"" UUID PRIMARY KEY, ""EmpresaId"" UUID NOT NULL REFERENCES ""Empresas""(""Id""),
                ""Nombre"" VARCHAR(200) NOT NULL, ""Email"" VARCHAR(200) NOT NULL UNIQUE,
                ""PasswordHash"" VARCHAR(500) NOT NULL DEFAULT '', ""Rol"" TEXT NOT NULL,
                ""Activo"" BOOLEAN DEFAULT TRUE, ""FechaRegistro"" TIMESTAMPTZ NOT NULL DEFAULT NOW(), ""FechaActualizacion"" TIMESTAMPTZ);
            CREATE TABLE IF NOT EXISTS ""Productos"" (
                ""Id"" UUID PRIMARY KEY, ""EmpresaId"" UUID NOT NULL REFERENCES ""Empresas""(""Id""),
                ""CodigoBarras"" VARCHAR(100) NOT NULL, ""Nombre"" VARCHAR(300) NOT NULL,
                ""CostoPromedio"" DECIMAL(18,4) NOT NULL, ""PrecioVenta"" DECIMAL(18,4) NOT NULL,
                ""StockActual"" DECIMAL(18,3) NOT NULL, ""StockMinimo"" DECIMAL(18,3) NOT NULL,
                ""Ubicacion"" VARCHAR(200), ""ImagenUrl"" VARCHAR(500),
                ""FechaRegistro"" TIMESTAMPTZ NOT NULL DEFAULT NOW(), ""FechaActualizacion"" TIMESTAMPTZ,
                UNIQUE(""EmpresaId"", ""CodigoBarras""));";
        await cmd.ExecuteNonQueryAsync();
        Console.WriteLine("[INFO] Tables ensured.");

        // Ensure PasswordHash column exists
        cmd.CommandText = @"ALTER TABLE ""Usuarios"" ADD COLUMN IF NOT EXISTS ""PasswordHash"" VARCHAR(500) NOT NULL DEFAULT ''";
        await cmd.ExecuteNonQueryAsync();

        // Fix empty PasswordHash
        cmd.CommandText = "UPDATE \"Usuarios\" SET \"PasswordHash\" = @hash WHERE \"Email\" = @email AND (\"PasswordHash\" = '' OR \"PasswordHash\" IS NULL)";
        var hasher = new PasswordHasherService();
        cmd.Parameters.AddWithValue("@hash", hasher.Hash("admin123"));
        cmd.Parameters.AddWithValue("@email", "admin@demo.com");
        var updated = await cmd.ExecuteNonQueryAsync();
        if (updated > 0) Console.WriteLine($"[INFO] Fixed {updated} admin password(s).");

        // Full seed if no empresas
        cmd.Parameters.Clear();
        cmd.CommandText = "SELECT COUNT(*) FROM \"Empresas\"";
        var empCount = (long)(await cmd.ExecuteScalarAsync())!;
        if (empCount == 0)
        {
            Console.WriteLine("[INFO] Seeding fresh data...");
            var empresaId = Guid.NewGuid();
            cmd.Parameters.Clear();
            cmd.CommandText = @"INSERT INTO ""Empresas"" (""Id"", ""Nombre"", ""NIT"") VALUES (@id, @nom, @nit)";
            cmd.Parameters.AddWithValue("@id", empresaId);
            cmd.Parameters.AddWithValue("@nom", "Demo Empresa");
            cmd.Parameters.AddWithValue("@nit", "900000000-1");
            await cmd.ExecuteNonQueryAsync();

            cmd.Parameters.Clear();
            cmd.CommandText = @"INSERT INTO ""Usuarios"" (""Id"", ""EmpresaId"", ""Nombre"", ""Email"", ""PasswordHash"", ""Rol"")
                VALUES (@id, @eid, @nom, @mail, @hash, @rol)";
            cmd.Parameters.AddWithValue("@id", Guid.NewGuid());
            cmd.Parameters.AddWithValue("@eid", empresaId);
            cmd.Parameters.AddWithValue("@nom", "Admin Demo");
            cmd.Parameters.AddWithValue("@mail", "admin@demo.com");
            cmd.Parameters.AddWithValue("@hash", hasher.Hash("admin123"));
            cmd.Parameters.AddWithValue("@rol", "Administrador");
            await cmd.ExecuteNonQueryAsync();

            var productos = new (string Codigo, string Nombre, decimal Costo, decimal Precio, decimal Stock, decimal Min)[]
            {
                ("75010001", "Arroz Diana x1kg", 2800m, 3200m, 50m, 10m),
                ("75010002", "Aceite Gourmet x900ml", 8500m, 9800m, 20m, 5m),
                ("75010003", "Pan Bimbo Grande", 4200m, 5200m, 15m, 8m),
                ("75010004", "Leche Colanta x1L", 3100m, 3800m, 30m, 12m),
                ("75010005", "Huevos Santa Reyes x30", 12000m, 14500m, 10m, 3m),
                ("75010006", "Jabón Ariel x500g", 4500m, 5600m, 25m, 6m),
                ("75010007", "Coca-Cola x2L", 4200m, 5000m, 40m, 15m),
                ("75010008", "Papel Higiénico x4", 3800m, 4800m, 18m, 5m),
            };
            foreach (var p in productos)
            {
                cmd.Parameters.Clear();
                cmd.CommandText = @"INSERT INTO ""Productos"" (""Id"", ""EmpresaId"", ""CodigoBarras"", ""Nombre"", ""CostoPromedio"", ""PrecioVenta"", ""StockActual"", ""StockMinimo"")
                    VALUES (@id, @eid, @cod, @nom, @cost, @precio, @stock, @min)";
                cmd.Parameters.AddWithValue("@id", Guid.NewGuid());
                cmd.Parameters.AddWithValue("@eid", empresaId);
                cmd.Parameters.AddWithValue("@cod", p.Codigo);
                cmd.Parameters.AddWithValue("@nom", p.Nombre);
                cmd.Parameters.AddWithValue("@cost", p.Costo);
                cmd.Parameters.AddWithValue("@precio", p.Precio);
                cmd.Parameters.AddWithValue("@stock", p.Stock);
                cmd.Parameters.AddWithValue("@min", p.Min);
                await cmd.ExecuteNonQueryAsync();
            }
            Console.WriteLine("[INFO] Seed completed.");
        }
        else
        {
            Console.WriteLine($"[INFO] Data exists ({empCount} empresas).");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[WARN] DB setup failed: {ex.Message}");
    }
});

var port = Uri.TryCreate(app.Urls.FirstOrDefault(), UriKind.Absolute, out var uri) ? uri.Port : 8080;
app.Lifetime.ApplicationStarted.Register(() =>
{
    Console.WriteLine($@"╔══════════════════════════════════════════╗");
    Console.WriteLine($@"║      ContableUxser API is running       ║");
    Console.WriteLine($@"║      Port: {port,-31}║");
    Console.WriteLine($@"╚══════════════════════════════════════════╝");
});

await app.RunAsync();
