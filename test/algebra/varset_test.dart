import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/algebra/varset.dart';

main() {
  test('Associativity.', () {
    expect(
      Varset('x') * Varset('y') * Varset('z'),
      Varset('x') * (Varset('y') * Varset('z')),
    );
    expect(
      Varset('x') + Varset('y') + Varset('z'),
      Varset('x') + (Varset('y') + Varset('z')),
    );
    expect(
      Varset('x') / Varset('y') / Varset('z'),
      Varset('x') / (Varset('y') / Varset('z')),
    );
  });

  test('Distributivity.', () {
    expect(
      Varset('x') * (Varset('y') + Varset('z')),
      Varset('x') * Varset('y') + Varset('x') * Varset('z'),
    );
    expect(
      (Varset('x') + Varset('y')) * Varset('z'),
      Varset('x') * Varset('z') + Varset('y') * Varset('z'),
    );
    expect(
      Varset('x') / (Varset('y') + Varset('z')),
      Varset('x') / Varset('y') + Varset('x') / Varset('z'),
    );
    expect(
      (Varset('x') + Varset('y')) / Varset('z'),
      Varset('x') / Varset('z') + Varset('y') / Varset('z'),
    );
  });

  test('No commutativity.', () {
    expect(
      Varset('x') * Varset('y'),
      isNot(Varset('y') * Varset('x')),
    );
    expect(
      Varset('x') + Varset('y'),
      isNot(Varset('y') + Varset('x')),
    );
    expect(
      Varset('x') / Varset('y'),
      isNot(Varset('y') / Varset('x')),
    );
  });
}
