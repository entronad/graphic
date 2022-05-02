import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart';

void main() {
  group('equalTo', () {
    test('returns true when type is `SymmetricModifier`', () {
      expect(SymmetricModifier() == SymmetricModifier(), true);
    });

    test('returns false when type is not `SymmetricModifier`', () {
      expect(SymmetricModifier() == DodgeModifier(), false);
    });
  });
}
