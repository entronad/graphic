import 'package:flutter_test/flutter_test.dart';

import 'package:graphic/src/attr/single_linear/size.dart';

main() {
  test('two values', () {
    final attr = SizeSingleLinearAttrComponent(SizeAttr(
      values: [1, 10],
      field: 'a',
    ));
    expect(attr.map([0]), 1);
    expect(attr.map([1]), 10);
    expect(attr.map([0.5]), 5.5);
  });

  test('with stops', () {
    final attr = SizeSingleLinearAttrComponent(SizeAttr(
      values: [0, 5, 10],
      stops: [0, 0.6, 1],
      field: 'a',
    ));
    expect(attr.map([0.6]), 5);
    expect(attr.map([0.8]), 7.5);
  });

  test('single values', () {
    final attr = SizeSingleLinearAttrComponent(SizeAttr(
      values: [12],
      field: 'a',
    ));
    expect(attr.map([0]), 12);
    expect(attr.map([1]), 12);
    expect(attr.map([0.5]), 12);
  });

  test('without field', () {
    final attr = SizeSingleLinearAttrComponent(SizeAttr(
      values: [1, 10],
    ));
    expect(attr.map([0]), 1);
    expect(attr.map([1]), 1);
    expect(attr.map([0.5]), 1);
  });
}
