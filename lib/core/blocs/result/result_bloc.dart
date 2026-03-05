import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../database/database_helper.dart';
import '../../database/models/result_model.dart';

// --- Events ---
abstract class ResultEvent extends Equatable {
  const ResultEvent();
  @override
  List<Object> get props => [];
}

class LoadResultsForRace extends ResultEvent {
  final int raceId;
  const LoadResultsForRace(this.raceId);
  @override
  List<Object> get props => [raceId];
}

class AddResult extends ResultEvent {
  final ResultModel result;
  const AddResult(this.result);
  @override
  List<Object> get props => [result];
}

class DeleteResult extends ResultEvent {
  final int id;
  final int pointsAwarded;
  final int driverId;
  final int raceId;

  const DeleteResult(this.id, this.pointsAwarded, this.driverId, this.raceId);
  @override
  List<Object> get props => [id, pointsAwarded, driverId, raceId];
}

// --- States ---
abstract class ResultState extends Equatable {
  const ResultState();
  @override
  List<Object> get props => [];
}

class ResultInitial extends ResultState {}

class ResultLoading extends ResultState {}

class ResultLoaded extends ResultState {
  final List<ResultModel> results;
  final int raceId;
  const ResultLoaded(this.results, this.raceId);
  @override
  List<Object> get props => [results, raceId];
}

class ResultError extends ResultState {
  final String message;
  const ResultError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class ResultBloc extends Bloc<ResultEvent, ResultState> {
  final DatabaseHelper dbHelper;

  ResultBloc({required this.dbHelper}) : super(ResultInitial()) {
    on<LoadResultsForRace>((event, emit) async {
      emit(ResultLoading());
      try {
        final results = await dbHelper.getResultsForRace(event.raceId);
        emit(ResultLoaded(results, event.raceId));
      } catch (e) {
        emit(ResultError(e.toString()));
      }
    });

    on<AddResult>((event, emit) async {
      try {
        await dbHelper.insertResult(event.result);
        add(LoadResultsForRace(event.result.raceId));
      } catch (e) {
        emit(ResultError(e.toString()));
      }
    });

    on<DeleteResult>((event, emit) async {
      try {
        await dbHelper.deleteResult(
          event.id,
          event.pointsAwarded,
          event.driverId,
        );
        add(
          LoadResultsForRace(event.raceId),
        ); // Refresh the specific race results
      } catch (e) {
        emit(ResultError(e.toString()));
      }
    });
  }
}
