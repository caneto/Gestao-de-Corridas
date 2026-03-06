import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/driver/driver_bloc.dart';
import '../../../core/blocs/result/result_bloc.dart';
import '../../../core/blocs/scoring/scoring_bloc.dart';
import '../../../core/database/models/driver_model.dart';
import '../../../core/database/models/race_model.dart';
import '../../../core/database/models/result_model.dart';

class RaceResultScreen extends StatefulWidget {
  final RaceModel race;

  const RaceResultScreen({super.key, required this.race});

  @override
  State<RaceResultScreen> createState() => _RaceResultScreenState();
}

class _RaceResultScreenState extends State<RaceResultScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ResultBloc>().add(LoadResultsForRace(widget.race.id!));
    context.read<DriverBloc>().add(LoadDrivers());
  }

  void _showAddResultModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddResultForm(race: widget.race),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultados: ${widget.race.name}')),
      body: BlocBuilder<ResultBloc, ResultState>(
        builder: (context, state) {
          if (state is ResultLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ResultLoaded) {
            if (state.results.isEmpty) {
              return const Center(child: Text('Nenhum resultado inserido.'));
            }
            return ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final result = state.results[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getPositionColor(result.position),
                      child: Text(
                        result.dnf ? 'DNF' : result.position.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: _DriverNameBuilder(driverId: result.driverId),
                    subtitle: Text(
                      'Grid: P${result.gridPosition} | Pontos: +${result.pointsAwarded}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (result.fastestLap)
                          const Icon(
                            Icons.timer,
                            color: Colors.purple,
                            size: 20,
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<ResultBloc>().add(
                              DeleteResult(
                                result.id!,
                                result.pointsAwarded,
                                result.driverId,
                                widget.race.id!,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ResultError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddResultModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Inserir Piloto'),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber;
    if (position == 2) return Colors.grey.shade400;
    if (position == 3) return Colors.brown.shade400;
    return Colors.blueGrey;
  }
}

class _DriverNameBuilder extends StatelessWidget {
  final int driverId;
  const _DriverNameBuilder({required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        if (state is DriverLoaded) {
          try {
            final driver = state.drivers.firstWhere((d) => d.id == driverId);
            return Text(
              driver.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          } catch (e) {
            return const Text('Piloto Desconhecido');
          }
        }
        return const Text('Carregando...');
      },
    );
  }
}

class _AddResultForm extends StatefulWidget {
  final RaceModel race;
  const _AddResultForm({required this.race});

  @override
  State<_AddResultForm> createState() => _AddResultFormState();
}

class _AddResultFormState extends State<_AddResultForm> {
  final _formKey = GlobalKey<FormState>();
  DriverModel? _selectedDriver;
  final TextEditingController _posController = TextEditingController();
  final TextEditingController _gridController = TextEditingController();
  bool _fastestLap = false;
  bool _dnf = false;

  @override
  void dispose() {
    _posController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDriver != null) {
      final position = int.tryParse(_posController.text) ?? 99;

      // Calculate Points using ScoringBloc manually without full stream for brevity of immediate db insert
      // Let's use bloc context
      context.read<ScoringBloc>().add(
        CalculatePointsEvent(
          isSprint: widget.race.isSprint,
          expectedDistance: widget.race.expectedDistance,
          completedDistance: widget.race.completedDistance,
          position: position,
          fastestLap: _fastestLap && !_dnf,
        ),
      );

      // Listen closely for exactly one result
      final scoringBloc = context.read<ScoringBloc>();
      final subscription = scoringBloc.stream.listen((state) {
        if (state is PointsCalculated) {
          final ptsCalculated = _dnf ? 0 : state.points;

          final result = ResultModel(
            raceId: widget.race.id!,
            driverId: _selectedDriver!.id!,
            teamId: _selectedDriver!.teamId,
            position: position,
            gridPosition: int.tryParse(_gridController.text) ?? 0,
            fastestLap: _fastestLap && !_dnf,
            dnf: _dnf,
            pointsAwarded: ptsCalculated,
          );

          context.read<ResultBloc>().add(AddResult(result));
          if (mounted) Navigator.pop(context); // close bottom sheet
        }
      });

      // Unsubscribe quickly after event is processed to prevent memory leak
      Future.delayed(
        const Duration(milliseconds: 500),
        () => subscription.cancel(),
      );
    } else if (_selectedDriver == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um piloto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adicionar Resultado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            BlocBuilder<DriverBloc, DriverState>(
              builder: (context, state) {
                if (state is DriverLoaded) {
                  return DropdownButtonFormField<DriverModel>(
                    decoration: const InputDecoration(
                      labelText: 'Piloto',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedDriver,
                    items: state.drivers
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text('${d.number} - ${d.name}'),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedDriver = val;
                      });
                    },
                    validator: (val) => val == null ? 'Obrigatório' : null,
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _posController,
                    decoration: const InputDecoration(
                      labelText: 'Posição Final',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _gridController,
                    decoration: const InputDecoration(
                      labelText: 'Posição no Grid',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? 'Obrigatório' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Volta Mais Rápida'),
              value: _fastestLap,
              onChanged: (val) => setState(() => _fastestLap = val!),
            ),
            CheckboxListTile(
              title: const Text('DNF (Não Terminou)'),
              value: _dnf,
              onChanged: (val) => setState(() => _dnf = val!),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Salvar Resultado e Computar Pontos'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
