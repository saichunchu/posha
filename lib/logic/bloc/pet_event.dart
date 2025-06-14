abstract class PetEvent {}

class LoadPetsEvent extends PetEvent {}

class SearchPetEvent extends PetEvent {
  final String query;
  SearchPetEvent(this.query);
}

class AdoptPetEvent extends PetEvent {
  final String petId;
  AdoptPetEvent(this.petId);
}

class ToggleFavoriteEvent extends PetEvent {
  final String petId;
  ToggleFavoriteEvent(this.petId);
}
