import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:graphic/src/scale/time.dart';

main() {
  group('scale time cat', () {
    final mask = 'yyyy/MM/dd';
    final scale = TimeScaleComponent(TimeScale(
      min: DateTime.fromMillisecondsSinceEpoch(1441296000000),
      max: DateTime.fromMillisecondsSinceEpoch(1449849600000),
      mask: mask,
      tickCount: 3,
    ));

    test('scale', () {
      expect(scale.scale(DateTime.fromMillisecondsSinceEpoch(1441296000000)), 0);
      expect(scale.scale(DateTime.fromMillisecondsSinceEpoch(1445572800000)), 0.5);
    });

    test('invert', () {
      expect(scale.invert(0), DateTime.fromMillisecondsSinceEpoch(1441296000000));
      expect(scale.invert(0.5), DateTime.fromMillisecondsSinceEpoch(1445572800000));
      expect(scale.invert(1), DateTime.fromMillisecondsSinceEpoch(1449849600000));
    });

    test('get text', () {
      final text = scale.getText(DateTime.fromMillisecondsSinceEpoch(1441296000000));
      final date = DateTime.fromMillisecondsSinceEpoch(1441296000000);
      final dateFormat = DateFormat(mask);
      expect(text, dateFormat.format(date));
      expect(
        scale.getText(DateTime.fromMillisecondsSinceEpoch(1445572800000)),
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(1445572800000)),
      );
    });

    test('this.ticks', () {
      expect(scale.state.ticks.length, 3);
      expect(scale.state.ticks, [
        DateTime.fromMillisecondsSinceEpoch(1441296000000),
        DateTime.fromMillisecondsSinceEpoch(1445572800000),
        DateTime.fromMillisecondsSinceEpoch(1449849600000),
      ]);
    });

    test('getTicks', () {
      final ticks = scale.state.ticks;
      expect(scale.scale(ticks[1]), 0.5);
      final dateFormat = DateFormat(mask);
      expect(
        scale.getText(ticks[1]),
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(1445572800000)),
      );
    });

    test('set props', () {
      scale.setProps(TimeScale(
        range: [0.2, 0.8],
        min: DateTime.fromMillisecondsSinceEpoch(1445572800000),
        max: DateTime.fromMillisecondsSinceEpoch(1449849600000),
      ));
      expect(
        scale.invert(scale.scale(DateTime.fromMillisecondsSinceEpoch(1445572800000))),
        DateTime.fromMillisecondsSinceEpoch(1445572800000),
      );
    });

    test('set props with itcks', () {
      scale.setProps(TimeScale(
        range: [0.2, 0.8],
        min: DateTime.fromMillisecondsSinceEpoch(1442937600000),
        max: DateTime.fromMillisecondsSinceEpoch(1443024000000),
        ticks: [
          DateTime.fromMillisecondsSinceEpoch(1442937600000),
          DateTime.fromMillisecondsSinceEpoch(1443024000000),
        ],
      ));
      expect(scale.state.ticks.length, 2);
    });

    test('scale formatter', () {
      final scale = TimeScaleComponent(TimeScale(
        min: DateTime.fromMillisecondsSinceEpoch(1519084800000),
        max: DateTime.fromMillisecondsSinceEpoch(1519257600000),
        formatter: (val) => 'time is ' + val.millisecondsSinceEpoch.toString(),
      ));
      
      final text = scale.getText(DateTime.fromMillisecondsSinceEpoch(1519084800000));
      expect(text, 'time is 1519084800000');
    });
  });
}
