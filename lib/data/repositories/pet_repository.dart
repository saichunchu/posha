import '../models/pet_model.dart';
import '../../services/api_service.dart';

import 'dart:async';

class PetRepository {
  final ApiService apiService;

  PetRepository({required this.apiService});

  Future<List<Pet>> getAllPets() async {
    return await apiService.fetchPets();
  }

  Future<List<Pet>> searchPets(String query) async {
    final allPets = await apiService.fetchPets();
    return allPets
        .where((pet) => pet.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
