using ContableUxser.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ContableUxser.Infrastructure.Data.Configurations;

public class SesionCajaConfiguration : IEntityTypeConfiguration<SesionCaja>
{
    public void Configure(EntityTypeBuilder<SesionCaja> builder)
    {
        builder.ToTable("SesionesCaja");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.ValorApertura)
            .HasPrecision(18, 4);

        builder.Property(e => e.ValorCierreReal)
            .HasPrecision(18, 4);

        builder.Property(e => e.ValorCierreCalculado)
            .HasPrecision(18, 4);

        builder.Property(e => e.Diferencia)
            .HasPrecision(18, 4);

        builder.Property(e => e.Estado)
            .IsRequired()
            .HasConversion<string>();

        builder.HasOne(e => e.Empresa)
            .WithMany(e => e.SesionesCaja)
            .HasForeignKey(e => e.EmpresaId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(e => e.Usuario)
            .WithMany(e => e.SesionesCaja)
            .HasForeignKey(e => e.UsuarioId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(e => e.EmpresaId);
        builder.HasIndex(e => e.UsuarioId);
    }
}
