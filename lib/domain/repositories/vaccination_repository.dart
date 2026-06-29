import 'dart:io';
import '../../domain/entities/vaccination_entity.dart';

/// Contrato abstracto del repositorio de vacunaciones.
/// Gestiona la lógica híbrida: offline (Hive) + online (Firestore + Storage)
abstract class VaccinationRepository {
  /// Guarda una vacunación. Si hay conexión va a Firestore; si no, queda en Hive.
  Future<VaccinationEntity> saveVaccination({
    required VaccinationEntity vaccination,
    File? photoFile,
  });

  /// Obtiene todos los registros de vacunación (Firestore)
  Future<List<VaccinationEntity>> getAllVaccinations();

  /// Obtiene vacunaciones de un sector específico
  Future<List<VaccinationEntity>> getVaccinationsBySector(String sectorId);

  /// Obtiene vacunaciones registradas por un vacunador específico
  Future<List<VaccinationEntity>> getVaccinationsByVacunador(String vacunadorId);

  /// Obtiene los registros offline pendientes de sincronización (Hive)
  Future<List<VaccinationEntity>> getPendingVaccinations();

  /// Sincroniza todos los registros offline pendientes con Firestore
  Future<int> syncPendingVaccinations();

  /// Actualiza un registro de vacunación existente
  Future<void> updateVaccination(VaccinationEntity vaccination);

  /// Elimina un registro de vacunación
  Future<void> deleteVaccination(String vaccinationId);

  /// Retorna estadísticas globales de la campaña
  Future<Map<String, dynamic>> getStats();

  /// Retorna estadísticas de un sector específico
  Future<Map<String, dynamic>> getStatsBySector(String sectorId);
}
