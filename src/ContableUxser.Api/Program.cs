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

app.MapGet("/api/health", async (ApplicationDbContext db) =>
{
    try
    {
        var canConnect = await db.Database.CanConnectAsync();
        var empresaCount = await db.Empresas.CountAsync();
        var usuarioCount = await db.Usuarios.IgnoreQueryFilters().CountAsync();
        var usuarios = await db.Usuarios.IgnoreQueryFilters()
            .Select(u => new { u.Email, u.Nombre }).ToListAsync();
        return Results.Ok(new { status = "ok", canConnect, empresaCount, usuarioCount, usuarios, environment = builder.Environment.EnvironmentName });
    }
    catch (Exception ex)
    {
        return Results.Ok(new { status = "error", message = ex.Message });
    }
});

app.MapControllers();

// ── Apply migrations on startup (after app is listening) ───────────
app.Lifetime.ApplicationStarted.Register(async () =>
{
    if (!builder.Configuration.GetValue<bool>("RUN_MIGRATIONS")) return;

    await Task.Delay(1000);
    Console.WriteLine("[INFO] Starting database setup...");

    try
    {
        using var scope = app.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        await db.Database.EnsureCreatedAsync();

        // Fix missing PasswordHash column from failed migration
        try
        {
            await db.Database.ExecuteSqlRawAsync(
                "ALTER TABLE \"Usuarios\" ADD COLUMN IF NOT EXISTS \"PasswordHash\" character varying(500) NOT NULL DEFAULT ''");
        }
        catch { /* column already exists or other error */ }

        var hasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();
        await SeedDataAsync(db, hasher);
        Console.WriteLine("[INFO] Seeding completed.");
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

static async Task SeedDataAsync(ApplicationDbContext db, IPasswordHasher passwordHasher)
{
    if (await db.Empresas.AnyAsync()) return;

    var empresa = new Empresa
    {
        Nombre = "Demo Empresa",
        NIT = "900000000-1",
        Activo = true
    };
    db.Empresas.Add(empresa);
    await db.SaveChangesAsync();

    var admin = new Usuario
    {
        EmpresaId = empresa.Id,
        Nombre = "Admin Demo",
        Email = "admin@demo.com",
        PasswordHash = passwordHasher.Hash("admin123"),
        Rol = RolUsuario.Administrador,
        Activo = true
    };
    db.Usuarios.Add(admin);
    await db.SaveChangesAsync();

    var productos = new[]
    {
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010001", Nombre = "Arroz Diana x1kg", CostoPromedio = 2800m, PrecioVenta = 3200m, StockActual = 50m, StockMinimo = 10m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010002", Nombre = "Aceite Gourmet x900ml", CostoPromedio = 8500m, PrecioVenta = 9800m, StockActual = 20m, StockMinimo = 5m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010003", Nombre = "Pan Bimbo Grande", CostoPromedio = 4200m, PrecioVenta = 5200m, StockActual = 15m, StockMinimo = 8m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010004", Nombre = "Leche Colanta x1L", CostoPromedio = 3100m, PrecioVenta = 3800m, StockActual = 30m, StockMinimo = 12m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010005", Nombre = "Huevos Santa Reyes x30", CostoPromedio = 12000m, PrecioVenta = 14500m, StockActual = 10m, StockMinimo = 3m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010006", Nombre = "Jabón Ariel x500g", CostoPromedio = 4500m, PrecioVenta = 5600m, StockActual = 25m, StockMinimo = 6m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010007", Nombre = "Coca-Cola x2L", CostoPromedio = 4200m, PrecioVenta = 5000m, StockActual = 40m, StockMinimo = 15m },
        new Producto { EmpresaId = empresa.Id, CodigoBarras = "75010008", Nombre = "Papel Higiénico x4", CostoPromedio = 3800m, PrecioVenta = 4800m, StockActual = 18m, StockMinimo = 5m },
    };
    db.Productos.AddRange(productos);
    await db.SaveChangesAsync();
}
