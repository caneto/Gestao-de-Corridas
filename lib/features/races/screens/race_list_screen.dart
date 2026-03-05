import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/blocs/race/race_bloc.dart';

class RaceListScreen extends StatelessWidget {
  const RaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Provas do Campeonato')),
      body: BlocBuilder<RaceBloc, RaceState>(
        builder: (context, state) {
          if (state is RaceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RaceLoaded) {
            if (state.races.isEmpty) {
              return const Center(child: Text('Nenhuma corrida cadastrada.'));
            }
            return ListView.builder(
              itemCount: state.races.length,
              itemBuilder: (context, index) {
                final race = state.races[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.flag, size: 32),
                    title: Text(race.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Local: ${race.locationTitle}'),
                        Text('Data: ${dateFormat.format(race.date)}'),
                        if (race.isSprint)
                          Text(
                            'Fim de semana Sprint',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Button to insert results for this race
                        IconButton(
                          icon: const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                          ),
                          tooltip: 'Resultados',
                          onPressed: () {
                            context.push('/races/results', extra: race);
                          },
                        ),
                        // Button to edit race config
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            context.push('/races/form', extra: race);
                          },
                        ),
                        // Button to delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(context, race.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is RaceError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/races/form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Corrida'),
        content: const Text(
          'Tem certeza que deseja excluir esta corrida? Os resultados associados também serão excluídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<RaceBloc>().add(DeleteRace(id));
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
