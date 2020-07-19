import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/auto_ticks/util.dart';

void main() {
  group('test util', () {
    test('snap to', () {
      final data = [ 1, 10, 15, 20, 22 ];
      expect(snapTo(data, 2), 1);
      expect(snapTo(data, 0), 1);
      expect(snapTo(data, 23), 22);
      expect(snapTo(data, 17), 15);
      expect(snapTo(data, 12.5), 15);
    });

    test('snap floor', () {
      final data = [ 1, 10, 15, 20, 22 ];
      expect(snapFloor(data, 2), 1);
      expect(snapFloor(data, 0).isNaN, true);
      expect(snapFloor(data, 23), 22);
      expect(snapFloor(data, 19), 15);
    });

    test('snapFactorTo', () {
      final data = [ 0, 1, 2, 5, 10 ];
      expect(snapFactorTo(1.2, data), 1);
      expect(snapFactorTo(1.2, data, SnapType.ceil), 2);
      expect(snapFactorTo(23, data), 20);
      expect(snapFactorTo(0, data), 0);
    });

    test('snap ceiling', () {
      final data = [ 1, 10, 15, 20, 22 ];
      expect(snapCeiling(data, 2), 10);
      expect(snapCeiling(data, 0), 1);
      expect(snapCeiling(data, 19), 20);
      expect(snapCeiling(data, 23).isNaN, true);
    });

    test('snap empty', () {
      expect(snapTo([], 10).isNaN, true);
      expect(snapCeiling([], 10).isNaN, true);
      expect(snapFloor([], 10).isNaN, true);
    });

    test('snap with factor', () {
      final arr = [ 0, 1, 2, 5, 10 ];
      expect(snapFactorTo(0.7, arr), 0.5);
      expect(snapFactorTo(7, arr), 5);
      expect(snapFactorTo(7.8, arr), 10);
    });

    test('snap with factor floor', () {
      final arr = [ 0, 1, 2, 5, 10 ];
      expect(snapFactorTo(0.7, arr, SnapType.floor), 0.5);
      expect(snapFactorTo(7, arr, SnapType.floor), 5);
      expect(snapFactorTo(7.8, arr, SnapType.floor), 5);
    });

    test('snap with factor ceil', () {
      final arr = [ 0, 1, 2, 5, 10 ];
      expect(snapFactorTo(0.7, arr, SnapType.ceil), 1);
      expect(snapFactorTo(7, arr, SnapType.ceil), 10);
      expect(snapFactorTo(7.8, arr, SnapType.ceil), 10);
    });

    test('snap multiple', () {
      expect(snapMultiple(23, 5, SnapType.floor), 20);
      expect(snapMultiple(23, 5, SnapType.ceil), 25);
      expect(snapMultiple(22, 5), 20);
      expect(snapMultiple(23, 5), 25);
    });
  });
}
