import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart';

void main() {
  group('equalTo', () {
    test('returns true when type is `StackModifier`', () {
      expect(StackModifier() == StackModifier(), true);
    });

    test('returns false when type is not `StackModifier`', () {
      expect(StackModifier() == DodgeModifier(), false);
    });
  });
}
