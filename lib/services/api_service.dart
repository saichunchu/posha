import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/pet_model.dart';

class ApiService {
  static const String _baseUrl = 'https://684c30aded2578be881e02c1.mockapi.io';
  static const String _petsEndpoint = '$_baseUrl/pets';

  /// Fetches all pets from the MockAPI
  Future<List<Pet>> fetchPets() async {
    final response = await http.get(Uri.parse(_petsEndpoint));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pet.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch pets (code ${response.statusCode})');
    }
  }

  /// Updates a pet's favorite or adoption status
  Future<void> updatePet(Pet pet) async {
    final url = Uri.parse('$_petsEndpoint/${pet.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pet.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update pet (code ${response.statusCode})');
    }
  }
}
