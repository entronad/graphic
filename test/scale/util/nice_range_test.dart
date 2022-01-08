import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/util/nice_range.dart';

main() {
  test('Linear Nice range.', () {
    expect(linearNiceRange(1.1, 10.9, 5), [0, 12]);
    expect(linearNiceRange(10.9, 1.1, 5), [12, 0]);
    expect(linearNiceRange(0.7, 11.001, 5), [0, 12]);
    expect(linearNiceRange(123.1, 6.7, 5), [140, 0]);
    expect(linearNiceRange(1.6, 10.4, 5), [0, 12]);

    expect(linearNiceRange(0, 15, 5), [0, 20]);
    expect(linearNiceRange(0, 14.1, 5), [0, 20]);
    expect(linearNiceRange(0.5, 0.5, 5), [0.5, 0.5]);

    expect(linearNiceRange(0.4, 0.6, 5), [0.4, 0.6]);
  });
}
