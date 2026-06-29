import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sector_entity.dart';

/// Modelo de datos del sector con serialización Firestore/JSON
class SectorModel extends SectorEntity {
  const SectorModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.fechaCreacion,
  });

  factory SectorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SectorModel(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fechaCreacion: data['fechaCreacion'] != null
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory SectorModel.fromMap(Map<String, dynamic> map) {
    return SectorModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaCreacion': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory SectorModel.fromEntity(SectorEntity entity) {
    return SectorModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      fechaCreacion: entity.fechaCreacion,
    );
  }
}
