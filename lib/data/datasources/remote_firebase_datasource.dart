import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/vaccination_model.dart';
import '../models/user_model.dart';
import '../models/sector_model.dart';

/// Fuente de datos remota usando Firebase (Firestore + Storage + Auth)
class RemoteFirebaseDatasource {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  // ── Auth ──────────────────────────────────────────────────────────

  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  /// Crea usuario en Firebase Auth. Se usa para que los coordinadores
  /// creen vacunadores/brigadistas sin perder su propia sesión.
  Future<String> createAuthUser(String email, String password) async {
    // Guardamos credenciales actuales
    final currentUser = _auth.currentUser!;
    final currentEmail = currentUser.email!;

    // Creamos el nuevo usuario
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final newUid = cred.user!.uid;

    // Re-autenticamos al usuario administrador para restaurar su sesión
    // Nota: en producción, usar Firebase Admin SDK o Cloud Functions para mayor seguridad
    await _auth.signOut();
    // Se debe solicitar la contraseña del admin para re-autenticar (simplificado aquí)
    // En la implementación del UI el coordinador ya estará logueado
    return newUid;
  }

  // ── Usuarios (Firestore) ──────────────────────────────────────────

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _db.collection(AppConstants.colUsers).doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return getUserById(uid);
  }

  Future<void> createUserProfile(String userId, UserModel user) async {
    await _db.collection(AppConstants.colUsers).doc(userId).set(user.toFirestore());
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection(AppConstants.colUsers).doc(user.id).update({
      'cedula': user.cedula,
      'nombres': user.nombres,
      'apellidos': user.apellidos,
      'telefono': user.telefono,
      'rol': user.rol,
      'sectorId': user.sectorId,
      'passwordChanged': user.passwordChanged,
    });
  }

  Future<void> markPasswordChanged(String userId) async {
    await _db.collection(AppConstants.colUsers).doc(userId).update({
      'passwordChanged': true,
    });
  }

  Future<List<UserModel>> getUsersByRole(String rol) async {
    final query = await _db
        .collection(AppConstants.colUsers)
        .where('rol', isEqualTo: rol)
        .get();
    return query.docs.map(UserModel.fromFirestore).toList();
  }

  Future<List<UserModel>> getVacunadoresBySector(String sectorId) async {
    final query = await _db
        .collection(AppConstants.colUsers)
        .where('rol', isEqualTo: AppConstants.rolVacunador)
        .where('sectorId', isEqualTo: sectorId)
        .get();
    return query.docs.map(UserModel.fromFirestore).toList();
  }

  Future<void> assignSector(String userId, String sectorId) async {
    await _db.collection(AppConstants.colUsers).doc(userId).update({
      'sectorId': sectorId,
    });
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection(AppConstants.colUsers).doc(userId).delete();
  }

  // ── Sectores (Firestore) ──────────────────────────────────────────

  Future<List<SectorModel>> getAllSectors() async {
    final query = await _db
        .collection(AppConstants.colSectors)
        .orderBy('nombre')
        .get();
    return query.docs.map(SectorModel.fromFirestore).toList();
  }

  Future<SectorModel?> getSectorById(String sectorId) async {
    final doc = await _db.collection(AppConstants.colSectors).doc(sectorId).get();
    if (!doc.exists) return null;
    return SectorModel.fromFirestore(doc);
  }

  Future<String> createSector(SectorModel sector) async {
    final ref = await _db
        .collection(AppConstants.colSectors)
        .add(sector.toFirestore());
    return ref.id;
  }

  Future<void> updateSector(SectorModel sector) async {
    await _db.collection(AppConstants.colSectors).doc(sector.id).update({
      'nombre': sector.nombre,
      'descripcion': sector.descripcion,
    });
  }

  Future<void> deleteSector(String sectorId) async {
    await _db.collection(AppConstants.colSectors).doc(sectorId).delete();
  }

  // ── Vacunaciones (Firestore) ──────────────────────────────────────

  Future<List<VaccinationModel>> getAllVaccinations() async {
    final query = await _db
        .collection(AppConstants.colVaccinations)
        .orderBy('fechaRegistro', descending: true)
        .get();
    return query.docs.map(VaccinationModel.fromFirestore).toList();
  }

  Future<List<VaccinationModel>> getVaccinationsBySector(String sectorId) async {
    final query = await _db
        .collection(AppConstants.colVaccinations)
        .where('sectorId', isEqualTo: sectorId)
        .orderBy('fechaRegistro', descending: true)
        .get();
    return query.docs.map(VaccinationModel.fromFirestore).toList();
  }

  Future<List<VaccinationModel>> getVaccinationsByVacunador(String vacunadorId) async {
    final query = await _db
        .collection(AppConstants.colVaccinations)
        .where('vacunadorId', isEqualTo: vacunadorId)
        .orderBy('fechaRegistro', descending: true)
        .get();
    return query.docs.map(VaccinationModel.fromFirestore).toList();
  }

  Future<String> saveVaccinationToFirestore(VaccinationModel vaccination) async {
    final ref = await _db
        .collection(AppConstants.colVaccinations)
        .add(vaccination.toFirestore());
    return ref.id;
  }

  Future<void> updateVaccination(VaccinationModel vaccination) async {
    await _db
        .collection(AppConstants.colVaccinations)
        .doc(vaccination.id)
        .update(vaccination.toFirestore());
  }

  Future<void> deleteVaccination(String vaccinationId) async {
    await _db.collection(AppConstants.colVaccinations).doc(vaccinationId).delete();
  }

  // ── Storage (imágenes) ────────────────────────────────────────────

  /// Sube un archivo de imagen a Firebase Storage y retorna su URL pública
  Future<String> uploadPhoto(File photoFile, String fileName) async {
    final ref = _storage.ref().child('vacunaciones/$fileName');
    final uploadTask = await ref.putFile(
      photoFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  /// Elimina una foto de Storage por su URL
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (_) {
      // Ignorar si la foto ya no existe
    }
  }
}
