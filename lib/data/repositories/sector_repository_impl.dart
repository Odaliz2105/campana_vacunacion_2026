import '../../domain/entities/sector_entity.dart';
import '../../domain/repositories/sector_repository.dart';
import '../datasources/remote_firebase_datasource.dart';
import '../models/sector_model.dart';

/// Implementación del repositorio de sectores
class SectorRepositoryImpl implements SectorRepository {
  final RemoteFirebaseDatasource _remote;

  SectorRepositoryImpl(this._remote);

  @override
  Future<List<SectorEntity>> getAllSectors() => _remote.getAllSectors();

  @override
  Future<SectorEntity?> getSectorById(String sectorId) =>
      _remote.getSectorById(sectorId);

  @override
  Future<SectorEntity> createSector({
    required String nombre,
    required String descripcion,
  }) async {
    final tempSector = SectorModel(
      id: '',
      nombre: nombre,
      descripcion: descripcion,
      fechaCreacion: DateTime.now(),
    );
    final newId = await _remote.createSector(tempSector);
    return tempSector.copyWith(id: newId);
  }

  @override
  Future<void> updateSector(SectorEntity sector) =>
      _remote.updateSector(SectorModel.fromEntity(sector));

  @override
  Future<void> deleteSector(String sectorId) =>
      _remote.deleteSector(sectorId);
}
