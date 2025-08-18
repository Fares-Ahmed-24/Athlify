import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Athlify/cubits/field_trainer_cubit/getField_state.dart';
import 'package:Athlify/models/trainer_model.dart';
import 'package:Athlify/services/trainer.dart';

class getFieldsCubit extends Cubit<getFieldState> {
  TrainerService trainerService;

  List<Trainer> trainers = [];
  getFieldsCubit(this.trainerService) : super(getFieldsInitial());

  // Modify this method to accept a 'type' parameter
  Future<void> getTrainers({String type = 'All'}) async {
    emit(getFieldsLoading());
    try {
      trainers = await trainerService.getTrainerByType(
          type: type); // Fetch trainers by type
      emit(getFieldsSuccess(trainers));
    } catch (e) {
      emit(getFieldsFailure());
    }
  }
}
