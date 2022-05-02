import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart';

void main() {
  group('equalTo', () {
    test('returns true when type is `DodgeModifier` and properties are equal',
        () {
      expect(DodgeModifier() == DodgeModifier(), true);
      expect(
          DodgeModifier(ratio: 0.5, symmetric: false) ==
              DodgeModifier(ratio: 0.5, symmetric: false),
          true);
    });

    test('returns false when type is not `DodgeModifier`', () {
      expect(DodgeModifier() == SymmetricModifier(), false);
    });

    test('returns false when some property differs', () {
      expect(DodgeModifier(ratio: 0.1) == DodgeModifier(ratio: 0.2), false);
      expect(DodgeModifier(symmetric: true) == DodgeModifier(symmetric: false),
          false);
    });
  });
}
