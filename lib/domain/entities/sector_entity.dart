/// Entidad de negocio pura: Sector geográfico de campaña
class SectorEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fechaCreacion;

  const SectorEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
  });

  SectorEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaCreacion,
  }) {
    return SectorEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
