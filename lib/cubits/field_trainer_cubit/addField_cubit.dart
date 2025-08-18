import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Athlify/cubits/field_trainer_cubit/addField_state.dart';
import 'package:Athlify/services/trainer.dart';

class AddTrainerCubit extends Cubit<AddTrainerState> {
  final TrainerService trainerService;

  AddTrainerCubit(this.trainerService) : super(AddTrainerInitial());

  Future<void> addTrainer({
    required String name,
    required String image,
    required String email,
    required String price,
    required String phone,
    required String category,
    required String location,
    required String bio,
    required int experienceYears,
    required bool isAvailable,
    required List<String> gallery,
    required List<String> certifications,
  }) async {
    emit(AddTrainerLoading());

    final result = await trainerService.addTrainerCard(
      name,
      image,
      email,
      price,
      phone,
      category,
      location,
      isAvailable,
      bio,
      experienceYears,
      gallery,
      certifications,
    );

    if (result['statusCode'] == 200 || result['statusCode'] == 201) {
      emit(AddTrainerSuccess(result['message']));
    } else {
      emit(AddTrainerFailure(result['message']));
    }
  }
}
