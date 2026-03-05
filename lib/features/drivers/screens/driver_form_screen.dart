import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/blocs/driver/driver_bloc.dart';
import '../../../core/blocs/team/team_bloc.dart';
import '../../../core/database/models/driver_model.dart';
import '../../../core/database/models/team_model.dart';

class DriverFormScreen extends StatefulWidget {
  final DriverModel? driver;

  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nationalityController;
  late TextEditingController _numberController;
  int? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.name ?? '');
    _nationalityController = TextEditingController(
      text: widget.driver?.nationality ?? '',
    );
    _numberController = TextEditingController(
      text: widget.driver?.number.toString() ?? '',
    );
    _selectedTeamId = widget.driver?.teamId;

    // Ensure teams are loaded
    context.read<TeamBloc>().add(LoadTeams());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalityController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate() && _selectedTeamId != null) {
      final isEditing = widget.driver != null;
      final newDriver = DriverModel(
        id: isEditing ? widget.driver!.id : null,
        name: _nameController.text.trim(),
        nationality: _nationalityController.text.trim(),
        number: int.parse(_numberController.text.trim()),
        teamId: _selectedTeamId!,
        pointsTotal: widget.driver?.pointsTotal ?? 0, // Keep existing points
      );

      if (isEditing) {
        context.read<DriverBloc>().add(UpdateDriver(newDriver));
      } else {
        context.read<DriverBloc>().add(AddDriver(newDriver));
      }

      context.pop();
    } else if (_selectedTeamId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione uma equipe!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.driver != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Piloto' : 'Novo Piloto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Piloto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _nationalityController,
                      decoration: const InputDecoration(
                        labelText: 'Nacionalidade (Ex: BRA)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: 'Nº',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obrigatório';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<TeamBloc, TeamState>(
                builder: (context, state) {
                  if (state is TeamLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is TeamLoaded) {
                    if (state.teams.isEmpty) {
                      return const Card(
                        color: Colors.redAccent,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Cadastre uma Equipe primeiro!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Equipe',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group),
                      ),
                      value:
                          _selectedTeamId != null &&
                              state.teams.any((t) => t.id == _selectedTeamId)
                          ? _selectedTeamId
                          : null,
                      items: state.teams.map((TeamModel team) {
                        return DropdownMenuItem<int>(
                          value: team.id,
                          child: Text(team.name),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedTeamId = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecione a equipe' : null,
                    );
                  }
                  return const Text('Erro ao carregar equipes');
                },
              ),
              const SizedBox(height: 32),
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
