import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/device_service.dart';
import '../../domain/entities/vaccination_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/vaccination_provider.dart';
import '../widgets/common_widgets.dart';

class FormularioVacunacionScreen extends StatefulWidget {
  final VaccinationEntity? vaccinationToEdit;

  const FormularioVacunacionScreen({super.key, this.vaccinationToEdit});

  @override
  State<FormularioVacunacionScreen> createState() =>
      _FormularioVacunacionScreenState();
}

class _FormularioVacunacionScreenState
    extends State<FormularioVacunacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceService = DeviceService();

  final _propNombreCtrl = TextEditingController();
  final _propCedulaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _mascotaNombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _vacunaCtrl = TextEditingController(text: 'Antirrábica');
  final _observacionesCtrl = TextEditingController();

  String _tipoMascota = 'Canino';
  String _sexo = 'Macho';

  File? _foto;
  double? _latitud;
  double? _longitud;

  bool _isGettingLocation = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final toEdit = widget.vaccinationToEdit;
    if (toEdit != null) {
      _propNombreCtrl.text = toEdit.propietarioNombre;
      _propCedulaCtrl.text = toEdit.propietarioCedula;
      _telefonoCtrl.text = toEdit.telefono;
      _mascotaNombreCtrl.text = toEdit.nombreMascota;
      _edadCtrl.text = toEdit.edadAproximada;
      _vacunaCtrl.text = toEdit.vacunaAplicada;
      _observacionesCtrl.text = toEdit.observaciones;

      _tipoMascota = toEdit.tipoMascota;
      _sexo = toEdit.sexo;
      _latitud = toEdit.latitud;
      _longitud = toEdit.longitud;
    }
  }

  @override
  void dispose() {
    _propNombreCtrl.dispose();
    _propCedulaCtrl.dispose();
    _telefonoCtrl.dispose();
    _mascotaNombreCtrl.dispose();
    _edadCtrl.dispose();
    _vacunaCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  Future<void> _tomarFoto() async {
    try {
      final foto = await _deviceService.takePhoto();

      if (!mounted) return;

      if (foto != null) {
        setState(() => _foto = foto);
      }
    } catch (e, stackTrace) {
      debugPrint('================ ERROR GUARDAR ================');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('===============================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar foto: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {}
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _isGettingLocation = true);

    try {
      final position = await _deviceService.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
        _isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación obtenida correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isGettingLocation = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener GPS: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS obligatorio'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final isEditing = widget.vaccinationToEdit != null;
    final hasPhoto = isEditing
        ? (_foto != null ||
            (widget.vaccinationToEdit!.fotoUrl != null &&
                widget.vaccinationToEdit!.fotoUrl!.isNotEmpty))
        : _foto != null;

    if (!hasPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar una foto'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // ── Validación de sesión: espera hasta 5s si el perfil aún está cargando
    // (ocurre en Android cuando la actividad se recrea tras volver de la cámara)
    var auth = context.read<AuthProvider>().currentUser;

    if (auth == null) {
      // ¿Firebase Auth tiene sesión activa aunque el Provider aún no cargó?
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        // No hay sesión real — redirigir al login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión expirada. Por favor inicie sesión nuevamente.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Sí hay sesión en Firebase Auth: esperar a que el Provider termine de cargar
      debugPrint('[_guardar] Perfil aún no disponible (UID=${firebaseUser.uid}). Esperando...');
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        auth = context.read<AuthProvider>().currentUser;
        if (auth != null) break;
        debugPrint('[_guardar] Esperando perfil... intento ${i + 1}/10');
      }

      if (auth == null) {
        debugPrint('[_guardar] Perfil no cargó tras 5s. Forzando reloadProfile...');
        // El wait loop solo sondea — si _loadUserProfile ya falló, nunca ayuda.
        // Reintentamos activamente llamando reloadProfile() que ejecuta _loadUserProfile de nuevo.
        await context.read<AuthProvider>().reloadProfile();
        if (!mounted) return;

        // Esperar hasta 3s más por si la recarga tardó
        for (int i = 0; i < 6; i++) {
          auth = context.read<AuthProvider>().currentUser;
          if (auth != null) break;
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
        }
      }

      if (auth == null) {
        debugPrint('[_guardar] Perfil sigue null tras reintento. Estado: '
            '${context.read<AuthProvider>().status} | '
            'Error: ${context.read<AuthProvider>().errorMessage}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar el perfil. Cierre y vuelva a abrir la app.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (auth.sectorId == null || auth.sectorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El usuario no tiene sector asignado'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final vp = context.read<VaccinationProvider>();
      bool success;

      if (isEditing) {
        final updated = widget.vaccinationToEdit!.copyWith(
          propietarioNombre: _propNombreCtrl.text.trim(),
          propietarioCedula: _propCedulaCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          tipoMascota: _tipoMascota,
          nombreMascota: _mascotaNombreCtrl.text.trim(),
          edadAproximada: _edadCtrl.text.trim(),
          sexo: _sexo,
          vacunaAplicada: _vacunaCtrl.text.trim(),
          observaciones: _observacionesCtrl.text.trim(),
          latitud: _latitud!,
          longitud: _longitud!,
        );

        success = await vp.updateVaccination(updated);
      } else {
        debugPrint('===== DATOS DEL USUARIO =====');
        debugPrint('ID: ${auth.id}');
        debugPrint('Sector: ${auth.sectorId}');
        debugPrint('=============================');

        final vaccination = VaccinationEntity(
          id: '',
          propietarioNombre: _propNombreCtrl.text.trim(),
          propietarioCedula: _propCedulaCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          tipoMascota: _tipoMascota,
          nombreMascota: _mascotaNombreCtrl.text.trim(),
          edadAproximada: _edadCtrl.text.trim(),
          sexo: _sexo,
          vacunaAplicada: _vacunaCtrl.text.trim(),
          observaciones: _observacionesCtrl.text.trim(),
          latitud: _latitud!,
          longitud: _longitud!,
          fechaRegistro: DateTime.now(),
          sectorId: auth.sectorId!,
          vacunadorId: auth.id,
          sincronizado: false,
        );

        success = await vp.saveVaccination(
          vaccination: vaccination,
          photoFile: _foto,
        );
      }

      if (!mounted) return;

      // Muestra el mensaje de error real del provider si el guardado falló
      final errorMsg = vp.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? (vp.successMessage ?? 'Guardado correctamente') : (errorMsg ?? 'Error al guardar'),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );

      if (success) Navigator.pop(context);
    } catch (e, stackTrace) {
      debugPrint('================ ERROR GUARDAR ================');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('===============================================');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.vaccinationToEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(edit != null ? 'Editar Registro' : 'Nuevo Registro'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEvidenceSection(edit),
              const SizedBox(height: 20),
              _buildPetSection(),
              const SizedBox(height: 20),
              _buildOwnerSection(),
              const SizedBox(height: 20),
              _buildMedicalSection(),
              const SizedBox(height: 28),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceSection(VaccinationEntity? edit) {
    return _sectionCard(
      children: [
        const SectionHeader(title: 'Evidencia'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _obtenerUbicacion,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.location_on),
                label: Text(
                  _isGettingLocation ? 'Obteniendo...' : 'Obtener GPS',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar Foto'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_latitud != null && _longitud != null)
          Text(
            'Latitud: $_latitud\nLongitud: $_longitud',
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        else
          const Text(
            'Ubicación no registrada',
            style: TextStyle(color: Colors.grey),
          ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),

          child: _foto != null
    ? kIsWeb
        ? Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Foto seleccionada'),
              ],
            ),
          )
        : Image.file(
            _foto!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          )
    : edit?.fotoUrl != null && edit!.fotoUrl!.isNotEmpty
        ? Image.network(
            edit.fotoUrl!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        : Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Sin foto registrada'),
              ],
            ),
          )
        ),
      ],
    );
  }

  Widget _buildPetSection() {
    return _sectionCard(
      children: [
        const SectionHeader(title: 'Datos de la mascota'),
        const SizedBox(height: 12),
        const Text(
          'Tipo de mascota',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: [
            ChoiceChip(
              label: const Text('Canino'),
              selected: _tipoMascota == 'Canino',
              onSelected: (_) => setState(() => _tipoMascota = 'Canino'),
            ),
            ChoiceChip(
              label: const Text('Felino'),
              selected: _tipoMascota == 'Felino',
              onSelected: (_) => setState(() => _tipoMascota = 'Felino'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _mascotaNombreCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre mascota',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _requiredValidator(
            value,
            'El nombre de la mascota es obligatorio',
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _edadCtrl,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Edad aproximada',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _requiredValidator(
            value,
            'La edad aproximada es obligatoria',
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _sexo,
          decoration: const InputDecoration(
            labelText: 'Sexo',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Macho', child: Text('Macho')),
            DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sexo = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    return _sectionCard(
      children: [
        const SectionHeader(title: 'Datos del propietario'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _propNombreCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre propietario',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _requiredValidator(
            value,
            'El propietario es obligatorio',
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _propCedulaCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cédula',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _requiredValidator(
            value,
            'La cédula es obligatoria',
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _telefonoCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _requiredValidator(
            value,
            'El teléfono es obligatorio',
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalSection() {
    return _sectionCard(
      children: [
        const SectionHeader(title: 'Datos médicos'),
        const SizedBox(height: 12),
        TextFormField(
          controller: _vacunaCtrl,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Vacuna aplicada',
            border: OutlineInputBorder(),
          ),
          validator: (value) => _requiredValidator(
            value,
            'La vacuna aplicada es obligatoria',
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _observacionesCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Observaciones',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _guardar,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}