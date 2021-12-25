import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/util/collection.dart';

main() {
  test('Deep collection equality.', () {
    expect(deepCollectionEquals(
      [[1, 2], [3, 4]],
      [[1, 2], [3, 4]],
    ), isTrue);

    expect(deepCollectionEquals(
      {{1, 2}, {3, 4}},
      {{1, 2}, {3, 4}},
    ), isTrue);

    expect(deepCollectionEquals(
      {{'1': 1, '2': 2}, {true: 3, false: 4}},
      {{'1': 1, '2': 2}, {true: 3, false: 4}},
    ), isTrue);

    expect(deepCollectionEquals(
      [[1, 2], [3, 4]],
      null,
    ), isFalse);

    expect(deepCollectionEquals(
      [[], []],
      [[], []],
    ), isTrue);

    expect(deepCollectionEquals(
      {{1, 2}, {3, 4}},
      {{1, 2}, {3, 5}},
    ), isFalse);

    expect(deepCollectionEquals(
      'aaa',
      'aaa',
    ), isTrue);
  });
}
