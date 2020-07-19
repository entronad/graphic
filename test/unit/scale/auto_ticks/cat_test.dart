import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/auto_ticks/cat.dart';

main() {
  group('Category test', () {
    test('no tick count, 1 items', () {
      final categories = [ '1' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 2 items', () {
      final categories = [ '1', '2' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 3 items', () {
      final categories = [ '1', '2', '3' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 4 items', () {
      final categories = [ '1', '2', '3', '4' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 5 items', () {
      final categories = [ '1', '2', '3', '4', '5' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 6 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 7 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, categories);
    });

    test('no tick count, 8 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8' ];
      final rst = catAutoTicks(
        categories: categories,
        maxCount: 7,
      );
      expect(rst, categories);
    });

    test('no tick count, 9 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9' ];
      final rst = catAutoTicks(
        categories: categories,
        isRounding: true,
      );
      expect(rst, [ '1', '3', '5', '7', '9' ]);
    });

    test('no tick count, 10 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0' ];
      final rst = catAutoTicks(
        categories: categories,
        isRounding: true,
      );
      expect(rst, [ '1', '4', '7', '1''0' ]);
    });

    test('no tick count, 14 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4' ];
      final rst = catAutoTicks(
        categories: categories,
        isRounding: true,
      );
      expect(rst, [ '1', '3', '5', '7', '9', '1''1', '1''4' ]);
    });

    test('no tick count, 15 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4', '1''5' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, [ '1', '3', '5', '7', '9', '1''1', '1''3', '1''5' ]);
    });

    test('no tick count, 18 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4', '1''5', '1''6', '1''7', '1''8' ];
      final rst = catAutoTicks(
        categories: categories,
        isRounding: true,
      );
      expect(rst, [ '1', '5', '9', '1''3', '1''8' ]);
    });

    test('no tick count, 20 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4', '1''5', '1''6', '1''7', '1''8', '1''9', '2''0' ];
      final rst = catAutoTicks(
        categories: categories,
        maxCount: 5,
        isRounding: true,
      );
      expect(rst, [ '1', '7', '1''3', '2''0' ]);
    });

    test('no tick count, 27 items', () {
      final categories = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4', '1''5', '1''6', '1''7', '1''8', '1''9', '2''0', '2''1', '2''2', '2''3', '2''4', '2''5', '2''6' ];
      final rst = catAutoTicks(
        categories: categories,
        maxCount: 12,
        isRounding: true,
      );
      expect(rst, [ '0', '3', '6', '9', '1''2', '1''5', '1''8', '2''1', '2''6' ]);
    });

    test('no tick count, 30 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4', '1''5', '1''6', '1''7', '1''8', '1''9', '2''0', '2''1', '2''2', '2''3', '2''4', '2''5', '2''6', '2''7', '2''8', '2''9', '3''0' ];
      final rst = catAutoTicks(
        categories: categories,
      );
      expect(rst, [ '1', '5', '9', '1''3', '1''7', '2''1', '2''5', '3''0' ]);
    });

    test('no tick count, 31 items', () {
      final categories = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', '1''0', '1''1', '1''2', '1''3', '1''4', '1''5', '1''6', '1''7', '1''8', '1''9', '2''0', '2''1', '2''2', '2''3', '2''4', '2''5', '2''6', '2''7', '2''8', '2''9', '3''0', '3''1' ];
      final rst = catAutoTicks(
        categories: categories,
        isRounding: true,
      );
      expect(rst, [ '1', '6', '1''1', '1''6', '2''1', '2''6', '3''1' ]);
    });

    test('tick count 25 items', () {
      final categories = [ '1', '2', '3', '4', '5' ];
      final rst = catAutoTicks(
        categories: categories,
        maxCount: 2,
      );
      expect(rst, [ '1', '5' ]);
    });

    test('tick count 35 items', () {
      final categories = [ '1', '2', '3', '4', '5' ];
      final rst = catAutoTicks(
        categories: categories,
        maxCount: 3,
      );
      expect(rst, [ '1', '3', '5' ]);
    });
  });
}
