import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para detectar el estado de la conexión a internet
class ConnectivityService {
  final _connectivity = Connectivity();

  /// Retorna true si hay conexión a internet disponible
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  /// Stream que emite cambios en el estado de la conexión
  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet));
}
