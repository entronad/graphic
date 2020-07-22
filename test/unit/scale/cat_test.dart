import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/category/string.dart';

main() {
  group('scale', () {
    final scale = StringCategoryScaleComponent(CatScale(
      values: [ 'Jan', 'Feb', 'Mar', 'Apr', 'May' ],
    ));

    test('scale', () {
      expect(scale.scale('Jan'), 0);
      expect(scale.scale('Feb'), 0.25);
      expect(scale.scale('May'), 1);
    });

    test('get text', () {
      expect(scale.getText('Feb'), 'Feb');
    });

    test('invert', () {
      expect(scale.invert(0), 'Jan');
      expect(scale.invert(0.5), 'Mar');
      expect(scale.invert(1), 'May');
      expect(scale.invert(-1), 'Jan');
      expect(scale.invert(2), 'May');
    });

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(ticks.length, scale.state.values.length);
      expect(scale.scale(ticks.first), 0);
      expect(scale.scale(ticks.last), 1);
    });

    test('set props', () {
      scale.setProps(CatScale(
        values: [ '1', '2', '3', '4', '5', '6' ],
      ));
      expect(scale.invert(0), '1');
      expect(scale.invert(0.4), '3');
      expect(scale.invert(1), '6');

      expect(scale.state.ticks.length, 6);
    });
  });

  group('scale cat change range', () {
    final scale = StringCategoryScaleComponent(CatScale(
      values: [ 'Jan', 'Feb', 'Mar', 'Apr', 'May' ],
      scaledRange: [0.1, 0.9],
    ));

    test('scale', () {
      expect(scale.scale('Jan'), 0.1);
      expect(scale.scale('May'), 0.9);
      expect(scale.scale('Feb'), 0.30000000000000004);
    });

    test('invert', () {
      expect(scale.invert(0.1), 'Jan');
      expect(scale.invert(0.5), 'Mar');
      expect(scale.invert(0.9), 'May');
    });
  });

  group('scale cat with tick count', () {
    final values = <String>[];
    for (var i = 0; i < 100; i++) {
      values.add(i.toString());
    }
    final scale = StringCategoryScaleComponent(CatScale(
      values: values,
      tickCount: 10,
    ));

    test('state', () {
      expect(scale.state.values.length, 100);
      expect(scale.state.ticks.length, isNot(100));
    });

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(ticks.length, 10);
      expect(scale.scale(ticks.first), 0);
      expect(scale.scale(ticks.last), 1);
    });
  });
}
