using ContableUxser.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ContableUxser.Infrastructure.Data.Configurations;

public class VentaConfiguration : IEntityTypeConfiguration<Venta>
{
    public void Configure(EntityTypeBuilder<Venta> builder)
    {
        builder.ToTable("Ventas");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.Total)
            .HasPrecision(18, 4);

        builder.Property(e => e.MetodoPago)
            .IsRequired()
            .HasConversion<string>();

        builder.Property(e => e.ReferenciaTransferencia)
            .HasMaxLength(20);

        builder.Property(e => e.SincronizadoNube)
            .HasDefaultValue(false);

        builder.HasOne(e => e.Empresa)
            .WithMany(e => e.Ventas)
            .HasForeignKey(e => e.EmpresaId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.SesionCaja)
            .WithMany(e => e.Ventas)
            .HasForeignKey(e => e.SesionCajaId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Usuario)
            .WithMany(e => e.Ventas)
            .HasForeignKey(e => e.UsuarioId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(e => e.EmpresaId);
        builder.HasIndex(e => e.SesionCajaId);
        builder.HasIndex(e => e.FechaVenta);
    }
}
