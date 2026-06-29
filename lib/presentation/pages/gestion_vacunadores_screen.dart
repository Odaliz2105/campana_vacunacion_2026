import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/management_provider.dart';
import '../widgets/common_widgets.dart';

/// Pantalla para gestionar Vacunadores (Solo Coordinador de Brigada)
class GestionVacunadoresScreen extends StatefulWidget {
  const GestionVacunadoresScreen({super.key});

  @override
  State<GestionVacunadoresScreen> createState() => _GestionVacunadoresScreenState();
}

class _GestionVacunadoresScreenState extends State<GestionVacunadoresScreen> {
  String? _sectorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sectorId = context.read<AuthProvider>().currentUser?.sectorId;
      if (_sectorId != null) {
        context.read<ManagementProvider>().loadVacunadores(sectorId: _sectorId);
      }
    });
  }

  void _mostrarModalUsuario() {
    final formKey = GlobalKey<FormState>();
    final cedulaCtrl = TextEditingController();
    final nombresCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final mgmt = ctx.watch<ManagementProvider>();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuevo Vacunador',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Cédula',
                        controller: cedulaCtrl,
                        keyboardType: TextInputType.number,
                        validator: AppUtils.validateCedula,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Nombres',
                        controller: nombresCtrl,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Apellidos',
                        controller: apellidosCtrl,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Teléfono',
                        controller: telefonoCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Correo Electrónico',
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: AppUtils.validateEmail,
                      ),
                      const SizedBox(height: 24),
                      LoadingButton(
                        label: 'Crear Vacunador',
                        isLoading: mgmt.isLoading,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await mgmt.createUser(
                            email: emailCtrl.text.trim(),
                            cedula: cedulaCtrl.text.trim(),
                            nombres: nombresCtrl.text.trim(),
                            apellidos: apellidosCtrl.text.trim(),
                            telefono: telefonoCtrl.text.trim(),
                            rol: AppConstants.rolVacunador,
                            sectorId: _sectorId, // Asignado automáticamente al mismo sector
                          );
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mgmt.successMessage ?? 'Éxito'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mgmt.errorMessage ?? 'Error'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mgmt = context.watch<ManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacunadores de mi Sector'),
      ),
      body: mgmt.isLoading && mgmt.vacunadores.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : mgmt.vacunadores.isEmpty
              ? EmptyState(
                  icon: Icons.person_off,
                  title: 'Sin vacunadores',
                  message: 'Aún no se han registrado vacunadores en este sector.',
                  buttonLabel: 'Añadir Vacunador',
                  onButtonPressed: _mostrarModalUsuario,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: mgmt.vacunadores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = mgmt.vacunadores[index];
                    
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.accentLight,
                        child: Icon(Icons.medical_services, color: AppColors.accent),
                      ),
                      title: Text(
                        user.nombreCompleto,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user.email),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarModalUsuario,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
