import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../providers/management_provider.dart';
import '../widgets/common_widgets.dart';

/// Pantalla para gestionar Coordinadores de Brigada (Solo Coordinador de Campaña)
class GestionCoordinadoresScreen extends StatefulWidget {
  const GestionCoordinadoresScreen({super.key});

  @override
  State<GestionCoordinadoresScreen> createState() => _GestionCoordinadoresScreenState();
}

class _GestionCoordinadoresScreenState extends State<GestionCoordinadoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementProvider>().loadCoordinadores();
      context.read<ManagementProvider>().loadSectors();
    });
  }

  void _mostrarModalUsuario() {
    final formKey = GlobalKey<FormState>();
    final cedulaCtrl = TextEditingController();
    final nombresCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String? selectedSectorId;

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
                        'Nuevo Coordinador de Brigada',
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
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedSectorId,
                        decoration: const InputDecoration(labelText: 'Asignar Sector'),
                        items: mgmt.sectors.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Text(s.nombre),
                          );
                        }).toList(),
                        onChanged: (val) => setModalState(() => selectedSectorId = val),
                        validator: (v) => v == null ? 'Debe asignar un sector' : null,
                      ),
                      const SizedBox(height: 24),
                      LoadingButton(
                        label: 'Crear Usuario',
                        isLoading: mgmt.isLoading,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await mgmt.createUser(
                            email: emailCtrl.text.trim(),
                            cedula: cedulaCtrl.text.trim(),
                            nombres: nombresCtrl.text.trim(),
                            apellidos: apellidosCtrl.text.trim(),
                            telefono: telefonoCtrl.text.trim(),
                            rol: AppConstants.rolCoordinadorBrigada,
                            sectorId: selectedSectorId,
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
        title: const Text('Coordinadores de Brigada'),
      ),
      body: mgmt.isLoading && mgmt.coordinadores.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : mgmt.coordinadores.isEmpty
              ? EmptyState(
                  icon: Icons.group_off,
                  title: 'Sin coordinadores',
                  message: 'Aún no se han registrado coordinadores de brigada.',
                  buttonLabel: 'Añadir Coordinador',
                  onButtonPressed: _mostrarModalUsuario,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: mgmt.coordinadores.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = mgmt.coordinadores[index];
                    final sector = mgmt.sectors.where((s) => s.id == user.sectorId).firstOrNull;
                    
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.secondaryLight,
                        child: Icon(Icons.person, color: AppColors.secondary),
                      ),
                      title: Text(
                        user.nombreCompleto,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email),
                          if (sector != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Sector: ${sector.nombre}',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarModalUsuario,
        child: const Icon(Icons.add),
      ),
    );
  }
}
