import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/vaccination_provider.dart';
import '../providers/management_provider.dart';
import '../../domain/entities/sector_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../widgets/common_widgets.dart';

/// Dashboard del Coordinador de Campaña con estadísticas globales
class DashboardCampanaScreen extends StatefulWidget {
  const DashboardCampanaScreen({super.key});

  @override
  State<DashboardCampanaScreen> createState() => _DashboardCampanaScreenState();
}

class _DashboardCampanaScreenState extends State<DashboardCampanaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaccinationProvider>().loadStats();
      context.read<VaccinationProvider>().loadVaccinations();
      context.read<ManagementProvider>().loadSectors();
      context.read<ManagementProvider>().loadVacunadores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vacProvider = context.watch<VaccinationProvider>();
    final stats = vacProvider.stats;
    final mgmtProvider = context.watch<ManagementProvider>();
    final sectors = mgmtProvider.sectors;
    final vacunadores = mgmtProvider.vacunadores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard General'),
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
          final mp = context.read<ManagementProvider>();
          await vacProvider.loadStats();
          await vacProvider.loadVaccinations();
          await mp.loadSectors();
          await mp.loadVacunadores();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Saludo ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 28,
                      child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido/a,',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          Text(
                            auth.currentUser?.nombres ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Coordinador de Campaña',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(title: 'Vacunaciones por Sector'),
              const SizedBox(height: 10),

              ...vacProvider.vaccinations
                  .fold<Map<String, int>>({}, (map, v) {
                    map[v.sectorId] = (map[v.sectorId] ?? 0) + 1;
                    return map;
                    })
                  .entries
                  .map((e) => ListTile(
                      leading: const Icon(Icons.map),
                      title: Text(e.key),
                      trailing: Text('${e.value}'),
                  )),

              const SizedBox(height: 20),

const SectionHeader(title: 'Vacunaciones por Vacunador'),
const SizedBox(height: 10),

...vacProvider.vaccinations
    .fold<Map<String, int>>({}, (map, v) {
      map[v.vacunadorId] = (map[v.vacunadorId] ?? 0) + 1;
      return map;
    })
    .entries
    .map((e) => ListTile(
          leading: const Icon(Icons.person),
          title: Text(e.key),
          trailing: Text('${e.value}'),
        )),
              

              // ── Tarjetas estadísticas ─────────────────────────────
              const SectionHeader(title: 'Resumen de la Campaña'),
              const SizedBox(height: 12),

              if (vacProvider.isLoading && stats.isEmpty)
                _buildSkeletonStats()
              else
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      title: 'Total Vacunaciones',
                      value: '${stats['total'] ?? 0}',
                      icon: Icons.vaccines,
                      color: AppColors.statCardTotal,
                    ),
                    StatCard(
                      title: 'Caninos Vacunados',
                      value: '${stats['caninos'] ?? 0}',
                      icon: Icons.pets,
                      color: AppColors.statCardPerro,
                    ),
                    StatCard(
                      title: 'Felinos Vacunados',
                      value: '${stats['felinos'] ?? 0}',
                      icon: Icons.catching_pokemon,
                      color: AppColors.statCardGato,
                    ),
                    StatCard(
                      title: 'Pendientes Sync',
                      value: '${stats['pendientes'] ?? 0}',
                      icon: Icons.cloud_off,
                      color: AppColors.statCardPending,
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // ── Vacunaciones por Sector ─────────────────────────────
              const SectionHeader(title: 'Vacunaciones por Sector'),
              const SizedBox(height: 12),
              _buildSectorStatsList(stats, sectors),
              const SizedBox(height: 24),

              // ── Vacunaciones por Vacunador ──────────────────────────
              const SectionHeader(title: 'Vacunaciones por Vacunador'),
              const SizedBox(height: 12),
              _buildVacunadorStatsList(stats, vacunadores),
              const SizedBox(height: 24),

              // ── Acciones de gestión ───────────────────────────────
              const SectionHeader(title: 'Gestión Administrativa'),
              const SizedBox(height: 12),

              _buildActionTile(
                icon: Icons.map_outlined,
                title: 'Gestión de Sectores',
                subtitle: 'Crear, editar y eliminar sectores',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.gestionSectores),
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.group_outlined,
                title: 'Gestión de Coordinadores',
                subtitle: 'Administrar Coordinadores de Brigada',
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.gestionCoordinadores),
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                icon: Icons.history,
                title: 'Historial de Vacunaciones',
                subtitle: 'Ver todos los registros de la campaña',
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.historialVacunaciones),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonStats() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: List.generate(
        4,
        (_) => SkeletonLoader(
          width: double.infinity,
          height: double.infinity,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorStatsList(Map<String, dynamic> stats, List<SectorEntity> sectors) {
    final porSector = stats['porSector'] as Map<dynamic, dynamic>? ?? {};
    if (porSector.isEmpty) {
      return const Card(
        color: AppColors.surface,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos por sector disponibles.'),
        ),
      );
    }

    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: porSector.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sectorId = porSector.keys.elementAt(index) as String;
          final count = porSector[sectorId] as int;
          final sector = sectors.where((s) => s.id == sectorId).firstOrNull;
          final nombreSector = sector?.nombre ?? 'Sector $sectorId';

          return ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.primary),
            title: Text(nombreSector, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Chip(
              label: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVacunadorStatsList(Map<String, dynamic> stats, List<UserEntity> vacunadores) {
    final porVacunador = stats['porVacunador'] as Map<dynamic, dynamic>? ?? {};
    if (porVacunador.isEmpty) {
      return const Card(
        color: AppColors.surface,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos por vacunador disponibles.'),
        ),
      );
    }

    return Card(
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: porVacunador.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final vacunadorId = porVacunador.keys.elementAt(index) as String;
          final count = porVacunador[vacunadorId] as int;
          final vacunador = vacunadores.where((v) => v.id == vacunadorId).firstOrNull;
          final nombreVacunador = vacunador?.nombreCompleto ?? 'Vacunador $vacunadorId';

          return ListTile(
            leading: const Icon(Icons.person, color: AppColors.secondary),
            title: Text(nombreVacunador, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Chip(
              label: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.secondary,
            ),
          );
        },
      ),
    );
  }
}
