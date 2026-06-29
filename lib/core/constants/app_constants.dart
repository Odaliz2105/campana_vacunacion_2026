/// Constantes de texto y configuración general de la aplicación
class AppConstants {
  AppConstants._();

  // ── Información de la App ─────────────────────────────────────────
  static const String appName = 'Vacunación Canina y Felina 2026';
  static const String appVersion = '1.0.0';
  static const String defaultPassword = 'Ecuador2026';
  static const String campanaYear = '2026';

  // ── Roles del sistema ─────────────────────────────────────────────
  static const String rolCoordinadorCampana = 'Coordinador de Campaña';
  static const String rolCoordinadorBrigada = 'Coordinador de Brigada';
  static const String rolVacunador = 'Vacunador';

  static const List<String> allRoles = [
    rolCoordinadorCampana,
    rolCoordinadorBrigada,
    rolVacunador,
  ];

  // ── Tipos de mascota ──────────────────────────────────────────────
  static const String tipoCanino = 'Canino';
  static const String tipoFelino = 'Felino';

  static const List<String> tiposMascota = [tipoCanino, tipoFelino];

  // ── Sexo de mascota ───────────────────────────────────────────────
  static const String sexoMacho = 'Macho';
  static const String sexoHembra = 'Hembra';

  static const List<String> sexosMascota = [sexoMacho, sexoHembra];

  // ── Vacunas disponibles ───────────────────────────────────────────
  static const List<String> vacunasDisponibles = [
    'Antirrábica',
    'Parvovirus (Canino)',
    'Moquillo (Canino)',
    'Hepatitis Infecciosa (Canino)',
    'Leptospirosis (Canino)',
    'Polivalente Felina',
    'Leucemia Felina (FeLV)',
    'Calicivirus (Felino)',
    'Rinotraqueitis (Felino)',
  ];

  // ── Colecciones de Firestore ──────────────────────────────────────
  static const String colUsers = 'users';
  static const String colSectors = 'sectors';
  static const String colVaccinations = 'vaccinations';

  // ── Claves Hive (almacenamiento local offline) ────────────────────
  static const String hiveBoxVaccinations = 'offline_vaccinations';
  static const String hiveBoxUser = 'current_user';

  // ── Claves de preferencias ────────────────────────────────────────
  static const String prefUserRole = 'user_role';
  static const String prefUserId = 'user_id';
  static const String prefPasswordChanged = 'password_changed';

  // ── Duración splash screen ────────────────────────────────────────
  static const int splashDurationSeconds = 2;
}
