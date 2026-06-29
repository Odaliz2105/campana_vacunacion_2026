import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/vaccination_entity.dart';

/// Modelo de datos de vacunación con serialización Firestore/JSON y soporte Hive
class VaccinationModel extends VaccinationEntity {
  const VaccinationModel({
    required super.id,
    required super.propietarioNombre,
    required super.propietarioCedula,
    required super.telefono,
    required super.tipoMascota,
    required super.nombreMascota,
    required super.edadAproximada,
    required super.sexo,
    required super.vacunaAplicada,
    required super.observaciones,
    super.fotoUrl,
    required super.latitud,
    required super.longitud,
    required super.fechaRegistro,
    required super.sectorId,
    required super.vacunadorId,
    required super.sincronizado,
  });

  factory VaccinationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaccinationModel(
      id: doc.id,
      propietarioNombre: data['propietarioNombre'] ?? '',
      propietarioCedula: data['propietarioCedula'] ?? '',
      telefono: data['telefono'] ?? '',
      tipoMascota: data['tipoMascota'] ?? '',
      nombreMascota: data['nombreMascota'] ?? '',
      edadAproximada: data['edadAproximada'] ?? '',
      sexo: data['sexo'] ?? '',
      vacunaAplicada: data['vacunaAplicada'] ?? '',
      observaciones: data['observaciones'] ?? '',
      fotoUrl: data['fotoUrl'],
      latitud: (data['latitud'] ?? 0.0).toDouble(),
      longitud: (data['longitud'] ?? 0.0).toDouble(),
      fechaRegistro: data['fechaRegistro'] != null
          ? (data['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
      sectorId: data['sectorId'] ?? '',
      vacunadorId: data['vacunadorId'] ?? '',
      sincronizado: data['sincronizado'] ?? true,
    );
  }

  /// Deserializa desde mapa JSON (almacenado en Hive como string JSON)
  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id'] ?? '',
      propietarioNombre: map['propietarioNombre'] ?? '',
      propietarioCedula: map['propietarioCedula'] ?? '',
      telefono: map['telefono'] ?? '',
      tipoMascota: map['tipoMascota'] ?? '',
      nombreMascota: map['nombreMascota'] ?? '',
      edadAproximada: map['edadAproximada'] ?? '',
      sexo: map['sexo'] ?? '',
      vacunaAplicada: map['vacunaAplicada'] ?? '',
      observaciones: map['observaciones'] ?? '',
      fotoUrl: map['fotoUrl'],
      latitud: (map['latitud'] ?? 0.0).toDouble(),
      longitud: (map['longitud'] ?? 0.0).toDouble(),
      fechaRegistro: map['fechaRegistro'] != null
          ? DateTime.parse(map['fechaRegistro'])
          : DateTime.now(),
      sectorId: map['sectorId'] ?? '',
      vacunadorId: map['vacunadorId'] ?? '',
      sincronizado: map['sincronizado'] ?? false,
    );
  }

  /// Serializa para subir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'propietarioNombre': propietarioNombre,
      'propietarioCedula': propietarioCedula,
      'telefono': telefono,
      'tipoMascota': tipoMascota,
      'nombreMascota': nombreMascota,
      'edadAproximada': edadAproximada,
      'sexo': sexo,
      'vacunaAplicada': vacunaAplicada,
      'observaciones': observaciones,
      'fotoUrl': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'sectorId': sectorId,
      'vacunadorId': vacunadorId,
      'sincronizado': true,
    };
  }

  /// Serializa a mapa JSON para almacenamiento local en Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propietarioNombre': propietarioNombre,
      'propietarioCedula': propietarioCedula,
      'telefono': telefono,
      'tipoMascota': tipoMascota,
      'nombreMascota': nombreMascota,
      'edadAproximada': edadAproximada,
      'sexo': sexo,
      'vacunaAplicada': vacunaAplicada,
      'observaciones': observaciones,
      'fotoUrl': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'sectorId': sectorId,
      'vacunadorId': vacunadorId,
      'sincronizado': sincronizado,
    };
  }

  factory VaccinationModel.fromEntity(VaccinationEntity entity) {
    return VaccinationModel(
      id: entity.id,
      propietarioNombre: entity.propietarioNombre,
      propietarioCedula: entity.propietarioCedula,
      telefono: entity.telefono,
      tipoMascota: entity.tipoMascota,
      nombreMascota: entity.nombreMascota,
      edadAproximada: entity.edadAproximada,
      sexo: entity.sexo,
      vacunaAplicada: entity.vacunaAplicada,
      observaciones: entity.observaciones,
      fotoUrl: entity.fotoUrl,
      latitud: entity.latitud,
      longitud: entity.longitud,
      fechaRegistro: entity.fechaRegistro,
      sectorId: entity.sectorId,
      vacunadorId: entity.vacunadorId,
      sincronizado: entity.sincronizado,
    );
  }
}
