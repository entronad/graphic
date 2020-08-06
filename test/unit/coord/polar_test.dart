import 'dart:ui';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/coord/polar.dart';

bool equal(num v1, num v2) =>
  (v1 - v2).abs() < 0.001;

main() {
  group('basic', () {
    final plot = Rect.fromLTRB(0, 0, 400, 400);
    final coord = PolarCoordComponent()..setRegion(plot);

    test('convert point', () {
      Offset p = Offset(0, 0);
        p = coord.convertPoint(p);
        expect(p.dx, 200);
        expect(p.dy, 200);

        p = Offset(0.5, 0);
        p = coord.convertPoint(p);
        expect(p.dx, 200);
        expect(p.dy, 200);

        p = Offset(0.5, 0.5);
        p = coord.convertPoint(p);
        expect(p.dx, 200);
        expect(p.dy, 300);
    });

    test('invert point', () {
      Offset p = Offset(200, 200);
        p = coord.invertPoint(p);
        expect(p.dx, 0);
        expect(p.dy, 0);

        p = Offset(200, 300);
        p = coord.invertPoint(p);
        expect(p.dx, 0.5);
        expect(p.dy, 0.5);
    });
  });

  group('props', () {
    final plot = Rect.fromLTRB(0, 0, 400, 400);
    final coord = PolarCoordComponent(
      PolarCoord(innerRadius: 0.5),
    )..setRegion(plot);

    test('convert point', () {
      Offset p = Offset(0, 0);
        p = coord.convertPoint(p);
        expect(p.dx, 200);
        expect(p.dy, 100);

        p = Offset(0, 1);
        p = coord.convertPoint(p);
        expect(p.dx, 200);
        expect(p.dy, 0);

        p = Offset(0.75, 0.5);
        p = coord.convertPoint(p);
        expect(equal(p.dx, 50), true);
        expect(equal(p.dy, 200), true);
    });

    test('invert point', () {
      Offset p = Offset(200, 100);
        p = coord.invertPoint(p);
        expect(p.dx, 0);
        expect(p.dy, 0);

        p = Offset(200, 0);
        p = coord.invertPoint(p);
        expect(p.dx, 0);
        expect(p.dy, 1);

        p = Offset(50, 200);
        p = coord.invertPoint(p);
        expect(equal(p.dx, 0.75), true);
        expect(equal(p.dy, 0.5), true);
    });
  });

  group('half', () {
    final plot = Rect.fromLTRB(0, 0, 400, 400);
    final coord = PolarCoordComponent(PolarCoord(
      startAngle: -pi,
      endAngle: 0,
    ))..setRegion(plot);

    test('convert point', () {
      final p = coord.convertPoint(Offset(0, 0));
      expect(p, Offset(200, 400));

      final p1 = coord.convertPoint(Offset(0, 1));
      expect(p1, Offset(0, 400));

      final p2 = coord.convertPoint(Offset(0.5, 1));
      expect(p2, Offset(200, 200));
    });

    test('invert point', () {
      expect(coord.invertPoint(Offset(200, 400)), Offset(0, 0));
      expect(coord.invertPoint(Offset(200, 200)), Offset(0.5, 1));
    });
  });

  group('set plot', () {
    test('', () {
      final plot1 = Rect.fromLTRB(0, 0, 200, 200);
      final coord = PolarCoordComponent()..setRegion(plot1);
      expect(coord.radiusLength, 100);

      final plot2 = Rect.fromLTRB(0, 0, 400, 500);
      coord.setRegion(plot2);
      expect(coord.radiusLength, 200);
    });
  });
}
