abstract class AddTrainerState {}

class AddTrainerInitial extends AddTrainerState {}

class AddTrainerLoading extends AddTrainerState {}

class AddTrainerSuccess extends AddTrainerState {
  final String message;

  AddTrainerSuccess(this.message);
}

class AddTrainerFailure extends AddTrainerState {
  final String error;

  AddTrainerFailure(this.error);
}
