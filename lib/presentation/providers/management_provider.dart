import 'package:flutter/foundation.dart';
import '../../domain/entities/sector_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/sector_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/constants/app_constants.dart';

enum ManagementState { initial, loading, success, error }

/// Provider de gestión administrativa (sectores y usuarios)
class ManagementProvider extends ChangeNotifier {
  final SectorRepository _sectorRepo;
  final UserRepository _userRepo;

  ManagementState _state = ManagementState.initial;
  List<SectorEntity> _sectors = [];
  List<UserEntity> _coordinadores = [];
  List<UserEntity> _vacunadores = [];
  String? _errorMessage;
  String? _successMessage;

  ManagementProvider(this._sectorRepo, this._userRepo);

  // ── Getters ───────────────────────────────────────────────────────
  ManagementState get state => _state;
  List<SectorEntity> get sectors => _sectors;
  List<UserEntity> get coordinadores => _coordinadores;
  List<UserEntity> get vacunadores => _vacunadores;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == ManagementState.loading;

  // ── SECTORES ──────────────────────────────────────────────────────

  Future<void> loadSectors() async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      _sectors = await _sectorRepo.getAllSectors();
      _state = ManagementState.success;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error cargando sectores';
    }
    notifyListeners();
  }

  Future<bool> createSector(String nombre, String descripcion) async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      final sector = await _sectorRepo.createSector(
        nombre: nombre,
        descripcion: descripcion,
      );
      _sectors.add(sector);
      _state = ManagementState.success;
      _successMessage = 'Sector "$nombre" creado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error al crear sector: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSector(SectorEntity sector) async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      await _sectorRepo.updateSector(sector);
      final idx = _sectors.indexWhere((s) => s.id == sector.id);
      if (idx >= 0) _sectors[idx] = sector;
      _state = ManagementState.success;
      _successMessage = 'Sector actualizado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error al actualizar sector';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSector(String sectorId) async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      await _sectorRepo.deleteSector(sectorId);
      _sectors.removeWhere((s) => s.id == sectorId);
      _state = ManagementState.success;
      _successMessage = 'Sector eliminado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error al eliminar sector';
      notifyListeners();
      return false;
    }
  }

  // ── USUARIOS ──────────────────────────────────────────────────────

  Future<void> loadCoordinadores() async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      _coordinadores = await _userRepo.getUsersByRole(AppConstants.rolCoordinadorBrigada);
      _state = ManagementState.success;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error cargando coordinadores';
    }
    notifyListeners();
  }

  Future<void> loadVacunadores({String? sectorId}) async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      if (sectorId != null) {
        _vacunadores = await _userRepo.getVacunadoresBySector(sectorId);
      } else {
        _vacunadores = await _userRepo.getUsersByRole(AppConstants.rolVacunador);
      }
      _state = ManagementState.success;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error cargando vacunadores';
    }
    notifyListeners();
  }

  Future<bool> createUser({
    required String email,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String rol,
    String? sectorId,
  }) async {
    _state = ManagementState.loading;
    notifyListeners();
    try {
      final user = await _userRepo.createUser(
        email: email,
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        rol: rol,
        sectorId: sectorId,
      );
      if (rol == AppConstants.rolCoordinadorBrigada) {
        _coordinadores.add(user);
      } else {
        _vacunadores.add(user);
      }
      _state = ManagementState.success;
      _successMessage = 'Usuario "$nombres $apellidos" creado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _state = ManagementState.error;
      _errorMessage = 'Error al crear usuario: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignSector(String userId, String sectorId) async {
    try {
      await _userRepo.assignSector(userId, sectorId);
      _successMessage = 'Sector asignado correctamente';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al asignar sector';
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
