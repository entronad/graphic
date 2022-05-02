import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart';

void main() {
  group('equalTo', () {
    test('returns true when type is `JitterModifier` and properties are equal',
        () {
      expect(JitterModifier() == JitterModifier(), true);
      expect(JitterModifier(ratio: 0.25) == JitterModifier(ratio: 0.25), true);
    });

    test('returns false when type is not `JitterModifier`', () {
      expect(JitterModifier() == SymmetricModifier(), false);
    });

    test('returns false when some property differs', () {
      expect(JitterModifier(ratio: 0.25) == JitterModifier(ratio: 0.3), false);
    });
  });
}
