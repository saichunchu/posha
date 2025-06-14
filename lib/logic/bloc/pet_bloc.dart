import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'pet_event.dart';
import 'pet_state.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/repositories/pet_repository.dart';
import '../../../data/local/pet_storage_helper.dart';

class PetBloc extends Bloc<PetEvent, PetState> {
  final PetRepository repository;
  List<Pet> _allPets = [];
  final Box<Pet> petBox = Hive.box<Pet>('pets');

  PetBloc({required this.repository}) : super(PetInitialState()) {
    on<LoadPetsEvent>(_onLoadPets);
    on<SearchPetEvent>(_onSearchPet);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<AdoptPetEvent>(_onAdoptPet);
  }

  Future<void> _onLoadPets(LoadPetsEvent event, Emitter<PetState> emit) async {
    emit(PetLoadingState());
    try {
      final apiPets = await repository.getAllPets();

      // Sync with stored favorites/adopted from local storage
      final favoritedIds = PetStorageHelper.getFavoritedPetIds();
      final adoptedIds = PetStorageHelper.getAdoptedPetIds();

      final petsWithLocalFlags = apiPets.map((pet) {
        return pet.copyWith(
          isFavorited: favoritedIds.contains(pet.id),
          isAdopted: adoptedIds.contains(pet.id),
        );
      }).toList();

      // Save to Hive
      await petBox.clear();
      for (var pet in petsWithLocalFlags) {
        await petBox.put(pet.id, pet);
      }

      _allPets = petsWithLocalFlags;
      emit(PetLoadedState(_allPets));
    } catch (e) {
      if (_allPets.isEmpty) {
        emit(PetErrorState('Failed to load pets: ${e.toString()}'));
      } else {
        emit(PetLoadedState(_allPets));
      }
    }
  }

  void _onSearchPet(SearchPetEvent event, Emitter<PetState> emit) {
    if (event.query.trim().isEmpty) {
      emit(PetLoadedState(_allPets));
      return;
    }

    final filtered = _allPets
        .where(
            (pet) => pet.name.toLowerCase().contains(event.query.toLowerCase()))
        .toList();

    emit(PetLoadedState(filtered));
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<PetState> emit) async {
    final updatedPets = <Pet>[];

    for (final pet in _allPets) {
      if (pet.id == event.petId) {
        final isNowFavorited = !pet.isFavorited;

        final updatedPet = pet.copyWith(isFavorited: isNowFavorited);
        await petBox.put(updatedPet.id, updatedPet);

        if (isNowFavorited) {
          await PetStorageHelper.addToFavorites(updatedPet.id);
        } else {
          await PetStorageHelper.removeFromFavorites(updatedPet.id);
        }

        updatedPets.add(updatedPet);
      } else {
        updatedPets.add(pet);
      }
    }

    _allPets = updatedPets;
    emit(PetLoadedState(_allPets));
  }

  Future<void> _onAdoptPet(AdoptPetEvent event, Emitter<PetState> emit) async {
    final updatedPets = <Pet>[];

    for (final pet in _allPets) {
      if (pet.id == event.petId) {
        final updatedPet = pet.copyWith(isAdopted: true);
        await petBox.put(updatedPet.id, updatedPet);

        await PetStorageHelper.markAsAdopted(updatedPet.id);

        updatedPets.add(updatedPet);
      } else {
        updatedPets.add(pet);
      }
    }

    _allPets = updatedPets;
    emit(PetLoadedState(_allPets));
  }
}
