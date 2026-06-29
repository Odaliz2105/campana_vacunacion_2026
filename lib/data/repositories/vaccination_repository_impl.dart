import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/vaccination_entity.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../datasources/local_vaccination_datasource.dart';
import '../datasources/remote_firebase_datasource.dart';
import '../models/vaccination_model.dart';

/// Implementación del repositorio de vacunaciones con lógica offline-first.
/// Si hay conexión → guarda en Firestore + Storage.
/// Si no hay conexión → guarda en Hive con sincronizado=false.
class VaccinationRepositoryImpl implements VaccinationRepository {
  final RemoteFirebaseDatasource _remote;
  final LocalVaccinationDatasource _local;
  final ConnectivityService _connectivity;
  final _uuid = const Uuid();

  VaccinationRepositoryImpl(this._remote, this._local, this._connectivity);

  @override
  Future<VaccinationEntity> saveVaccination({
    required VaccinationEntity vaccination,
    File? photoFile,
  }) async {
    final hasInternet = await _connectivity.hasConnection();
    final id = _uuid.v4();

    if (hasInternet) {
      // ── Con conexión: subir foto y guardar en Firestore ─────────────
      String? fotoUrl;
      if (photoFile != null) {
        final fileName = 'vac_${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        fotoUrl = await _remote.uploadPhoto(photoFile, fileName);
      }
      final model = VaccinationModel.fromEntity(
        vaccination.copyWith(id: id, fotoUrl: fotoUrl, sincronizado: true),
      );
      final firestoreId = await _remote.saveVaccinationToFirestore(model);
      // También guardamos en local con sincronizado=true para el historial offline
      await _local.saveVaccination(
        VaccinationModel.fromEntity(model.copyWith(id: firestoreId, sincronizado: true)),
      );
      return model.copyWith(id: firestoreId);
    } else {
      // ── Sin conexión: guardar en Hive con ruta local de foto ─────────
      final fotoLocalPath = photoFile?.path;
      final model = VaccinationModel.fromEntity(
        vaccination.copyWith(
          id: id,
          fotoUrl: fotoLocalPath,
          sincronizado: false,
        ),
      );
      await _local.saveVaccination(model);
      return model;
    }
  }

  @override
  Future<List<VaccinationEntity>> getAllVaccinations() async {
    final hasInternet = await _connectivity.hasConnection();
    if (hasInternet) {
      return _remote.getAllVaccinations();
    }
    return _local.getAllLocalVaccinations();
  }

  @override
  Future<List<VaccinationEntity>> getVaccinationsBySector(String sectorId) async {
    final hasInternet = await _connectivity.hasConnection();
    if (hasInternet) {
      return _remote.getVaccinationsBySector(sectorId);
    }
    return _local.getAllLocalVaccinations()
        .where((v) => v.sectorId == sectorId)
        .toList();
  }

  @override
  Future<List<VaccinationEntity>> getVaccinationsByVacunador(String vacunadorId) async {
    final hasInternet = await _connectivity.hasConnection();
    if (hasInternet) {
      return _remote.getVaccinationsByVacunador(vacunadorId);
    }
    return _local.getAllLocalVaccinations()
        .where((v) => v.vacunadorId == vacunadorId)
        .toList();
  }

  @override
  Future<List<VaccinationEntity>> getPendingVaccinations() async {
    return _local.getPendingVaccinations();
  }

  @override
  Future<int> syncPendingVaccinations() async {
    final hasInternet = await _connectivity.hasConnection();
    if (!hasInternet) return 0;

    final pending = _local.getPendingVaccinations();
    int synced = 0;

    for (final vaccination in pending) {
      try {
        String? fotoUrl = vaccination.fotoUrl;

        // Si la fotoUrl apunta a un archivo local, subirla primero
        if (fotoUrl != null && fotoUrl.startsWith('/')) {
          final file = File(fotoUrl);
          if (await file.exists()) {
            final fileName = 'vac_${vaccination.id}_sync.jpg';
            fotoUrl = await _remote.uploadPhoto(file, fileName);
          }
        }

        final model = VaccinationModel.fromEntity(
          vaccination.copyWith(fotoUrl: fotoUrl, sincronizado: true),
        );
        await _remote.saveVaccinationToFirestore(model);
        await _local.markAsSynced(vaccination.id);
        synced++;
      } catch (e) {
        // Continuar con el siguiente si uno falla
        continue;
      }
    }
    return synced;
  }

  @override
  Future<void> updateVaccination(VaccinationEntity vaccination) =>
      _remote.updateVaccination(VaccinationModel.fromEntity(vaccination));

  @override
  Future<void> deleteVaccination(String vaccinationId) =>
      _remote.deleteVaccination(vaccinationId);

  @override
  Future<Map<String, dynamic>> getStats() async {
    final vaccinations = await _remote.getAllVaccinations();
    return _calculateStats(vaccinations);
  }

  @override
  Future<Map<String, dynamic>> getStatsBySector(String sectorId) async {
    final vaccinations = await _remote.getVaccinationsBySector(sectorId);
    return _calculateStats(vaccinations);
  }

  Map<String, dynamic> _calculateStats(List<VaccinationModel> vaccinations) {
    final total = vaccinations.length;
    final caninos = vaccinations.where((v) => v.isCanino).length;
    final felinos = vaccinations.where((v) => v.isFelino).length;
    final pending = _local.pendingCount;

    // Agrupar por sector
    final Map<String, int> porSector = {};
    for (final v in vaccinations) {
      porSector[v.sectorId] = (porSector[v.sectorId] ?? 0) + 1;
    }

    // Agrupar por vacunador
    final Map<String, int> porVacunador = {};
    for (final v in vaccinations) {
      porVacunador[v.vacunadorId] = (porVacunador[v.vacunadorId] ?? 0) + 1;
    }

    return {
      'total': total,
      'caninos': caninos,
      'felinos': felinos,
      'pendientes': pending,
      'porSector': porSector,
      'porVacunador': porVacunador,
    };
  }
}
