import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/vaccination_provider.dart';
import '../widgets/common_widgets.dart';

/// Dashboard del Coordinador de Brigada – estadísticas de su sector
class DashboardBrigadaScreen extends StatefulWidget {
  const DashboardBrigadaScreen({super.key});

  @override
  State<DashboardBrigadaScreen> createState() => _DashboardBrigadaScreenState();
}

class _DashboardBrigadaScreenState extends State<DashboardBrigadaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectorId = context.read<AuthProvider>().currentUser?.sectorId;
      final vp = context.read<VaccinationProvider>();
      if (sectorId != null) {
        vp.loadStats(sectorId: sectorId);
        vp.loadVaccinations(sectorId: sectorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vp = context.watch<VaccinationProvider>();
    final stats = vp.stats;
    final sectorId = auth.currentUser?.sectorId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Brigada'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (sectorId != null) {
            await vp.loadStats(sectorId: sectorId);
            await vp.loadVaccinations(sectorId: sectorId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner de bienvenida ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 28,
                      child: Icon(Icons.manage_accounts, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.nombres ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Coordinador de Brigada',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Estadísticas del sector ───────────────────────────
              const SectionHeader(title: 'Estadísticas del Sector'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    title: 'Vacunaciones',
                    value: '${stats['total'] ?? 0}',
                    icon: Icons.vaccines,
                    color: AppColors.statCardTotal,
                  ),
                  StatCard(
                    title: 'Caninos',
                    value: '${stats['caninos'] ?? 0}',
                    icon: Icons.pets,
                    color: AppColors.statCardPerro,
                  ),
                  StatCard(
                    title: 'Felinos',
                    value: '${stats['felinos'] ?? 0}',
                    icon: Icons.catching_pokemon,
                    color: AppColors.statCardGato,
                  ),
                  StatCard(
                    title: 'Pendientes',
                    value: '${stats['pendientes'] ?? 0}',
                    icon: Icons.cloud_off,
                    color: AppColors.statCardPending,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Gestión de vacunadores ────────────────────────────
              const SectionHeader(title: 'Gestión'),
              const SizedBox(height: 12),
              _buildTile(
                icon: Icons.medical_services_outlined,
                title: 'Gestión de Vacunadores',
                subtitle: 'Crear y asignar vacunadores',
                onTap: () => Navigator.pushNamed(context, AppRoutes.gestionVacunadores),
              ),
              const SizedBox(height: 10),
              _buildTile(
                icon: Icons.history,
                title: 'Historial de Vacunaciones',
                subtitle: 'Registros del sector',
                onTap: () => Navigator.pushNamed(context, AppRoutes.historialVacunaciones),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
