import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/blocs/driver/driver_bloc.dart';
import '../../../core/blocs/race/race_bloc.dart';
import 'widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Corridas F1'),
        actions: [_buildTopMenu(context)],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DriverBloc>().add(LoadDrivers());
          context.read<RaceBloc>().add(LoadRaces());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNextRaceCard(context),
                const SizedBox(height: 24),
                Text(
                  'Classificação de Pilotos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStandingsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu_open),
      tooltip: 'Ações Rápidas',
      onSelected: (String result) {
        switch (result) {
          case 'races':
            context.push('/races');
            break;
          case 'drivers':
            context.push('/drivers');
            break;
          case 'teams':
            context.push('/teams');
            break;
          case 'profile':
            context.push('/profile');
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'races',
          child: Text('Próxima Corrida / Provas'),
        ),
        const PopupMenuItem<String>(
          value: 'drivers',
          child: Text('Cadastro de Pilotos'),
        ),
        const PopupMenuItem<String>(
          value: 'teams',
          child: Text('Cadastro de Equipes'),
        ),
        const PopupMenuItem<String>(value: 'profile', child: Text('Perfil')),
      ],
    );
  }

  Widget _buildNextRaceCard(BuildContext context) {
    return BlocBuilder<RaceBloc, RaceState>(
      builder: (context, state) {
        if (state is RaceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RaceLoaded) {
          final now = DateTime.now();
          // Find the first race that hasn't happened yet based on date (assuming completed races are strictly past dates)
          // For a real app we might rely on a 'completed' flag.
          final upcomingRaces = state.races
              .where((r) => r.date.isAfter(now))
              .toList();

          if (upcomingRaces.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Nenhuma corrida futura programada.'),
              ),
            );
          }

          final nextRace = upcomingRaces.first;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

          return Card(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Próxima Corrida',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    nextRace.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(nextRace.locationTitle),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(dateFormat.format(nextRace.date)),
                    ],
                  ),
                  if (nextRace.isSprint)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Chip(
                        label: const Text('Fim de Semana Sprint'),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.tertiaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStandingsList(BuildContext context) {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        if (state is DriverLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DriverLoaded) {
          if (state.drivers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Nenhum piloto cadastrado. Vá ao menu para cadastrar.',
                ),
              ),
            );
          }

          // List is already sorted by points_total descending from SQL
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.drivers.length,
            itemBuilder: (context, index) {
              final driver = state.drivers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForPosition(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        driver.number.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    driver.nationality,
                  ), // Ideally we would join with Teams to show Team Name here
                  trailing: Text(
                    '${driver.pointsTotal} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is DriverError) {
          return Center(child: Text('Erro: ${state.message}'));
        }
        return const SizedBox();
      },
    );
  }

  Color _getColorForPosition(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey.shade400;
    if (index == 2) return Colors.brown.shade400;
    return Colors.grey.shade800;
  }
}
