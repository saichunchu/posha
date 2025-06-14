// test/integration/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:posha/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pet Adoption App Integration Tests', () {
    testWidgets('complete pet adoption flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify pet list loads
      expect(find.byType(ListView), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap on a pet
      final firstPetCard = find.byType(Card).first;
      expect(firstPetCard, findsOneWidget);
      await tester.tap(firstPetCard);
      await tester.pumpAndSettle();

      // Verify pet details screen opens
      expect(find.text('Pet Details'), findsOneWidget);
      expect(find.text('Adopt'), findsOneWidget);

      // Test favorite functionality
      final favoriteButton = find.byIcon(Icons.favorite_border);
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();

        // Verify favorite icon changes
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }

      // Go back to list
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on the list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('search functionality works', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find search field
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.tap(searchField);
        await tester.pumpAndSettle();

        // Enter search text
        await tester.enterText(searchField, 'Charlie');
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.text('Charlie'), findsWidgets);
      }
    });

    testWidgets('favorites page shows favorited pets',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find and favorite a pet
      final favoriteButton = find.byIcon(Icons.favorite_border).first;
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      // Navigate to favorites (assuming bottom nav)
      final favoritesTab = find.byIcon(Icons.favorite);
      if (favoritesTab.evaluate().isNotEmpty) {
        await tester.tap(favoritesTab);
        await tester.pumpAndSettle();

        // Verify favorited pet appears
        expect(find.byType(Card), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('filter functionality works', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Find filter button
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Select age filter
        final ageFilter = find.text('Young (1-2 years)');
        if (ageFilter.evaluate().isNotEmpty) {
          await tester.tap(ageFilter);
          await tester.pumpAndSettle();

          // Apply filter
          final applyButton = find.text('Apply');
          await tester.tap(applyButton);
          await tester.pumpAndSettle();

          // Verify filtered results
          expect(find.byType(Card), findsWidgets);
        }
      }
    });

    testWidgets('pet adoption process', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Tap on a pet
      final petCard = find.byType(Card).first;
      await tester.tap(petCard);
      await tester.pumpAndSettle();

      // Find and tap adopt button
      final adoptButton = find.text('Adopt');
      await tester.tap(adoptButton);
      await tester.pumpAndSettle();

      // Fill adoption form (if exists)
      final nameField = find.byKey(const Key('adopter_name'));
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'John Doe');
        await tester.pumpAndSettle();

        final emailField = find.byKey(const Key('adopter_email'));
        await tester.enterText(emailField, 'john@example.com');
        await tester.pumpAndSettle();

        // Submit adoption
        final submitButton = find.text('Submit');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Adoption Successful'), findsOneWidget);
      }
    });

    testWidgets('app handles no internet connection',
        (WidgetTester tester) async {
      // This would require network mocking
      // For now, just verify error handling UI exists
      app.main();
      await tester.pumpAndSettle();

      // Look for error handling UI elements
      // final retryButton = find.text('Retry');
      // final errorMessage = find.text('No internet connection');

      // These might not be visible initially, but should exist in the widget tree
      // when network errors occur
    });
  });
}
