import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio de acceso al hardware del dispositivo (GPS y Cámara)
class DeviceService {
  final _imagePicker = ImagePicker();

  // ── GPS ───────────────────────────────────────────────────────────

  /// Solicita permisos de ubicación y retorna la posición actual.
  /// Lanza [LocationServiceDisabledException] si el servicio GPS está apagado.
  /// Lanza [PermissionDeniedException] si el permiso es denegado.
  Future<Position> getCurrentPosition() async {
    // Verificar que el servicio de ubicación está activo
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // Verificar y solicitar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Permiso de ubicación denegado');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Permiso de ubicación denegado permanentemente. '
        'Por favor, actívelo en la configuración del dispositivo.',
      );
    }

    // Obtener posición con alta precisión
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  // ── Cámara e Imágenes ─────────────────────────────────────────────

  /// Captura una foto con la cámara del dispositivo.
  /// Retorna el [File] de la imagen, o null si el usuario canceló.
  Future<File?> takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75, // Compresión para optimizar almacenamiento
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (photo == null) return null;
    return File(photo.path);
  }

  /// Selecciona una imagen de la galería.
  /// Retorna el [File] de la imagen, o null si el usuario canceló.
  Future<File?> pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (image == null) return null;
    return File(image.path);
  }
}
