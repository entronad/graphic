import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:graphic/src/scale/ordinal/date_time.dart';

main() {
  group('scale time cat', () {
    final mask = 'yyyy/MM/dd';
    final scale = DateTimeOrdinalScaleComponent(TimeScale(
      values: [
        DateTime.fromMillisecondsSinceEpoch(1442937600000),
        DateTime.fromMillisecondsSinceEpoch(1441296000000),
        DateTime.fromMillisecondsSinceEpoch(1449849600000),
      ],
      mask: mask,
    ));

    test('scale', () {
      expect(scale.scale(DateTime.fromMillisecondsSinceEpoch(1441296000000)), 0);
      expect(scale.scale(DateTime.fromMillisecondsSinceEpoch(1442937600000)), 0.5);
    });

    test('invert', () {
      expect(scale.invert(0), DateTime.fromMillisecondsSinceEpoch(1441296000000));
      expect(scale.invert(0.5), DateTime.fromMillisecondsSinceEpoch(1442937600000));
      expect(scale.invert(1), DateTime.fromMillisecondsSinceEpoch(1449849600000));
    });

    test('get text', () {
      final text = scale.getText(DateTime.fromMillisecondsSinceEpoch(1441296000000));
      final date = DateTime.fromMillisecondsSinceEpoch(1441296000000);
      final dateFormat = DateFormat(mask);
      expect(text, dateFormat.format(date));
      expect(
        scale.getText(DateTime.fromMillisecondsSinceEpoch(1442937600000)),
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(1442937600000)),
      );
    });

    test('this.ticks', () {
      expect(scale.state.ticks.length, 3);
      expect(scale.state.ticks, [
        DateTime.fromMillisecondsSinceEpoch(1441296000000),
        DateTime.fromMillisecondsSinceEpoch(1442937600000),
        DateTime.fromMillisecondsSinceEpoch(1449849600000),
      ]);
    });

    test('getTicks', () {
      final ticks = scale.state.ticks;
      expect(scale.scale(ticks[1]), 0.5);
      final dateFormat = DateFormat(mask);
      expect(
        scale.getText(ticks[1]),
        dateFormat.format(DateTime.fromMillisecondsSinceEpoch(1442937600000)),
      );
    });

    test('set props', () {
      scale.setProps(TimeScale(
        scaledRange: [0.2, 0.8],
        values: [
          DateTime.fromMillisecondsSinceEpoch(1442937600000),
          DateTime.fromMillisecondsSinceEpoch(1441296000000),
          DateTime.fromMillisecondsSinceEpoch(1449849600000),
          DateTime.fromMillisecondsSinceEpoch(1359648000000),
          DateTime.fromMillisecondsSinceEpoch(1362326400000),
          DateTime.fromMillisecondsSinceEpoch(1443024000000),
        ]
      ));
      expect(
        scale.invert(scale.scale(DateTime.fromMillisecondsSinceEpoch(1442937600000))),
        DateTime.fromMillisecondsSinceEpoch(1442937600000),
      );
    });

    test('set props with itcks', () {
      scale.setProps(TimeScale(
        scaledRange: [0.2, 0.8],
        values: [
          DateTime.fromMillisecondsSinceEpoch(1442937600000),
          DateTime.fromMillisecondsSinceEpoch(1441296000000),
          DateTime.fromMillisecondsSinceEpoch(1449849600000),
          DateTime.fromMillisecondsSinceEpoch(1359648000000),
          DateTime.fromMillisecondsSinceEpoch(1362326400000),
          DateTime.fromMillisecondsSinceEpoch(1443024000000),
        ],
        ticks: [
          DateTime.fromMillisecondsSinceEpoch(1442937600000),
          DateTime.fromMillisecondsSinceEpoch(1443024000000),
        ],
      ));
      expect(scale.state.ticks.length, 2);
    });

    test('scale formatter', () {
      final scale = DateTimeOrdinalScaleComponent(TimeScale(
      values: [
        DateTime.fromMillisecondsSinceEpoch(1519084800000),
        DateTime.fromMillisecondsSinceEpoch(1519171200000),
        DateTime.fromMillisecondsSinceEpoch(1519257600000),
      ],
      formatter: (val) => 'time is ' + val.millisecondsSinceEpoch.toString(),
      isSorted: true,
    ));
      
      final text = scale.getText(DateTime.fromMillisecondsSinceEpoch(1519084800000));
      expect(text, 'time is 1519084800000');
    });

    test('scale scale a value not in scale values', () {
      final scale = DateTimeOrdinalScaleComponent(TimeScale(
      values: [
        DateTime.fromMillisecondsSinceEpoch(1519084800000),
        DateTime.fromMillisecondsSinceEpoch(1519171200000),
        DateTime.fromMillisecondsSinceEpoch(1519257600000),
      ],
    ));
      final scaledValue = scale.scale(DateTime.fromMillisecondsSinceEpoch(1441296000000));
      expect(scaledValue, null);
    });
  });
}
