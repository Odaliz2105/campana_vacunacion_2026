/// Entidad de negocio pura: Usuario del sistema
class UserEntity {
  final String id;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String email;
  final String rol;
  final String? sectorId;
  final bool passwordChanged;
  final DateTime fechaCreacion;

  const UserEntity({
    required this.id,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.email,
    required this.rol,
    this.sectorId,
    required this.passwordChanged,
    required this.fechaCreacion,
  });

  /// Nombre completo del usuario
  String get nombreCompleto => '$nombres $apellidos';

  /// Verifica si el usuario es Coordinador de Campaña
  bool get isCoordinadorCampana => rol == 'Coordinador de Campaña';

  /// Verifica si el usuario es Coordinador de Brigada
  bool get isCoordinadorBrigada => rol == 'Coordinador de Brigada';

  /// Verifica si el usuario es Vacunador
  bool get isVacunador => rol == 'Vacunador';

  UserEntity copyWith({
    String? id,
    String? cedula,
    String? nombres,
    String? apellidos,
    String? telefono,
    String? email,
    String? rol,
    String? sectorId,
    bool? passwordChanged,
    DateTime? fechaCreacion,
  }) {
    return UserEntity(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      sectorId: sectorId ?? this.sectorId,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
