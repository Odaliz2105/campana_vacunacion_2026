import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/vaccination_provider.dart';
import '../widgets/common_widgets.dart';
import '../../core/services/connectivity_service.dart';

/// Dashboard del Vacunador (Enfocado en registrar y ver sus pendientes)
class DashboardVacunadorScreen extends StatefulWidget {
  const DashboardVacunadorScreen({super.key});

  @override
  State<DashboardVacunadorScreen> createState() => _DashboardVacunadorScreenState();
}

class _DashboardVacunadorScreenState extends State<DashboardVacunadorScreen> {
  final ConnectivityService _connectivity = ConnectivityService();
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
    _connectivity.connectivityStream.listen((hasConnection) {
      if (mounted) setState(() => _hasInternet = hasConnection);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId != null) {
        context.read<VaccinationProvider>().loadVaccinations(vacunadorId: userId);
        context.read<VaccinationProvider>().loadPending();
      }
    });
  }

  Future<void> _checkInternet() async {
    final hasConn = await _connectivity.hasConnection();
    if (mounted) setState(() => _hasInternet = hasConn);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vp = context.watch<VaccinationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Vacunador'),
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
          final userId = auth.currentUser?.id;
          if (userId != null) {
            await vp.loadVaccinations(vacunadorId: userId);
            await vp.loadPending();
            await _checkInternet();
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
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDark],
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
                      child: Icon(Icons.vaccines, color: Colors.white, size: 28),
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
                            'Vacunador',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Estado de conexión ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasInternet
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.pending.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasInternet ? AppColors.success : AppColors.pending,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasInternet ? Icons.wifi : Icons.wifi_off,
                      color: _hasInternet ? AppColors.success : AppColors.pending,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _hasInternet
                            ? 'Conectado a Internet. Sus registros se guardarán en la nube.'
                            : 'Sin conexión. Puede seguir registrando vacunaciones; se guardarán en su dispositivo.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _hasInternet ? AppColors.success : AppColors.pending,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Botón Principal de Vacunación ─────────────────────
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.formularioVacunacion),
                  icon: const Icon(Icons.add_circle, size: 32),
                  label: const Text(
                    'NUEVO REGISTRO DE VACUNACIÓN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Estadísticas rápidas y sincronización ─────────────
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Mis Registros',
                      value: '${vp.vaccinations.length}',
                      icon: Icons.history,
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.historialVacunaciones),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: 'Pendientes Sync',
                      value: '${vp.pendingCount}',
                      icon: Icons.cloud_upload,
                      color: vp.pendingCount > 0 ? AppColors.pending : AppColors.success,
                      onTap: null, // Podríamos abrir un modal para forzar sync
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botón de sincronización manual si hay pendientes y hay internet
              if (vp.pendingCount > 0 && _hasInternet)
                LoadingButton(
                  label: 'Sincronizar ${vp.pendingCount} registros',
                  icon: Icons.sync,
                  backgroundColor: AppColors.secondary,
                  isLoading: vp.isLoading,
                  onPressed: () async {
                    await vp.syncPending();
                    if (vp.errorMessage != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vp.errorMessage!), backgroundColor: AppColors.error),
                      );
                    } else if (vp.successMessage != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vp.successMessage!), backgroundColor: AppColors.success),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
