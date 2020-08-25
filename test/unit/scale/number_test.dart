import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/linear/num.dart';

main() {
  group('scale linear', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 0,
      max: 100,
      formatter: (val) => '${val}bit',
    ));

    test('scale', () {
      expect(scale.scale(0), 0);
      expect(scale.scale(50), 0.5);
      expect(scale.scale(100), 1);
    });

    test('invert', () {
      expect(scale.invert(0), 0);
      expect(scale.invert(0.5), 50);
      expect(scale.invert(1), 100);
    });

    test('formatter', () {
      expect(scale.getText(5), '5bit');
    });

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(scale.scale(ticks.first), 0);
      expect(scale.scale(ticks.last), 1);
    });

    test('scale null', () {
      expect(scale.scale(null), null);
    });

    test('set props', () {
      scale.setProps(NumberScale(
        min: 10,
        max: 110,
      ));
      expect(scale.scale(60), 0.5);
    });
  });

  group('scale linear change range', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 0,
      max: 100,
      scaledRange: [0, 1000],
    ));

    test('scale', () {
      expect(scale.scale(0), 0);
      expect(scale.scale(50), 500);
      expect(scale.scale(100), 1000);
    });

    test('invert', () {
      expect(scale.invert(0), 0);
      expect(scale.invert(500), 50);
      expect(scale.invert(1000), 100);
    });
  });

  group('scale not nice', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 3,
      max: 97,
    ));

    test('scale', () {
      final val = scale.scale(50);
      expect(val, (50 - 3) / (97 - 3));
    });

    test('invert', () {
      expect(scale.invert(0), 3);
      expect(scale.invert(1), 97);
    });

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(ticks.first > 3, true);
      expect(ticks.last< 97, true);
    });
  });

  group('scale nice', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 3,
      max: 97,
      nice: true,
    ));

    test('state', () {
      expect(scale.state.min, isNot(3));
      expect(scale.state.max, isNot(97));
    });

    test('scale', () {
      final val = scale.scale(50);
      expect(val, 0.5);
    });

    test('invert', () {
      expect(scale.invert(0), 0);
      expect(scale.invert(1), 100);
    });

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(ticks.first < 3, true);
      expect(ticks.last > 97, true);
    });
  });

  group('scale ticks', () {
    final scale = NumLinearScaleComponent(NumberScale(
      ticks: [ 1, 2, 3, 4, 5 ],
    ));

    test('min, max', () {
      expect(scale.state.min, 1);
      expect(scale.state.max, 5);
    });
  });

  group('scale linear: min is equal to max', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 0,
      max: 0,
    ));

    test('scale', () {
      final val = scale.scale(0);
      expect(val, 0);
    });

    test('invert', () {
      expect(scale.invert(1), 0);
      expect(scale.invert(0), 0);
    });
  });

  group('scale linear: min is equal to max, nice true', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 0,
      max: 0,
      nice: true,
    ));

    test('scale', () {
      final val = scale.scale(0);
      expect(val, 0);
    });

    test('invert', () {
      expect(scale.invert(1), 1);
      expect(scale.invert(0), 0);
    });
  });

  group('scale linear: declare tickInterval.', () {
    final scale = NumLinearScaleComponent(NumberScale(
      min: 20,
      max: 85,
      tickInterval: 15,
      nice: true,
    ));

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(ticks.length, 6);
      expect(ticks, [ 15, 30, 45, 60, 75, 90 ]);
    });
  });
}
