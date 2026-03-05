import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../database/database_helper.dart';
import '../../database/models/team_model.dart';

// --- Events ---
abstract class TeamEvent extends Equatable {
  const TeamEvent();
  @override
  List<Object> get props => [];
}

class LoadTeams extends TeamEvent {}

class AddTeam extends TeamEvent {
  final TeamModel team;
  const AddTeam(this.team);
  @override
  List<Object> get props => [team];
}

class UpdateTeam extends TeamEvent {
  final TeamModel team;
  const UpdateTeam(this.team);
  @override
  List<Object> get props => [team];
}

class DeleteTeam extends TeamEvent {
  final int id;
  const DeleteTeam(this.id);
  @override
  List<Object> get props => [id];
}

// --- States ---
abstract class TeamState extends Equatable {
  const TeamState();
  @override
  List<Object> get props => [];
}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<TeamModel> teams;
  const TeamLoaded(this.teams);
  @override
  List<Object> get props => [teams];
}

class TeamError extends TeamState {
  final String message;
  const TeamError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class TeamBloc extends Bloc<TeamEvent, TeamState> {
  final DatabaseHelper dbHelper;

  TeamBloc({required this.dbHelper}) : super(TeamInitial()) {
    on<LoadTeams>((event, emit) async {
      emit(TeamLoading());
      try {
        final teams = await dbHelper.getTeams();
        emit(TeamLoaded(teams));
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<AddTeam>((event, emit) async {
      try {
        await dbHelper.insertTeam(event.team);
        add(LoadTeams());
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<UpdateTeam>((event, emit) async {
      try {
        await dbHelper.updateTeam(event.team);
        add(LoadTeams());
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });

    on<DeleteTeam>((event, emit) async {
      try {
        await dbHelper.deleteTeam(event.id);
        add(LoadTeams());
      } catch (e) {
        emit(TeamError(e.toString()));
      }
    });
  }
}
