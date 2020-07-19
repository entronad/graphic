import 'package:flutter_test/flutter_test.dart';

import 'package:graphic/src/scale/auto_ticks/num.dart';

main() {
  group('test number auto', () {
    test('no interval', () {
      final rst = numAutoTicks(
        minValue: 0,
        maxValue: 10,
      );
      expect(rst, [ 0, 2, 4, 6, 8, 10 ]);
    });

    test('no interval no nice', () {
      final rst = numAutoTicks(
        minValue: 1,
        maxValue: 9.5,
      );
      expect(rst, [ 0, 2, 4, 6, 8, 10 ]);
    });

    test('no interval, max : 11', () {
      final rst = numAutoTicks(
        minValue: 1,
        maxValue: 11,
      );
      expect(rst, [ 0, 2, 4, 6, 8, 10, 12 ]);
    });

    test('with interval', () {
      final rst = numAutoTicks(
        minValue: 0,
        interval: 5,
        maxValue: 10,
      );
      expect(rst, [ 0, 5, 10 ]);
    });

    test('with interval not nice, larger', () {
      final rst = numAutoTicks(
        minValue: 1.2,
        interval: 5,
        maxValue: 11.5,
      );
      expect(rst, [ 0, 5, 10, 15 ]);
    });

    test('with interval, not the multiple of interval', () {
      var rst = numAutoTicks(
        minValue: 0,
        interval: 6,
        maxValue: 10,
      );
      expect(rst, [ 0, 6, 12 ]);

      rst = numAutoTicks(
        minValue: 3,
        interval: 6,
        maxValue: 11,
      );
      expect(rst, [ 0, 6, 12 ]);
    });

    test('max < 0, min < 0', () {
      final rst = numAutoTicks(
        minValue: -100,
        interval: 20,
        maxValue: -10,
      );
      expect(rst, [ -100, -80, -60, -40, -20, -0 ]);
    });

    test('with count', () {
      final rst = numAutoTicks(
        minValue: 0,
        minCount: 3,
        maxCount: 4,
        maxValue: 10,
      );
      expect(rst, [ 0, 5, 10 ]);
    });

    test('with count', () {
      final rst = numAutoTicks(
        minValue: 0,
        minCount: 5,
        maxCount: 5,
        maxValue: 4200,
      );
      expect(rst, [ 0, 1200, 2400, 3600, 4800 ]);
    });

    test('max equals min', () {
      var rst = numAutoTicks(
        minValue: 100,
        maxValue: 100,
      );
      expect(rst, [ 0, 20, 40, 60, 80, 100 ]);

      rst = numAutoTicks(
        minValue: 0,
        maxValue: 0,
      );
      expect(rst, [ 0, 1 ]);
    });

    test('very little', () {
      final rst = numAutoTicks(
        minValue: 0.0002,
        minCount: 3,
        maxCount: 4,
        maxValue: 0.0010,
      );
      expect(rst, [ 0, 0.0004, 0.0008, 0.0012 ]);
    });

    test('very little minus', () {
      final rst = numAutoTicks(
        minValue: -0.0010,
        minCount: 3,
        maxCount: 4,
        maxValue: -0.0002,
      );
      expect(rst, [ -0.0012, -0.0008, -0.0004, 0 ]);
    });

    test('tick count 5', () {
      final rst = numAutoTicks(
        minValue: -5,
        minCount: 5,
        maxCount: 5,
        maxValue: 605,
      );
      expect(rst, [ -160, 0, 160, 320, 480, 640 ]);
    });

    test('tick count 6', () {
      final rst = numAutoTicks(
        minValue: 0,
        minCount: 6,
        maxCount: 6,
        maxValue: 100,
      );
      expect(rst, [ 0, 20, 40, 60, 80, 100 ]);
    });

    test('tick count 10', () {
      final rst = numAutoTicks(
        minValue: 0,
        minCount: 10,
        maxCount: 10,
        maxValue: 5,
      );
      expect(rst, [ 0, 0.6, 1.2, 1.8, 2.4, 3.0, 3.6, 4.2, 4.8, 5.4 ]);
    });

    test('snapList', () {
      final rst = numAutoTicks(
        minValue: 0,
        minCount: 6,
        maxCount: 6,
        snapList: [ 0.3, 3, 6, 30 ],
        maxValue: 1000,
      );
      expect(rst, [ 0, 300, 600, 900, 1200 ]);
    });

    test('with count 5', () {
      final rst = numAutoTicks(
        minValue: 0,
        minCount: 5,
        maxCount: 5,
        maxValue: 10,
      );
      expect(rst, [ 0, 2.5, 5, 7.5, 10 ]);
    });

    test('very small and float', () {
      var rst = numAutoTicks(
        minValue: 0,
        maxValue: 0.0000267519,
      );
      expect(rst, [
        0,
        0.000005,
        0.00001,
        0.000015,
        0.00002,
        0.000025,
        0.00003,
      ]);

      rst = numAutoTicks(
        minValue: 0.0000237464,
        maxValue: 0.0000586372
      );
      expect(rst, [
        0.00002,
        0.00003,
        0.00004,
        0.00005,
        0.00006,
      ]);
    });

    test('minTickInterval', () {
      final rst = numAutoTicks(
        minValue: 140,
        minTickInterval: 1,
        maxValue: 141,
      );
      expect(rst, [ 140, 141 ]);
    });
  });
}