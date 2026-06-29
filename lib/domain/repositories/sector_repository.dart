import '../../domain/entities/sector_entity.dart';

/// Contrato abstracto del repositorio de sectores
abstract class SectorRepository {
  /// Obtiene todos los sectores de la campaña
  Future<List<SectorEntity>> getAllSectors();

  /// Obtiene un sector por su ID
  Future<SectorEntity?> getSectorById(String sectorId);

  /// Crea un nuevo sector
  Future<SectorEntity> createSector({
    required String nombre,
    required String descripcion,
  });

  /// Actualiza un sector existente
  Future<void> updateSector(SectorEntity sector);

  /// Elimina un sector
  Future<void> deleteSector(String sectorId);
}
