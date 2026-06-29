import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/app_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

/// Pantalla de inicio de sesión con soporte para recuperar contraseña
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      // El AuthProvider escucha authStateChanges; esperamos a que se cargue el perfil
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      final updatedAuth = context.read<AuthProvider>();
      if (updatedAuth.needsPasswordChange) {
        Navigator.pushReplacementNamed(context, AppRoutes.changePassword);
      } else {
        _navigateToDashboard(updatedAuth.currentUser?.rol);
      }
    } else {
      _showError(auth.errorMessage ?? 'Error al iniciar sesión');
    }
  }

  void _navigateToDashboard(String? rol) {
    switch (rol) {
      case AppConstants.rolCoordinadorCampana:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardCoordinadorCampana);
        break;
      case AppConstants.rolCoordinadorBrigada:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardCoordinadorBrigada);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardVacunador);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header verde/azul ───────────────────────────────
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.vaccines, size: 70, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Vacunación Canina y Felina',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Campaña Municipal 2026  🐕🐈',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tarjeta de login ────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Iniciar Sesión',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ingrese sus credenciales institucionales',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 28),

                        // ── Email ──────────────────────────────────
                        AppTextField(
                          label: 'Correo electrónico',
                          hint: 'usuario@municipio.gob.ec',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: AppUtils.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // ── Contraseña ─────────────────────────────
                        AppTextField(
                          label: 'Contraseña',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'La contraseña es requerida'
                              : null,
                        ),
                        const SizedBox(height: 8),

                        // ── Olvidé contraseña ──────────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.forgotPassword,
                            ),
                            child: const Text('¿Olvidó su contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ── Botón Ingresar ─────────────────────────
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => LoadingButton(
                            label: 'Ingresar al Sistema',
                            icon: Icons.login,
                            isLoading: auth.isLoading,
                            onPressed: _login,
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        // ── Nota informativa ───────────────────────
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryLight),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Los usuarios son creados por el Coordinador de Campaña. '
                                  'Si es su primer acceso, use la contraseña inicial "Ecuador2026".',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
