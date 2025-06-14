import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posha/data/models/pet_model.dart';
import 'package:posha/presentation/widgets/pet_card.dart';

void main() {
  group('PetCard Widget Tests', () {
    late Pet testPet;

    setUp(() {
      testPet = Pet(
        id: '1',
        name: 'Charlie',
        age: 2,
        price: 100.0,
        imageUrl: 'https://example.com/image.jpg',
        isAdopted: false,
        isFavorited: false,
      );
    });

    testWidgets('should display pet information correctly',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCard(
              pet: testPet,
              // onPressed: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Age: 2'), findsOneWidget);
      expect(find.text('\$100.0'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should show favorite icon when pet is favorited',
        (WidgetTester tester) async {
      // Arrange
      final favoritedPet = testPet.copyWith(isFavorited: true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCard(
              pet: favoritedPet,
              // onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCard(
              pet: testPet,
              // onTap: () => wasTapped = true,
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PetCard));
      await tester.pump();

      // Assert
      expect(wasTapped, true);
    });

    testWidgets('should call onFavoriteToggle when favorite button is tapped',
        (WidgetTester tester) async {
      // Arrange
      bool favoriteToggled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCard(
              pet: testPet,
              // onTap: () {},
              onFavoriteToggle: () => favoriteToggled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      // Assert
      expect(favoriteToggled, true);
    });

    testWidgets('should show adopted label when pet is adopted',
        (WidgetTester tester) async {
      // Arrange
      final adoptedPet = testPet.copyWith(isAdopted: true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetCard(
              pet: adoptedPet,
              // onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('ADOPTED'), findsOneWidget);
    });
  });
}
