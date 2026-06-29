import '../../domain/entities/user_entity.dart';

/// Contrato abstracto del repositorio de usuarios.
/// La capa de presentación depende de esta interfaz, no de la implementación concreta.
abstract class UserRepository {
  /// Crea una nueva cuenta de usuario en Firebase Auth y Firestore
  Future<UserEntity> createUser({
    required String email,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String rol,
    String? sectorId,
  });

  /// Obtiene el perfil del usuario actualmente autenticado
  Future<UserEntity?> getCurrentUser();

  /// Obtiene un usuario por su ID
  Future<UserEntity?> getUserById(String userId);

  /// Obtiene todos los usuarios con un rol específico
  Future<List<UserEntity>> getUsersByRole(String rol);

  /// Obtiene todos los vacunadores asignados a un sector
  Future<List<UserEntity>> getVacunadoresBySector(String sectorId);

  /// Actualiza el perfil de un usuario
  Future<void> updateUser(UserEntity user);

  /// Marca la contraseña como cambiada
  Future<void> markPasswordChanged(String userId);

  /// Elimina un usuario (del sistema de auth y Firestore)
  Future<void> deleteUser(String userId);

  /// Asigna un sector a un usuario
  Future<void> assignSector(String userId, String sectorId);
}
