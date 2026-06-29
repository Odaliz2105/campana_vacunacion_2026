import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import '../../core/services/device_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/vaccination_entity.dart';
import '../../domain/repositories/vaccination_repository.dart';

enum VaccinationState { initial, loading, success, error }

/// Provider de gestión de vacunaciones: registro, historial, sincronización y estadísticas
class VaccinationProvider extends ChangeNotifier {
  final VaccinationRepository _repo;
  final DeviceService _deviceService;
  final ConnectivityService _connectivity = ConnectivityService();

  VaccinationState _state = VaccinationState.initial;
  List<VaccinationEntity> _vaccinations = [];
  List<VaccinationEntity> _pendingVaccinations = [];
  Map<String, dynamic> _stats = {};
  String? _errorMessage;
  String? _successMessage;
  int _syncedCount = 0;
  StreamSubscription<bool>? _connectivitySubscription;

  VaccinationProvider(this._repo, this._deviceService) {
    _initConnectivityListener();
  }

  // ── Getters ───────────────────────────────────────────────────────
  VaccinationState get state => _state;
  List<VaccinationEntity> get vaccinations => _vaccinations;
  List<VaccinationEntity> get pendingVaccinations => _pendingVaccinations;
  Map<String, dynamic> get stats => _stats;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == VaccinationState.loading;
  int get syncedCount => _syncedCount;
  int get pendingCount => _pendingVaccinations.length;

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.connectivityStream.listen((hasConnection) async {
      if (hasConnection) {
        // Carga pendientes para estar seguro de lo que hay que sincronizar
        await loadPending();
        if (_pendingVaccinations.isNotEmpty && _state != VaccinationState.loading) {
          debugPrint('Conexión detectada. Sincronizando ${_pendingVaccinations.length} registros offline...');
          await syncPending();
        }
      }
    });
  }

  /// Carga todas las vacunaciones (respeta permisos según rol en el repositorio)
  Future<void> loadVaccinations({String? sectorId, String? vacunadorId}) async {
    _state = VaccinationState.loading;
    notifyListeners();
    try {
      if (sectorId != null) {
        _vaccinations = await _repo.getVaccinationsBySector(sectorId);
      } else if (vacunadorId != null) {
        _vaccinations = await _repo.getVaccinationsByVacunador(vacunadorId);
      } else {
        _vaccinations = await _repo.getAllVaccinations();
      }
      await loadPending();
      _state = VaccinationState.success;
    } catch (e) {
      _state = VaccinationState.error;
      _errorMessage = 'Error cargando registros: ${e.toString()}';
    }
    notifyListeners();
  }

  /// Carga estadísticas del dashboard
  Future<void> loadStats({String? sectorId}) async {
    try {
      _stats = sectorId != null
          ? await _repo.getStatsBySector(sectorId)
          : await _repo.getStats();
      notifyListeners();
    } catch (e) {
      // No bloquear la UI si las estadísticas fallan
    }
  }

  /// Carga los registros pendientes de sincronización
  Future<void> loadPending() async {
    _pendingVaccinations = await _repo.getPendingVaccinations();
    notifyListeners();
  }

  /// Guarda una nueva vacunación (online u offline automáticamente)
  Future<bool> saveVaccination({
    required VaccinationEntity vaccination,
    File? photoFile,
  }) async {
    _state = VaccinationState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final saved = await _repo.saveVaccination(
        vaccination: vaccination,
        photoFile: photoFile,
      );
      _vaccinations.insert(0, saved);
      if (!saved.sincronizado) {
        _pendingVaccinations.add(saved);
      }
      _state = VaccinationState.success;
      _successMessage = saved.sincronizado
          ? 'Vacunación registrada correctamente'
          : 'Vacunación guardada sin conexión. Se sincronizará automáticamente';
      notifyListeners();
      return true;
    } catch (e) {
      _state = VaccinationState.error;
      _errorMessage = 'Error al registrar: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Sincroniza los registros offline con Firebase
  Future<void> syncPending() async {
    _state = VaccinationState.loading;
    notifyListeners();
    try {
      _syncedCount = await _repo.syncPendingVaccinations();
      await loadPending();
      _state = VaccinationState.success;
      _successMessage = _syncedCount > 0
          ? '$_syncedCount registro(s) sincronizados correctamente'
          : 'No hay registros pendientes de sincronización';
    } catch (e) {
      _state = VaccinationState.error;
      _errorMessage = 'Error en sincronización: ${e.toString()}';
    }
    notifyListeners();
  }

  /// Actualiza un registro existente
  Future<bool> updateVaccination(VaccinationEntity vaccination) async {
    _state = VaccinationState.loading;
    notifyListeners();
    try {
      await _repo.updateVaccination(vaccination);
      final idx = _vaccinations.indexWhere((v) => v.id == vaccination.id);
      if (idx >= 0) _vaccinations[idx] = vaccination;
      _state = VaccinationState.success;
      _successMessage = 'Registro actualizado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _state = VaccinationState.error;
      _errorMessage = 'Error al actualizar: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
