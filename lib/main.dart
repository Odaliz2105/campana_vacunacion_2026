import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'core/services/connectivity_service.dart';

// Data
import 'data/datasources/remote_firebase_datasource.dart';
import 'data/datasources/local_vaccination_datasource.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/sector_repository_impl.dart';
import 'data/repositories/vaccination_repository_impl.dart';

// Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/vaccination_provider.dart';
import 'presentation/providers/management_provider.dart';

// Pages
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/change_password_screen.dart';
import 'presentation/pages/forgot_password_screen.dart';
import 'presentation/pages/dashboard_campana_screen.dart';
import 'presentation/pages/dashboard_brigada_screen.dart';
import 'presentation/pages/dashboard_vacunador_screen.dart';
import 'presentation/pages/gestion_sectores_screen.dart';
import 'presentation/pages/gestion_coordinadores_screen.dart';
import 'presentation/pages/gestion_vacunadores_screen.dart';
import 'presentation/pages/formulario_vacunacion_screen.dart';
import 'presentation/pages/historial_vacunaciones_screen.dart';
import 'presentation/pages/perfil_screen.dart';

import 'core/services/device_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase error: $e');
  }

  await Hive.initFlutter();
  await Hive.openBox<String>(AppConstants.hiveBoxVaccinations);

  final remoteDb = RemoteFirebaseDatasource();
  final localDb = LocalVaccinationDatasource();
  final connectivity = ConnectivityService();
  final deviceService = DeviceService();

  final userRepo = UserRepositoryImpl(remoteDb);
  final sectorRepo = SectorRepositoryImpl(remoteDb);
  final vaccinationRepo =
      VaccinationRepositoryImpl(remoteDb, localDb, connectivity);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(userRepo, remoteDb),
        ),
        ChangeNotifierProvider(
          create: (_) => ManagementProvider(sectorRepo, userRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => VaccinationProvider(vaccinationRepo, deviceService),
        ),
      ],
      child: const CampanaApp(),
    ),
  );
}

class CampanaApp extends StatelessWidget {
  const CampanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.dashboardCoordinadorCampana: (_) =>
            const DashboardCampanaScreen(),
        AppRoutes.dashboardCoordinadorBrigada: (_) =>
            const DashboardBrigadaScreen(),
        AppRoutes.dashboardVacunador: (_) =>
            const DashboardVacunadorScreen(),
        AppRoutes.gestionSectores: (_) => const GestionSectoresScreen(),
        AppRoutes.gestionCoordinadores: (_) =>
            const GestionCoordinadoresScreen(),
        AppRoutes.gestionVacunadores: (_) =>
            const GestionVacunadoresScreen(),
        AppRoutes.formularioVacunacion: (_) =>
            const FormularioVacunacionScreen(),
        AppRoutes.historialVacunaciones: (_) =>
            const HistorialVacunacionesScreen(),
        AppRoutes.perfil: (_) => const PerfilScreen(),
      },
    );
  }
}