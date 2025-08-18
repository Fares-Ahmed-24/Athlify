import 'package:Athlify/models/trainer_model.dart';

abstract class getFieldState {}

class getFieldsInitial extends getFieldState {}

class getFieldsLoading extends getFieldState {}

class getFieldsSuccess extends getFieldState {
  final List<Trainer> trainers;

  getFieldsSuccess(this.trainers);
}

class getFieldsFailure extends getFieldState {}
