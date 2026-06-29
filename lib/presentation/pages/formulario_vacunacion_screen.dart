import 'dart:io';
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar la foto: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _isGettingLocation = true);

    try {
      final position = await _deviceService.getCurrentPosition();

      if (!mounted) return;

      if (position == null) {
        setState(() => _isGettingLocation = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

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

    setState(() => _isSaving = true);

    final auth = context.read<AuthProvider>().currentUser!;
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

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Guardado correctamente' : 'Error al guardar'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) Navigator.pop(context);
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
                label: Text(_isGettingLocation ? 'Obteniendo...' : 'Obtener GPS'),
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
              ? Image.file(
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
                    ),
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
          validator: (value) =>
              _requiredValidator(value, 'El nombre de la mascota es obligatorio'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _edadCtrl,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Edad aproximada',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              _requiredValidator(value, 'La edad aproximada es obligatoria'),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _sexo,
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
          validator: (value) =>
              _requiredValidator(value, 'El propietario es obligatorio'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _propCedulaCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cédula',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              _requiredValidator(value, 'La cédula es obligatoria'),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _telefonoCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              _requiredValidator(value, 'El teléfono es obligatorio'),
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
          validator: (value) =>
              _requiredValidator(value, 'La vacuna aplicada es obligatoria'),
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