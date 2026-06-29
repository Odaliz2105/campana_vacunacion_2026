import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

/// Pantalla de recuperación de contraseña mediante correo electrónico
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailController.text.trim());
    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al enviar correo'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.email_outlined, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Olvidó su contraseña?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ingrese su correo electrónico y le enviaremos un enlace para restablecer su contraseña.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'Correo electrónico',
            hint: 'usuario@municipio.gob.ec',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: AppUtils.validateEmail,
          ),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(
            builder: (_, auth, __) => LoadingButton(
              label: 'Enviar Correo de Recuperación',
              icon: Icons.send,
              isLoading: auth.isLoading,
              onPressed: _sendReset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read, size: 52, color: AppColors.success),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Correo Enviado!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Revise su bandeja de entrada en\n${_emailController.text}\ny siga las instrucciones para restablecer su contraseña.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al Login'),
          ),
        ],
      ),
    );
  }
}
