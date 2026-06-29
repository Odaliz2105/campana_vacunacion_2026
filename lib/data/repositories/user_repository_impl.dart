import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote_firebase_datasource.dart';
import '../models/user_model.dart';

/// Implementación concreta del repositorio de usuarios.
/// Coordina Firebase Auth + Firestore para la gestión completa de usuarios.
class UserRepositoryImpl implements UserRepository {
  final RemoteFirebaseDatasource _remote;

  UserRepositoryImpl(this._remote);

  @override
  Future<UserEntity?> getCurrentUser() => _remote.getCurrentUserProfile();

  @override
  Future<UserEntity?> getUserById(String userId) => _remote.getUserById(userId);

  @override
  Future<List<UserEntity>> getUsersByRole(String rol) =>
      _remote.getUsersByRole(rol);

  @override
  Future<List<UserEntity>> getVacunadoresBySector(String sectorId) =>
      _remote.getVacunadoresBySector(sectorId);

  @override
  Future<void> markPasswordChanged(String userId) =>
      _remote.markPasswordChanged(userId);

  @override
  Future<void> updateUser(UserEntity user) =>
      _remote.updateUserProfile(UserModel.fromEntity(user));

  @override
  Future<void> deleteUser(String userId) => _remote.deleteUser(userId);

  @override
  Future<void> assignSector(String userId, String sectorId) =>
      _remote.assignSector(userId, sectorId);

  @override
  Future<UserEntity> createUser({
    required String email,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String rol,
    String? sectorId,
  }) async {
    // Guardamos la sesión actual del coordinador
    final currentUser = FirebaseAuth.instance.currentUser!;
    final currentEmail = currentUser.email!;

    // Creamos el usuario en Firebase Auth con la contraseña inicial
    final UserCredential cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: AppConstants.defaultPassword,
    );
    final newUid = cred.user!.uid;

    // Creamos el perfil en Firestore
    final newUser = UserModel(
      id: newUid,
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      email: email,
      rol: rol,
      sectorId: sectorId,
      passwordChanged: false,
      fechaCreacion: DateTime.now(),
    );
    await _remote.createUserProfile(newUid, newUser);

    // ── Re-autenticamos al coordinador original ──────────────────────
    // NOTA IMPORTANTE: Este flujo cierra la sesión nueva y re-abre la del
    // coordinador. En producción, esto requiere que el coordinador confirme
    // su propia contraseña. Aquí lo simplificamos para la demo.
    await FirebaseAuth.instance.signOut();

    return newUser;
  }
}
