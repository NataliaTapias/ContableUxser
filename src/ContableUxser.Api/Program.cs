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
app.MapControllers();

// ── Apply migrations on startup (opt-in) ────────────────────────────
if (builder.Configuration.GetValue<bool>("RUN_MIGRATIONS"))
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await dbContext.Database.MigrateAsync();
    var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();
    await SeedDataAsync(dbContext, passwordHasher);
}

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

    var empresaId = Guid.NewGuid();
    var adminId = Guid.NewGuid();
    var adminPasswordHash = passwordHasher.Hash("admin123");

    using var tx = await db.Database.BeginTransactionAsync();
    db.Database.ExecuteSqlRaw(
        "INSERT INTO \"Empresas\" (\"Id\", \"Nombre\", \"NIT\", \"Activo\", \"FechaRegistro\") VALUES ({0}, {1}, {2}, TRUE, NOW())",
        empresaId, "Demo Empresa", "900000000-1");
    db.Database.ExecuteSqlRaw(
        "INSERT INTO \"Usuarios\" (\"Id\", \"EmpresaId\", \"Nombre\", \"Email\", \"PasswordHash\", \"Rol\", \"Activo\", \"FechaRegistro\") VALUES ({0}, {1}, {2}, {3}, {4}, {5}, TRUE, NOW())",
        adminId, empresaId, "Admin Demo", "admin@demo.com", adminPasswordHash, "Administrador");

    var productos = new[]
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

    foreach (var (codigo, nombre, costo, precio, stock, min) in productos)
    {
        db.Database.ExecuteSqlRaw(
            "INSERT INTO \"Productos\" (\"Id\", \"EmpresaId\", \"CodigoBarras\", \"Nombre\", \"CostoPromedio\", \"PrecioVenta\", \"StockActual\", \"StockMinimo\", \"FechaRegistro\") VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, NOW())",
            Guid.NewGuid(), empresaId, codigo, nombre, costo, precio, stock, min);
    }

    await tx.CommitAsync();
}
