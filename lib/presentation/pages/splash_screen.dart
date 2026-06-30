import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

/// Pantalla de carga inicial con verificación del estado de sesión
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Navegar después del tiempo de splash
    Future.delayed(
      const Duration(seconds: AppConstants.splashDurationSeconds + 1),
      _navigate,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    switch (authProvider.status) {
      case AuthStatus.authenticated:
        // TODO: Reactivar cambio de contraseña obligatorio en producción
        // if (authProvider.needsPasswordChange) {
        //   Navigator.pushReplacementNamed(context, AppRoutes.changePassword);
        // } else {
        _navigateToDashboard(authProvider.currentUser?.rol);
        // }
        break;
      case AuthStatus.unauthenticated:
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _navigateToDashboard(String? rol) {
    switch (rol) {
      case AppConstants.rolCoordinadorCampana:
      case 'Administrador':
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardCoordinadorCampana);
        break;
      case AppConstants.rolCoordinadorBrigada:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardCoordinadorBrigada);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardVacunador);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo/Ícono ──────────────────────────────────
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.vaccines,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Título ──────────────────────────────────────
                    const Text(
                      'Campaña de Vacunación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Canina y Felina 2026',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🐕 🐈',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 60),

                    // ── Indicador de carga ──────────────────────────
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Iniciando sistema...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
