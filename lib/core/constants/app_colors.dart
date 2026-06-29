import 'package:flutter/material.dart';

/// Paleta de colores institucional de la Campaña de Vacunación
class AppColors {
  AppColors._();

  // ── Colores primarios institucionales ──────────────────────────────
  static const Color primary = Color(0xFF1B5E20);       // Verde oscuro institucional
  static const Color primaryLight = Color(0xFF4CAF50);  // Verde medio
  static const Color primaryDark = Color(0xFF003300);   // Verde muy oscuro

  static const Color secondary = Color(0xFF0D47A1);     // Azul institucional
  static const Color secondaryLight = Color(0xFF1976D2); // Azul medio
  static const Color secondaryDark = Color(0xFF002171); // Azul oscuro

  // ── Colores de acento y estado ────────────────────────────────────
  static const Color accent = Color(0xFF00BFA5);        // Verde azulado
  static const Color accentLight = Color(0xFF1DE9B6);   // Verde azulado claro
  static const Color accentDark = Color(0xFF00897B);    // Verde azulado oscuro
  static const Color warning = Color(0xFFF57F17);       // Naranja advertencia
  static const Color error = Color(0xFFC62828);         // Rojo error
  static const Color success = Color(0xFF2E7D32);       // Verde éxito
  static const Color pending = Color(0xFFF9A825);       // Amarillo pendiente

  // ── Colores de fondo y superficie ────────────────────────────────
  static const Color background = Color(0xFFF1F8E9);    // Fondo verde muy claro
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8F5E9); // Verde muy claro

  // ── Colores de texto ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF9E9E9E);

  // ── Colores para tarjetas estadísticas del Dashboard ─────────────
  static const Color statCardPerro = Color(0xFF1565C0);   // Azul para perros
  static const Color statCardGato = Color(0xFF6A1B9A);    // Morado para gatos
  static const Color statCardTotal = Color(0xFF2E7D32);   // Verde para total
  static const Color statCardPending = Color(0xFFE65100); // Naranja para pendientes

  // ── Gradiente institucional ───────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
