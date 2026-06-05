import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/data/store.dart';
import 'package:listeo/models/models.dart';
import 'package:listeo/screens/shopping_trip_screen.dart';
import 'package:listeo/widgets/primitives.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Shopping Trip Screen UI & Flow Tests', () {
    testWidgets('renders list details, timer, progress, and responds to actions', (WidgetTester tester) async {
      final store = AppStore();
      await store.init();
      store.locale = 'fr'; // Use French

      // Create a list with custom items
      final listId = store.createList('Courses Hebdo', [], 'green');
      store.addLooseItem(listId, name: 'Lait de soja', qty: 2.0, unit: 'L');
      store.addLooseItem(listId, name: 'Pommes', qty: 6.0, unit: 'pc');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppStore>.value(
            value: store,
            child: ShoppingTripScreen(listId: listId),
          ),
        ),
      );

      await tester.pump();

      // Verify Header details
      expect(find.text('Mode Course'), findsOneWidget);
      expect(find.text('Courses Hebdo'), findsOneWidget);

      // Verify elapsed timer is present and starts at 00:00
      expect(find.text('TEMPS ÉCOULÉ'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);

      // Verify progress is 0 / 2
      expect(find.text('0 / 2'), findsOneWidget);

      // Verify category headers: Lait de soja -> Produits Laitiers & Œufs (cat.dairy), Pommes -> Fruits & Légumes (cat.fruits)
      expect(find.text('FRUITS & LÉGUMES'), findsOneWidget);
      expect(find.text('PRODUITS LAITIERS & ŒUFS'), findsOneWidget);

      // Verify items render
      expect(find.text('Lait de soja'), findsOneWidget);
      expect(find.text('Pommes'), findsOneWidget);

      // Check first item (Pommes)
      // Checkboxes are inside InkWell / Pressable. Let's find by type and tap
      final checkboxFinder = find.byType(Pressable);
      // We have multiple Pressables: Wake lock, Exit button, category accordions, checkbox pressables, qty chips
      // Let's find the checkboxes by looking for checked/unchecked structures.
      // Or simply tap the item row by tapping the text 'Pommes' since the InkWell onTap is on the whole row!
      await tester.tap(find.text('Pommes'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify progress is now 1 / 2
      expect(find.text('1 / 2'), findsOneWidget);

      // Tap the wake lock button to check simulated wake lock state
      expect(find.text('Écran actif'), findsOneWidget);
      await tester.tap(find.text('Écran actif'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Tap the exit button to test confirmation dialog when incomplete
      final exitBtn = find.byIcon(Icons.close_rounded);
      expect(exitBtn, findsOneWidget);
      await tester.tap(exitBtn);
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify confirmation dialog is visible
      expect(find.text('Quitter le mode course ?'), findsOneWidget);
      // Cancel exit
      expect(find.text('continuer'), findsOneWidget);
      await tester.tap(find.text('continuer'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Check last item to complete shopping
      await tester.tap(find.text('Lait de soja'));
      await tester.pump();
      
      // Let timer tick or pump duration to let confetti finish/transition settle
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify completion overlay is displayed
      expect(find.text('Courses terminées ! 🎉'), findsOneWidget);
      expect(find.text('retour à la liste'), findsOneWidget);

      // Go back to the list detail screen
      await tester.tap(find.text('retour à la liste'));
      await tester.pump();
      await tester.pumpAndSettle();
    });
  });
}
