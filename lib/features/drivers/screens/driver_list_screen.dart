import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/blocs/driver/driver_bloc.dart';
import '../../../core/blocs/team/team_bloc.dart';

class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilotos')),
      body: BlocBuilder<DriverBloc, DriverState>(
        builder: (context, driverState) {
          if (driverState is DriverLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (driverState is DriverLoaded) {
            if (driverState.drivers.isEmpty) {
              return const Center(child: Text('Nenhum piloto cadastrado.'));
            }
            return ListView.builder(
              itemCount: driverState.drivers.length,
              itemBuilder: (context, index) {
                final driver = driverState.drivers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        driver.number.toString(),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(driver.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nacionalidade: ${driver.nationality}'),
                        // We could look up team name here if needed using context.read<TeamBloc>()
                        _buildTeamName(context, driver.teamId),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            context.push('/drivers/form', extra: driver);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(context, driver.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (driverState is DriverError) {
            return Center(child: Text('Erro: ${driverState.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/drivers/form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTeamName(BuildContext context, int teamId) {
    return BlocBuilder<TeamBloc, TeamState>(
      builder: (context, state) {
        if (state is TeamLoaded) {
          try {
            final team = state.teams.firstWhere((t) => t.id == teamId);
            return Text(
              'Equipe: ${team.name}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            );
          } catch (e) {
            return const SizedBox();
          }
        }
        return const SizedBox();
      },
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Piloto'),
        content: const Text('Tem certeza que deseja excluir este piloto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DriverBloc>().add(DeleteDriver(id));
              Navigator.pop(ctx);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
