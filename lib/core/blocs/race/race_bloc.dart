import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../database/database_helper.dart';
import '../../database/models/race_model.dart';

// --- Events ---
abstract class RaceEvent extends Equatable {
  const RaceEvent();
  @override
  List<Object> get props => [];
}

class LoadRaces extends RaceEvent {}

class AddRace extends RaceEvent {
  final RaceModel race;
  const AddRace(this.race);
  @override
  List<Object> get props => [race];
}

class UpdateRace extends RaceEvent {
  final RaceModel race;
  const UpdateRace(this.race);
  @override
  List<Object> get props => [race];
}

class DeleteRace extends RaceEvent {
  final int id;
  const DeleteRace(this.id);
  @override
  List<Object> get props => [id];
}

// --- States ---
abstract class RaceState extends Equatable {
  const RaceState();
  @override
  List<Object> get props => [];
}

class RaceInitial extends RaceState {}

class RaceLoading extends RaceState {}

class RaceLoaded extends RaceState {
  final List<RaceModel> races;
  const RaceLoaded(this.races);
  @override
  List<Object> get props => [races];
}

class RaceError extends RaceState {
  final String message;
  const RaceError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class RaceBloc extends Bloc<RaceEvent, RaceState> {
  final DatabaseHelper dbHelper;

  RaceBloc({required this.dbHelper}) : super(RaceInitial()) {
    on<LoadRaces>((event, emit) async {
      emit(RaceLoading());
      try {
        final races = await dbHelper.getRaces();
        emit(RaceLoaded(races));
      } catch (e) {
        emit(RaceError(e.toString()));
      }
    });

    on<AddRace>((event, emit) async {
      try {
        await dbHelper.insertRace(event.race);
        add(LoadRaces());
      } catch (e) {
        emit(RaceError(e.toString()));
      }
    });

    on<UpdateRace>((event, emit) async {
      try {
        await dbHelper.updateRace(event.race);
        add(LoadRaces());
      } catch (e) {
        emit(RaceError(e.toString()));
      }
    });

    on<DeleteRace>((event, emit) async {
      try {
        await dbHelper.deleteRace(event.id);
        add(LoadRaces());
      } catch (e) {
        emit(RaceError(e.toString()));
      }
    });
  }
}
