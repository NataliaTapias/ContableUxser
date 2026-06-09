using ContableUxser.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ContableUxser.Infrastructure.Data.Configurations;

public class ProductoConfiguration : IEntityTypeConfiguration<Producto>
{
    public void Configure(EntityTypeBuilder<Producto> builder)
    {
        builder.ToTable("Productos");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.Nombre)
            .IsRequired()
            .HasMaxLength(300);

        builder.Property(e => e.CodigoBarras)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(e => e.CostoPromedio)
            .HasPrecision(18, 4);

        builder.Property(e => e.PrecioVenta)
            .HasPrecision(18, 4);

        builder.Property(e => e.StockActual)
            .HasPrecision(18, 3);

        builder.Property(e => e.StockMinimo)
            .HasPrecision(18, 3);

        builder.Property(e => e.Ubicacion)
            .HasMaxLength(200);

        builder.Property(e => e.ImagenUrl)
            .HasMaxLength(500);

        builder.HasOne(e => e.Empresa)
            .WithMany(e => e.Productos)
            .HasForeignKey(e => e.EmpresaId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(e => new { e.EmpresaId, e.CodigoBarras })
            .IsUnique();

        builder.HasIndex(e => e.EmpresaId);
    }
}
