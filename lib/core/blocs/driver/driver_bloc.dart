import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../database/database_helper.dart';
import '../../database/models/driver_model.dart';

// --- Events ---
abstract class DriverEvent extends Equatable {
  const DriverEvent();
  @override
  List<Object> get props => [];
}

class LoadDrivers extends DriverEvent {}

class AddDriver extends DriverEvent {
  final DriverModel driver;
  const AddDriver(this.driver);
  @override
  List<Object> get props => [driver];
}

class UpdateDriver extends DriverEvent {
  final DriverModel driver;
  const UpdateDriver(this.driver);
  @override
  List<Object> get props => [driver];
}

class DeleteDriver extends DriverEvent {
  final int id;
  const DeleteDriver(this.id);
  @override
  List<Object> get props => [id];
}

// --- States ---
abstract class DriverState extends Equatable {
  const DriverState();
  @override
  List<Object> get props => [];
}

class DriverInitial extends DriverState {}

class DriverLoading extends DriverState {}

class DriverLoaded extends DriverState {
  final List<DriverModel> drivers;
  const DriverLoaded(this.drivers);
  @override
  List<Object> get props => [drivers];
}

class DriverError extends DriverState {
  final String message;
  const DriverError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DatabaseHelper dbHelper;

  DriverBloc({required this.dbHelper}) : super(DriverInitial()) {
    on<LoadDrivers>((event, emit) async {
      emit(DriverLoading());
      try {
        final drivers = await dbHelper.getDrivers();
        emit(DriverLoaded(drivers));
      } catch (e) {
        emit(DriverError(e.toString()));
      }
    });

    on<AddDriver>((event, emit) async {
      try {
        await dbHelper.insertDriver(event.driver);
        add(LoadDrivers()); // Reload list after add
      } catch (e) {
        emit(DriverError(e.toString()));
      }
    });

    on<UpdateDriver>((event, emit) async {
      try {
        await dbHelper.updateDriver(event.driver);
        add(LoadDrivers());
      } catch (e) {
        emit(DriverError(e.toString()));
      }
    });

    on<DeleteDriver>((event, emit) async {
      try {
        await dbHelper.deleteDriver(event.id);
        add(LoadDrivers());
      } catch (e) {
        emit(DriverError(e.toString()));
      }
    });
  }
}
