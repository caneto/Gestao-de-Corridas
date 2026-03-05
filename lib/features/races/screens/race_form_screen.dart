import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/blocs/race/race_bloc.dart';
import '../../../core/database/models/race_model.dart';

class RaceFormScreen extends StatefulWidget {
  final RaceModel? race;

  const RaceFormScreen({super.key, this.race});

  @override
  State<RaceFormScreen> createState() => _RaceFormScreenState();
}

class _RaceFormScreenState extends State<RaceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _expectedDistanceController;
  late TextEditingController _completedDistanceController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSprint = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.race?.name ?? '');
    _locationController = TextEditingController(
      text: widget.race?.locationTitle ?? '',
    );
    _latController = TextEditingController(
      text: widget.race?.positionLat.toString() ?? '',
    );
    _lngController = TextEditingController(
      text: widget.race?.positionLng.toString() ?? '',
    );
    _expectedDistanceController = TextEditingController(
      text: widget.race?.expectedDistance.toString() ?? '',
    );
    _completedDistanceController = TextEditingController(
      text: widget.race?.completedDistance.toString() ?? '',
    );

    if (widget.race != null) {
      _selectedDate = widget.race!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.race!.date);
      _isSprint = widget.race!.isSprint;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _expectedDistanceController.dispose();
    _completedDistanceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.race != null;

      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newRace = RaceModel(
        id: isEditing ? widget.race!.id : null,
        name: _nameController.text.trim(),
        locationTitle: _locationController.text.trim(),
        positionLat: double.tryParse(_latController.text.trim()) ?? 0.0,
        positionLng: double.tryParse(_lngController.text.trim()) ?? 0.0,
        date: dateTime,
        expectedDistance:
            double.tryParse(_expectedDistanceController.text.trim()) ?? 0.0,
        completedDistance:
            double.tryParse(_completedDistanceController.text.trim()) ?? 0.0,
        isSprint: _isSprint,
      );

      if (isEditing) {
        context.read<RaceBloc>().add(UpdateRace(newRace));
      } else {
        context.read<RaceBloc>().add(AddRace(newRace));
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.race != null;
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Corrida' : 'Nova Corrida'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Corrida (ex: GP Brasil)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localização (ex: Interlagos)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) => null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.gps_fixed),
                      ),
                      validator: (value) => null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.gps_fixed),
                      ),
                      validator: (value) => null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expectedDistanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Distância Esperada (km/voltas)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.route),
                      ),
                      validator: (value) => null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _completedDistanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Distância Concluída',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.done_all),
                      ),
                      validator: (value) => null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(dateStr),
                        onPressed: () => _pickDate(context),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(timeStr),
                        onPressed: () => _pickTime(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Fim de Semana Sprint?'),
                subtitle: const Text(
                  'Habilita pontuação extra nas provas Sprint',
                ),
                value: _isSprint,
                onChanged: (val) {
                  setState(() {
                    _isSprint = val;
                  });
                },
                secondary: const Icon(Icons.speed),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
