import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/datasources/remote_firebase_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

/// Provider de autenticación: maneja el estado de sesión del usuario
class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo;
  final RemoteFirebaseDatasource _firebase;

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  String? _errorMessage;

  AuthProvider(this._userRepo, this._firebase) {
    _init();
  }

  // ── Getters ───────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get needsPasswordChange =>
      _currentUser != null && !_currentUser!.passwordChanged;

  /// Inicializa escuchando el estado de Auth de Firebase
  void _init() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user == null) {
          _status = AuthStatus.unauthenticated;
          _currentUser = null;
          notifyListeners();
        } else {
          await _loadUserProfile(user.uid);
        }
      });
    } catch (e) {
      // Firebase no está inicializado (falta flutterfire configure)
      _status = AuthStatus.error;
      _errorMessage = 'Firebase no configurado. Ejecute flutterfire configure.';
      notifyListeners();
      // Forzamos el estado a desautenticado para que el SplashScreen avance
      Future.delayed(const Duration(milliseconds: 500), () {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      });
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      _currentUser = await _userRepo.getUserById(uid);
      _status = _currentUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error cargando perfil de usuario';
    }
    notifyListeners();
  }

  /// Inicia sesión con email y contraseña
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _firebase.signIn(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseAuthError(e.code);
      notifyListeners();
      return false;
    }
  }

  /// Cambia la contraseña del usuario actual
  Future<bool> changePassword(String newPassword) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      await _firebase.updatePassword(newPassword);
      if (_currentUser != null) {
        await _userRepo.markPasswordChanged(_currentUser!.id);
        _currentUser = _currentUser!.copyWith(passwordChanged: true);
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Error al cambiar la contraseña: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Envía correo de recuperación de contraseña
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _firebase.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e.code);
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión
  Future<void> signOut() async {
    await _firebase.signOut();
  }

  /// Traduce los códigos de error de Firebase Auth a mensajes en español
  String _parseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intente más tarde';
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifique su red';
      default:
        return 'Error de autenticación ($code)';
    }
  }
}
