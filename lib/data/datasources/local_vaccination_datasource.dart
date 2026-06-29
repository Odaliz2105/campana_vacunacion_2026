import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/vaccination_model.dart';

/// Fuente de datos local usando Hive para persistencia offline de vacunaciones.
/// Almacena los registros como JSON strings en un Box de Hive.
class LocalVaccinationDatasource {
  Box<String> get _box => Hive.box<String>(AppConstants.hiveBoxVaccinations);

  /// Guarda un registro de vacunación localmente
  Future<void> saveVaccination(VaccinationModel vaccination) async {
    final jsonString = jsonEncode(vaccination.toMap());
    await _box.put(vaccination.id, jsonString);
  }

  /// Obtiene todos los registros locales pendientes de sincronización
  List<VaccinationModel> getPendingVaccinations() {
    return _box.values.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return VaccinationModel.fromMap(map);
    }).where((v) => !v.sincronizado).toList();
  }

  /// Obtiene todos los registros locales
  List<VaccinationModel> getAllLocalVaccinations() {
    return _box.values.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return VaccinationModel.fromMap(map);
    }).toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  /// Marca un registro local como sincronizado
  Future<void> markAsSynced(String vaccinationId) async {
    final jsonStr = _box.get(vaccinationId);
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      map['sincronizado'] = true;
      await _box.put(vaccinationId, jsonEncode(map));
    }
  }

  /// Elimina un registro local (tras sincronización exitosa)
  Future<void> deleteLocal(String vaccinationId) async {
    await _box.delete(vaccinationId);
  }

  /// Limpia todos los registros ya sincronizados del box local
  Future<void> clearSynced() async {
    final toDelete = _box.keys.where((key) {
      final jsonStr = _box.get(key as String);
      if (jsonStr == null) return false;
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map['sincronizado'] == true;
    }).toList();
    for (final key in toDelete) {
      await _box.delete(key);
    }
  }

  /// Cuenta total de registros pendientes
  int get pendingCount => getPendingVaccinations().length;
}
