import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class ScoringEvent extends Equatable {
  const ScoringEvent();

  @override
  List<Object> get props => [];
}

class CalculatePointsEvent extends ScoringEvent {
  final bool isSprint;
  final double expectedDistance;
  final double completedDistance;
  final int position;
  final bool fastestLap;

  const CalculatePointsEvent({
    required this.isSprint,
    required this.expectedDistance,
    required this.completedDistance,
    required this.position,
    this.fastestLap = false,
  });

  @override
  List<Object> get props => [
    isSprint,
    expectedDistance,
    completedDistance,
    position,
    fastestLap,
  ];
}

// --- States ---
abstract class ScoringState extends Equatable {
  const ScoringState();

  @override
  List<Object> get props => [];
}

class ScoringInitial extends ScoringState {}

class PointsCalculated extends ScoringState {
  final int points;

  const PointsCalculated(this.points);

  @override
  List<Object> get props => [points];
}

// --- BLoC ---
class ScoringBloc extends Bloc<ScoringEvent, ScoringState> {
  ScoringBloc() : super(ScoringInitial()) {
    on<CalculatePointsEvent>((event, emit) {
      int points = _calculateF1Points(
        event.isSprint,
        event.expectedDistance,
        event.completedDistance,
        event.position,
        event.fastestLap,
      );
      emit(PointsCalculated(points));
    });
  }

  int _calculateF1Points(
    bool isSprint,
    double expectedDistance,
    double completedDistance,
    int position,
    bool fastestLap,
  ) {
    if (position <= 0) return 0; // Invalid position

    if (isSprint) {
      // Sprint Race Points: Top 8
      const sprintPoints = [8, 7, 6, 5, 4, 3, 2, 1];
      if (position <= 8) {
        return sprintPoints[position - 1];
      }
      return 0;
    }

    // Calculate percentage of distance completed
    double percentageCompleted = 0;
    if (expectedDistance > 0) {
      percentageCompleted = (completedDistance / expectedDistance) * 100;
    }

    int basePoints = 0;

    // Short Races exceptions
    if (percentageCompleted < 25) {
      // Assuming min 2 green laps as implicitly checked before feeding to bloc
      // Top 5
      const points25 = [6, 4, 3, 2, 1];
      if (position <= 5) {
        basePoints = points25[position - 1];
      }
    } else if (percentageCompleted >= 25 && percentageCompleted < 50) {
      // Top 9
      const points50 = [13, 10, 8, 6, 5, 4, 3, 2, 1];
      if (position <= 9) {
        basePoints = points50[position - 1];
      }
    } else if (percentageCompleted >= 50 && percentageCompleted < 75) {
      // Top 10
      const points75 = [19, 14, 12, 9, 8, 6, 5, 3, 2, 1];
      if (position <= 10) {
        basePoints = points75[position - 1];
      }
    } else {
      // Standard Base (> 75%)
      const standardPoints = [25, 18, 15, 12, 10, 8, 6, 4, 2, 1];
      if (position <= 10) {
        basePoints = standardPoints[position - 1];
      }
    }

    // Fastest lap point (only standard races if top 10)
    if (fastestLap && position <= 10 && percentageCompleted >= 50) {
      // F1 fast lap rules typically require >50% completion
      basePoints += 1;
    }

    return basePoints;
  }
}
