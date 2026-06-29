import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/app_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

/// Pantalla de cambio obligatorio de contraseña (primer inicio de sesión)
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(_newPasswordController.text);
    if (!mounted) return;
    if (success) {
      _navigateToDashboard(auth.currentUser?.rol);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al cambiar contraseña'),
          backgroundColor: AppColors.error,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset, size: 42, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cambio de Contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Por seguridad, debe cambiar su contraseña inicial antes de continuar',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Formulario ──────────────────────────────────────
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
                        // ── Aviso de seguridad ─────────────────────
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Esta acción es obligatoria. No podrá acceder al sistema hasta cambiar su contraseña.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Requisitos ─────────────────────────────
                        const Text(
                          'Requisitos de la contraseña:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const _PasswordRequirement('Mínimo 8 caracteres'),
                        const _PasswordRequirement('Al menos una letra mayúscula'),
                        const _PasswordRequirement('Al menos un número'),
                        const _PasswordRequirement('No puede ser "Ecuador2026"'),
                        const SizedBox(height: 20),

                        // ── Nueva contraseña ───────────────────────
                        AppTextField(
                          label: 'Nueva contraseña',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscureNew,
                          controller: _newPasswordController,
                          suffix: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          validator: AppUtils.validateNewPassword,
                        ),
                        const SizedBox(height: 16),

                        // ── Confirmar contraseña ───────────────────
                        AppTextField(
                          label: 'Confirmar contraseña',
                          prefixIcon: Icons.lock_outlined,
                          obscureText: _obscureConfirm,
                          controller: _confirmController,
                          suffix: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          validator: (v) => AppUtils.validateConfirmPassword(
                            v,
                            _newPasswordController.text,
                          ),
                        ),
                        const SizedBox(height: 28),

                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => LoadingButton(
                            label: 'Cambiar Contraseña',
                            icon: Icons.check_circle,
                            isLoading: auth.isLoading,
                            onPressed: _changePassword,
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

class _PasswordRequirement extends StatelessWidget {
  final String text;
  const _PasswordRequirement(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
