import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/management_provider.dart';
import '../widgets/common_widgets.dart';

/// Pantalla para la gestión (CRUD) de Sectores (Solo Coordinador de Campaña)
class GestionSectoresScreen extends StatefulWidget {
  const GestionSectoresScreen({super.key});

  @override
  State<GestionSectoresScreen> createState() => _GestionSectoresScreenState();
}

class _GestionSectoresScreenState extends State<GestionSectoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementProvider>().loadSectors();
    });
  }

  void _mostrarModalSector({String? id, String? nombre, String? descripcion}) {
    final isEditing = id != null;
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController(text: nombre);
    final descCtrl = TextEditingController(text: descripcion);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Editar Sector' : 'Nuevo Sector',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Nombre del Sector',
                  controller: nombreCtrl,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Descripción (Opcional)',
                  controller: descCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Consumer<ManagementProvider>(
                  builder: (_, mgmt, __) => LoadingButton(
                    label: isEditing ? 'Guardar Cambios' : 'Crear Sector',
                    isLoading: mgmt.isLoading,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      bool success;
                      if (isEditing) {
                        final sector = mgmt.sectors.firstWhere((s) => s.id == id);
                        success = await mgmt.updateSector(
                          sector.copyWith(
                            nombre: nombreCtrl.text,
                            descripcion: descCtrl.text,
                          ),
                        );
                      } else {
                        success = await mgmt.createSector(
                          nombreCtrl.text,
                          descCtrl.text,
                        );
                      }
                      if (mounted) {
                        if (success) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mgmt.successMessage ?? 'Éxito'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mgmt.errorMessage ?? 'Error al guardar'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mgmt = context.watch<ManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Sectores'),
      ),
      body: mgmt.isLoading && mgmt.sectors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : mgmt.sectors.isEmpty
              ? EmptyState(
                  icon: Icons.map_outlined,
                  title: 'No hay sectores',
                  message: 'Cree el primer sector de la campaña',
                  buttonLabel: 'Crear Sector',
                  onButtonPressed: () => _mostrarModalSector(),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: mgmt.sectors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sector = mgmt.sectors[index];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.map, color: AppColors.primary),
                      ),
                      title: Text(
                        sector.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        sector.descripcion.isEmpty ? 'Sin descripción' : sector.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.secondary),
                            onPressed: () => _mostrarModalSector(
                              id: sector.id,
                              nombre: sector.nombre,
                              descripcion: sector.descripcion,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () => _confirmDelete(context, sector.id, sector.nombre),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarModalSector(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Sector'),
        content: Text('¿Está seguro de eliminar el sector "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final mgmt = context.read<ManagementProvider>();
              final success = await mgmt.deleteSector(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mgmt.successMessage ?? 'Eliminado'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
