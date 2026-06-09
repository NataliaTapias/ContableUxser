using ContableUxser.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ContableUxser.Infrastructure.Data.Configurations;

public class MovimientoInventarioConfiguration : IEntityTypeConfiguration<MovimientoInventario>
{
    public void Configure(EntityTypeBuilder<MovimientoInventario> builder)
    {
        builder.ToTable("MovimientosInventario");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.TipoMovimiento)
            .IsRequired()
            .HasConversion<string>();

        builder.Property(e => e.Cantidad)
            .HasPrecision(18, 3);

        builder.Property(e => e.CostoUnitario)
            .HasPrecision(18, 4);

        builder.Property(e => e.Notas)
            .HasMaxLength(500);

        builder.HasOne(e => e.Empresa)
            .WithMany(e => e.MovimientosInventario)
            .HasForeignKey(e => e.EmpresaId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Producto)
            .WithMany(e => e.MovimientosInventario)
            .HasForeignKey(e => e.ProductoId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(e => e.EmpresaId);
        builder.HasIndex(e => e.ProductoId);
        builder.HasIndex(e => e.FechaRegistro);
    }
}
