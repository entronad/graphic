import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:graphic/src/attr/position.dart';

main() {
  test('map', () {
    final attr = PositionAttrComponent(PositionAttr(
      field: 'x*y',
      mapper: (values) => [Offset(values[0], values[1])],
    ));
    
    expect(attr.map([0, 0]), [Offset(0, 0)]);
    expect(attr.map([1, 1]), [Offset(1, 1)]);
    expect(attr.map([0.5, 0.5]), [Offset(0.5, 0.5)]);
  });
}
