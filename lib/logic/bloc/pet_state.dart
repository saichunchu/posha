import '../../../data/models/pet_model.dart';

abstract class PetState {}

class PetInitialState extends PetState {}

class PetLoadingState extends PetState {}

class PetLoadedState extends PetState {
  final List<Pet> pets;
  PetLoadedState(this.pets);
}

class PetErrorState extends PetState {
  final String message;
  PetErrorState(this.message);
}
