using ContableUxser.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ContableUxser.Infrastructure.Data.Configurations;

public class VentaDetalleConfiguration : IEntityTypeConfiguration<VentaDetalle>
{
    public void Configure(EntityTypeBuilder<VentaDetalle> builder)
    {
        builder.ToTable("VentaDetalles");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.Cantidad)
            .HasPrecision(18, 3);

        builder.Property(e => e.PrecioUnitario)
            .HasPrecision(18, 4);

        builder.Property(e => e.Subtotal)
            .HasPrecision(18, 4);

        builder.HasOne(e => e.Venta)
            .WithMany(e => e.VentaDetalles)
            .HasForeignKey(e => e.VentaId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(e => e.Producto)
            .WithMany(e => e.VentaDetalles)
            .HasForeignKey(e => e.ProductoId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(e => e.VentaId);
        builder.HasIndex(e => e.ProductoId);
    }
}
