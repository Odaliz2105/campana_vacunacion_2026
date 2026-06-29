import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// Modelo de datos del usuario con serialización Firestore/JSON
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.cedula,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.email,
    required super.rol,
    super.sectorId,
    required super.passwordChanged,
    required super.fechaCreacion,
  });

  /// Construye un UserModel desde un documento de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      cedula: data['cedula'] ?? '',
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      telefono: data['telefono'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? '',
      sectorId: data['sectorId'],
      passwordChanged: data['passwordChanged'] ?? false,
      fechaCreacion: data['fechaCreacion'] != null
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Construye un UserModel desde un mapa JSON (Hive local)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      cedula: map['cedula'] ?? '',
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      rol: map['rol'] ?? '',
      sectorId: map['sectorId'],
      passwordChanged: map['passwordChanged'] ?? false,
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  /// Serializa a mapa para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'email': email,
      'rol': rol,
      'sectorId': sectorId,
      'passwordChanged': passwordChanged,
      'fechaCreacion': FieldValue.serverTimestamp(),
    };
  }

  /// Serializa a mapa para almacenamiento local (Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'email': email,
      'rol': rol,
      'sectorId': sectorId,
      'passwordChanged': passwordChanged,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Construye desde entidad de dominio
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      cedula: entity.cedula,
      nombres: entity.nombres,
      apellidos: entity.apellidos,
      telefono: entity.telefono,
      email: entity.email,
      rol: entity.rol,
      sectorId: entity.sectorId,
      passwordChanged: entity.passwordChanged,
      fechaCreacion: entity.fechaCreacion,
    );
  }
}
