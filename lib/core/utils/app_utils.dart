import 'package:intl/intl.dart';

/// Utilidades de validación y formateo
class AppUtils {
  AppUtils._();

  // ── Formateo de fechas ────────────────────────────────────────────

  /// Retorna fecha formateada como "25 jun 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }

  /// Retorna fecha y hora como "25/06/2026 15:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es').format(date);
  }

  // ── Validadores ───────────────────────────────────────────────────

  /// Valida que el campo no esté vacío
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Valida formato de email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  /// Valida contraseña (mínimo 8 caracteres, mayúscula, número)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  /// Valida que la nueva contraseña no sea la predeterminada
  static String? validateNewPassword(String? value) {
    final basicValidation = validatePassword(value);
    if (basicValidation != null) return basicValidation;
    if (value == 'Ecuador2026') {
      return 'No puede usar la contraseña temporal inicial';
    }
    return null;
  }

  /// Valida confirmación de contraseña
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirme la contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida cédula ecuatoriana (10 dígitos, algoritmo módulo 10)
  static String? validateCedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cédula es requerida';
    }
    final cedula = value.trim();
    if (cedula.length != 10) {
      return 'La cédula debe tener 10 dígitos';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(cedula)) {
      return 'La cédula solo debe contener números';
    }
    // Algoritmo de validación de cédula ecuatoriana
    final digits = cedula.split('').map(int.parse).toList();
    if (digits[0] > 6) return 'Cédula inválida';
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int val = digits[i];
      if (i.isEven) {
        val *= 2;
        if (val > 9) val -= 9;
      }
      sum += val;
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    if (checkDigit != digits[9]) return 'Cédula inválida';
    return null;
  }

  /// Valida número de teléfono ecuatoriano (10 dígitos, empieza con 09 o 02-07)
  static String? validateTelefono(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    final tel = value.trim().replaceAll(' ', '');
    if (!RegExp(r'^\d{10}$').hasMatch(tel)) {
      return 'Ingrese un teléfono válido de 10 dígitos';
    }
    return null;
  }

  // ── Formateo de coordenadas GPS ───────────────────────────────────

  /// Formatea coordenada a 6 decimales
  static String formatCoordinate(double coord) {
    return coord.toStringAsFixed(6);
  }

  /// Formatea latitud/longitud para mostrar al usuario
  static String formatGPS(double lat, double lng) {
    return '${formatCoordinate(lat)}, ${formatCoordinate(lng)}';
  }
}
