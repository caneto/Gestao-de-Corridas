import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/blocs/team/team_bloc.dart';
import '../../../core/database/models/team_model.dart';

class TeamFormScreen extends StatefulWidget {
  final TeamModel?
  team; // If null, means Add context. If not null, Edit context.

  const TeamFormScreen({super.key, this.team});

  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team?.name ?? '');
    _countryController = TextEditingController(
      text: widget.team?.country ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.team != null;
      final newTeam = TeamModel(
        id: isEditing ? widget.team!.id : null,
        name: _nameController.text.trim(),
        country: _countryController.text.trim(),
      );

      if (isEditing) {
        context.read<TeamBloc>().add(UpdateTeam(newTeam));
      } else {
        context.read<TeamBloc>().add(AddTeam(newTeam));
      }

      context.pop(); // Go back to list
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.team != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Equipe' : 'Nova Equipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Equipe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'País Origem',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveForm,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
