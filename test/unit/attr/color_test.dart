import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graphic/src/attr/single_linear/color.dart';

main() {
  test('gradient white black', () {
    final attr = ColorSingleLinearAttrComponent(ColorAttr(
      values: [
        Color(0xffffffff),
        Color(0xff000000),
      ],
    ));
    expect(attr.map([0]), Color(0xffffffff));
    expect(attr.map([1]), Color(0xff000000));
    expect(attr.map([0.5]), Color(0xff7f7f7f));
  });

  test('gradient red blue', () {
    final attr = ColorSingleLinearAttrComponent(ColorAttr(
      values: [
        Color(0xffff0000),
        Color(0xff0000ff),
      ],
    ));
    expect(attr.map([0]), Color(0xffff0000));
    expect(attr.map([-0.1]), Color(0xffff0000));
    expect(attr.map([1]), Color(0xff0000ff));
    expect(attr.map([1.2]), Color(0xff0000ff));
    expect(attr.map([0.5]), Color(0xff7f007f));
  });


  test('category', () {
    final attr = ColorSingleLinearAttrComponent(ColorAttr(
      values: [ Colors.amberAccent, Colors.blueAccent, Colors.cyanAccent ],
    ));
    expect(attr.map([0]), Colors.amberAccent);
    expect(attr.map([1]), Colors.cyanAccent);
    expect(attr.map([0.5]), Colors.blueAccent);
  });

  test('single color', () {
    final attr = ColorSingleLinearAttrComponent(ColorAttr(
      values: [ Color(0xffff0000) ],
    ));
    expect(attr.map([0]), Color(0xffff0000));
    expect(attr.map([1]), Color(0xffff0000));
    expect(attr.map([0.5]), Color(0xffff0000));
  });
}
