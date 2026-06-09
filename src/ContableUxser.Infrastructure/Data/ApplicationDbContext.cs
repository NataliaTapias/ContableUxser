using System.Reflection;
using ContableUxser.Application.Interfaces;
using ContableUxser.Domain.Common;
using ContableUxser.Domain.Entities;
using ContableUxser.Domain.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace ContableUxser.Infrastructure.Data;

public class ApplicationDbContext : DbContext, IApplicationDbContext
{
    private readonly ITenantProvider _tenantProvider;

    public ApplicationDbContext(
        DbContextOptions<ApplicationDbContext> options,
        ITenantProvider tenantProvider)
        : base(options)
    {
        _tenantProvider = tenantProvider;
    }

    public DbSet<Empresa> Empresas => Set<Empresa>();
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Producto> Productos => Set<Producto>();
    public DbSet<SesionCaja> SesionesCaja => Set<SesionCaja>();
    public DbSet<Venta> Ventas => Set<Venta>();
    public DbSet<VentaDetalle> VentaDetalles => Set<VentaDetalle>();
    public DbSet<MovimientoInventario> MovimientosInventario => Set<MovimientoInventario>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());

        ApplyGlobalQueryFilters(modelBuilder);
    }

    private void ApplyGlobalQueryFilters(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Producto>().HasQueryFilter(e => e.EmpresaId == _tenantProvider.EmpresaId);
        modelBuilder.Entity<SesionCaja>().HasQueryFilter(e => e.EmpresaId == _tenantProvider.EmpresaId);
        modelBuilder.Entity<Venta>().HasQueryFilter(e => e.EmpresaId == _tenantProvider.EmpresaId);
        modelBuilder.Entity<MovimientoInventario>().HasQueryFilter(e => e.EmpresaId == _tenantProvider.EmpresaId);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        SetAuditableEntityProperties();
        return await base.SaveChangesAsync(cancellationToken);
    }

    private void SetAuditableEntityProperties()
    {
        var entries = ChangeTracker
            .Entries()
            .Where(e => e.Entity is BaseEntity && e.State is EntityState.Added or EntityState.Modified);

        foreach (var entry in entries)
        {
            if (entry.State == EntityState.Added)
            {
                ((BaseEntity)entry.Entity).FechaRegistro = DateTime.UtcNow;
            }

            if (entry.State == EntityState.Modified)
            {
                ((BaseEntity)entry.Entity).FechaActualizacion = DateTime.UtcNow;
            }
        }
    }
}
