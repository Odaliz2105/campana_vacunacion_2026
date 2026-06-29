import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/vaccination_provider.dart';
import '../widgets/common_widgets.dart';
import 'formulario_vacunacion_screen.dart';
import 'dart:io';

/// Pantalla para ver el historial de registros de vacunación
class HistorialVacunacionesScreen extends StatelessWidget {
  const HistorialVacunacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vp = context.watch<VaccinationProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentUser;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Vacunaciones'),
      ),
      body: vp.isLoading && vp.vaccinations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : vp.vaccinations.isEmpty
              ? const EmptyState(
                  icon: Icons.history_toggle_off,
                  title: 'Sin registros',
                  message: 'Aún no se han registrado vacunaciones.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vp.vaccinations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vac = vp.vaccinations[index];
                    
                    bool canEdit = false;
                    if (currentUser != null) {
                      if (currentUser.rol == AppConstants.rolVacunador) {
                        canEdit = vac.vacunadorId == currentUser.id;
                      } else if (currentUser.rol == AppConstants.rolCoordinadorBrigada) {
                        canEdit = vac.sectorId == currentUser.sectorId;
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado: Mascota y Chip de Sync
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    PetTypeChip(tipo: vac.tipoMascota),
                                    const SizedBox(width: 8),
                                    Text(
                                      vac.nombreMascota,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SyncStatusChip(sincronizado: vac.sincronizado),
                                    if (canEdit) ...[
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppColors.secondary, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => FormularioVacunacionScreen(vaccinationToEdit: vac),
                                            ),
                                          ).then((_) {
                                            // Recargar las vacunaciones para refrescar cambios
                                            final user = currentUser;
                                            if (user != null) {
                                              if (user.rol == AppConstants.rolVacunador) {
                                                vp.loadVaccinations(vacunadorId: user.id);
                                              } else if (user.rol == AppConstants.rolCoordinadorBrigada) {
                                                vp.loadVaccinations(sectorId: user.sectorId);
                                              } else {
                                                vp.loadVaccinations();
                                              }
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // Datos
                            _buildInfoRow(Icons.person, 'Propietario', vac.propietarioNombre),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.badge, 'Cédula', vac.propietarioCedula),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.calendar_today, 'Fecha', dateFormat.format(vac.fechaRegistro)),
                            const SizedBox(height: 12),
                            // Foto miniatura si existe
                            if (vac.fotoUrl != null)
                              Container(
                                height: 80,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: vac.fotoUrl!.startsWith('http')
                                    ? Image.network(vac.fotoUrl!, fit: BoxFit.cover)
                                    : Image.file(File(vac.fotoUrl!), fit: BoxFit.cover),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
