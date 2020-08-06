import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/coord/cartesian.dart';

main() {
  group('basic', () {
    final plot = Rect.fromLTRB(0, 0, 400, 400);
    final coord = CartesianCoordComponent()..setRegion(plot);

    test('convert point', () {
      Offset p = Offset(0, 0);
      p = coord.convertPoint(p);
      expect(p.dx, 0);
      expect(p.dy, 400);

      p = Offset(0, 1);
      p = coord.convertPoint(p);
      expect(p.dx, 0);
      expect(p.dy, 0);

      p = Offset(1, 0.5);
      p = coord.convertPoint(p);
      expect(p.dx, 400);
      expect(p.dy, 200);

      p = Offset(0.3, 0.7);
      p = coord.convertPoint(p);
      expect(p.dx, 120);
      expect(p.dy, 120);
    });

    test('invert point', () {
      Offset p = Offset(200, 200);
      p = coord.invertPoint(p);
      expect(p.dx, 0.5);
      expect(p.dy, 0.5);

      p = Offset(0, 400);
      p = coord.invertPoint(p);
      expect(p.dx, 0);
      expect(p.dy, 0);

      p = Offset(400, 400);
      p = coord.invertPoint(p);
      expect(p.dx, 1);
      expect(p.dy, 0);

      p = Offset(120, 120);
      p = coord.invertPoint(p);
      expect(p.dx, 0.3);
      expect(p.dy, 0.7);
    });
  });

  group('transposed', () {
    final plot = Rect.fromLTRB(0, 0, 400, 400);
    final coord = CartesianCoordComponent(
      CartesianCoord(transposed: true)
    )..setRegion(plot);

    test('convert point', () {
      Offset p = Offset(0, 0);
      p = coord.convertPoint(p);
      expect(p.dx, 0);
      expect(p.dy, 400);

      p = Offset(1, 0.5);
      p = coord.convertPoint(p);
      expect(p.dx, 200);
      expect(p.dy, 0);

      p = Offset(0.5, 1);
      p = coord.convertPoint(p);
      expect(p.dx, 400);
      expect(p.dy, 200);

      p = Offset(0.3, 0.7);
      p = coord.convertPoint(p);
      expect(p.dx, 280);
      expect(p.dy, 280);
    });

    test('invert point', () {
      Offset p = Offset(0, 400);
      p = coord.invertPoint(p);
      expect(p.dx, 0);
      expect(p.dy, 0);

      p = Offset(200, 0);
      p = coord.invertPoint(p);
      expect(p.dx, 1);
      expect(p.dy, 0.5);

      p = Offset(400, 200);
      p = coord.invertPoint(p);
      expect(p.dx, 0.5);
      expect(p.dy, 1);

      p = Offset(280, 280);
      p = coord.invertPoint(p);
      expect(p.dx, 0.3);
      expect(p.dy, 0.7);
    });
  });
}
