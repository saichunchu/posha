import 'package:flutter_test/flutter_test.dart';
import 'package:posha/data/models/pet_model.dart';

void main() {
  group('Pet Model Tests', () {
    test('should create Pet from JSON correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'Charlie',
        'age': 2,
        'price': 100.0,
        'imageUrl': 'https://example.com/image.jpg',
        'isAdopted': false,
        'isFavorited': true,
      };

      // Act
      final pet = Pet.fromJson(json);

      // Assert
      expect(pet.id, '1');
      expect(pet.name, 'Charlie');
      expect(pet.age, 2);
      expect(pet.price, 100.0);
      expect(pet.imageUrl, 'https://example.com/image.jpg');
      expect(pet.isAdopted, false);
      expect(pet.isFavorited, true);
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'name': 'Unknown Pet',
      };

      // Act
      final pet = Pet.fromJson(json);

      // Assert
      expect(pet.name, 'Unknown Pet');
      expect(pet.age, 0);
      expect(pet.price, 0.0);
      expect(pet.isAdopted, false);
      expect(pet.isFavorited, false);
    });

    test('should convert Pet to JSON correctly', () {
      // Arrange
      final pet = Pet(
        id: '1',
        name: 'Charlie',
        age: 2,
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        isAdopted: false,
        isFavorited: true,
      );

      // Act
      final json = pet.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'Charlie');
      expect(json['age'], 2);
      expect(json['price'], 100.0);
      expect(json['imageUrl'], 'https://example.com/image.jpg');
      expect(json['isAdopted'], false);
      expect(json['isFavorited'], true);
    });

    test('copyWith should update only specified fields', () {
      // Arrange
      final pet = Pet(
        id: '1',
        name: 'Charlie',
        age: 2,
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        isAdopted: false,
        isFavorited: false,
      );

      // Act
      final updatedPet = pet.copyWith(
        isFavorited: true,
        isAdopted: true,
      );

      // Assert
      expect(updatedPet.id, '1');
      expect(updatedPet.name, 'Charlie');
      expect(updatedPet.age, 2);
      expect(updatedPet.price, 100.0);
      expect(updatedPet.imageUrl, 'https://example.com/image.jpg');
      expect(updatedPet.isAdopted, true);
      expect(updatedPet.isFavorited, true);
    });
  });
}
