import 'package:flutter_test/flutter_test.dart';
import 'package:listeo/screens/cooking_screen.dart';

void main() {
  group('Cooking Timer Detector Tests', () {
    test('should detect minutes', () {
      final t1 = detectTimer('Faire cuire 15 minutes.');
      expect(t1, isNotNull);
      expect(t1!.seconds, equals(15 * 60));
      expect(t1.label.toLowerCase(), contains('15 minutes'));

      final t2 = detectTimer('Mijoter 5 min à feu doux.');
      expect(t2, isNotNull);
      expect(t2!.seconds, equals(5 * 60));
      expect(t2.label.toLowerCase(), contains('5 min'));
    });

    test('should detect hours', () {
      final t1 = detectTimer('Laisser cuire pendant 2 heures au four.');
      expect(t1, isNotNull);
      expect(t1!.seconds, equals(2 * 3600));
      expect(t1.label.toLowerCase(), contains('2 heures'));

      final t2 = detectTimer('Infuser pendant 1.5 h.');
      expect(t2, isNotNull);
      expect(t2!.seconds, equals((1.5 * 3600).round()));
      expect(t2.label.toLowerCase(), contains('1.5 h'));
    });

    test('should return null if no timer is found', () {
      final t1 = detectTimer('Faire dorer les lardons.');
      expect(t1, isNull);

      final t2 = detectTimer('Ajouter 2 cuillères à soupe de sucre.');
      expect(t2, isNull); // "2 cuillères" is not a time
    });
  });
}
