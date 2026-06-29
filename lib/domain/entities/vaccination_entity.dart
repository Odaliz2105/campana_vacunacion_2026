/// Entidad de negocio pura: Registro de vacunación
class VaccinationEntity {
  final String id;
  final String propietarioNombre;
  final String propietarioCedula;
  final String telefono;
  final String tipoMascota;   // 'Canino' | 'Felino'
  final String nombreMascota;
  final String edadAproximada;
  final String sexo;          // 'Macho' | 'Hembra'
  final String vacunaAplicada;
  final String observaciones;
  final String? fotoUrl;      // URL remota (Firebase) o ruta local (offline)
  final double latitud;
  final double longitud;
  final DateTime fechaRegistro;
  final String sectorId;
  final String vacunadorId;
  final bool sincronizado;    // false = pendiente en Hive, true = en Firestore

  const VaccinationEntity({
    required this.id,
    required this.propietarioNombre,
    required this.propietarioCedula,
    required this.telefono,
    required this.tipoMascota,
    required this.nombreMascota,
    required this.edadAproximada,
    required this.sexo,
    required this.vacunaAplicada,
    required this.observaciones,
    this.fotoUrl,
    required this.latitud,
    required this.longitud,
    required this.fechaRegistro,
    required this.sectorId,
    required this.vacunadorId,
    required this.sincronizado,
  });

  /// Retorna true si el registro pertenece a un canino
  bool get isCanino => tipoMascota == 'Canino';

  /// Retorna true si el registro es un felino
  bool get isFelino => tipoMascota == 'Felino';

  VaccinationEntity copyWith({
    String? id,
    String? propietarioNombre,
    String? propietarioCedula,
    String? telefono,
    String? tipoMascota,
    String? nombreMascota,
    String? edadAproximada,
    String? sexo,
    String? vacunaAplicada,
    String? observaciones,
    String? fotoUrl,
    double? latitud,
    double? longitud,
    DateTime? fechaRegistro,
    String? sectorId,
    String? vacunadorId,
    bool? sincronizado,
  }) {
    return VaccinationEntity(
      id: id ?? this.id,
      propietarioNombre: propietarioNombre ?? this.propietarioNombre,
      propietarioCedula: propietarioCedula ?? this.propietarioCedula,
      telefono: telefono ?? this.telefono,
      tipoMascota: tipoMascota ?? this.tipoMascota,
      nombreMascota: nombreMascota ?? this.nombreMascota,
      edadAproximada: edadAproximada ?? this.edadAproximada,
      sexo: sexo ?? this.sexo,
      vacunaAplicada: vacunaAplicada ?? this.vacunaAplicada,
      observaciones: observaciones ?? this.observaciones,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      sectorId: sectorId ?? this.sectorId,
      vacunadorId: vacunadorId ?? this.vacunadorId,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}
