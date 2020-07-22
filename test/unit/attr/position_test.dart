import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/coord/cartesian.dart';

class MyCoord extends CartesianCoordComponent {
  @override
  Offset convertPoint(Offset abstractPoint) => Offset(
    abstractPoint.dx * 100,
    abstractPoint.dy * 200,
  );
}

main() {
  final coord = MyCoord();

  test('map', () {
    final attr = PositionAttrComponent(PositionAttr())
      ..state.coord = coord;
    
    expect(attr.map([0, 0]), Offset(0, 0));
    expect(attr.map([1, 1]), Offset(100, 200));
    expect(attr.map([0.5, 0.5]), Offset(50, 100));
  });
}
