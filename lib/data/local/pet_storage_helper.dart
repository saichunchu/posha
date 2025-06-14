import 'package:hive/hive.dart';

class PetStorageHelper {
  static const String favoritedBoxName = 'favoritedPetsBox';
  static const String adoptedBoxName = 'adoptedPetsBox';

  // Initialize Hive boxes (must be called before any other methods)
  static Future<void> init() async {
    await Hive.openBox<String>(favoritedBoxName);
    await Hive.openBox<String>(adoptedBoxName);
  }

  static Box<String> _favoritedBox() => Hive.box<String>(favoritedBoxName);
  static Box<String> _adoptedBox() => Hive.box<String>(adoptedBoxName);

  // Get all favorited pet IDs
  static List<String> getFavoritedPetIds() {
    return _favoritedBox().values.toList();
  }

  // Get all adopted pet IDs
  static List<String> getAdoptedPetIds() {
    return _adoptedBox().values.toList();
  }

  // Save a pet as favorited
  static Future<void> addToFavorites(String petId) async {
    if (!_favoritedBox().values.contains(petId)) {
      await _favoritedBox().put(petId, petId);
    }
  }

  // Remove pet from favorites
  static Future<void> removeFromFavorites(String petId) async {
    await _favoritedBox().delete(petId);
  }

  // Save a pet as adopted
  static Future<void> markAsAdopted(String petId) async {
    if (!_adoptedBox().values.contains(petId)) {
      await _adoptedBox().put(petId, petId);
    }
  }

  // Check if pet is favorited
  static bool isFavorited(String petId) {
    return _favoritedBox().containsKey(petId);
  }

  // Check if pet is adopted
  static bool isAdopted(String petId) {
    return _adoptedBox().containsKey(petId);
  }

  // Get count
  static int getFavoritesCount() => _favoritedBox().length;
  static int getAdoptedCount() => _adoptedBox().length;

  // Clear all
  static Future<void> clearAll() async {
    await _favoritedBox().clear();
    await _adoptedBox().clear();
  }

  static Future<void> clearFavorites() async {
    await _favoritedBox().clear();
  }

  static Future<void> clearAdopted() async {
    await _adoptedBox().clear();
  }
}
