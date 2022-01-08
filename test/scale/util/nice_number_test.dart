import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/util/nice_numbers.dart';

main() {
  group('Wilkinson extended test.', () {
    test('Double nice numbers.', () {
      expect(linearNiceNumbers(double.nan, double.nan, 5), []);

      expect(linearNiceNumbers(0, 1e-16, 5), [0]);
      expect(linearNiceNumbers(0, 100, 1), [0]);
      expect(linearNiceNumbers(0.5, 0.5000000000000001, 5), [0.5]);

      expect(linearNiceNumbers(0, 100, 10),
          [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]);

      expect(linearNiceNumbers(0, 10, 5), [0, 2.5, 5, 7.5, 10]);
      expect(linearNiceNumbers(1, 9.5, 5), [0, 2.5, 5, 7.5, 10]);
      expect(linearNiceNumbers(1, 11, 5), [0, 3, 6, 9, 12]);
      expect(linearNiceNumbers(3, 97, 5), [0, 25, 50, 75, 100]);
      expect(linearNiceNumbers(-100, -10, 5), [-100, -75, -50, -25, 0]);
      expect(linearNiceNumbers(0.0002, 0.001, 5),
          [0.0002, 0.0004, 0.0006, 0.0008, 0.001]);
      expect(linearNiceNumbers(0, 0.0000267519, 5),
          [0, 0.00001, 0.00002, 0.00003]);
      expect(linearNiceNumbers(0.0000237464, 0.0000586372, 5),
          [0.00002, 0.00003, 0.00004, 0.00005, 0.00006]);
      expect(linearNiceNumbers(0.153, 0.987, 5), [0, 0.25, 0.5, 0.75, 1]);
      expect(linearNiceNumbers(0.153, 0.987, 10),
          [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]);

      expect(linearNiceNumbers(0, 0.1, 5), [0, 0.025, 0.05, 0.075, 0.1]);
      expect(linearNiceNumbers(0, 0.01, 5), [0, 0.0025, 0.005, 0.0075, 0.01]);
      expect(
          linearNiceNumbers(0, 0.001, 5), [0, 0.00025, 0.0005, 0.00075, 0.001]);
      expect(linearNiceNumbers(0, 0.0001, 6),
          [0.0, 0.00002, 0.00004, 0.00006, 0.00008, 0.0001]);
      expect(linearNiceNumbers(0, 0.00001, 6),
          [0, 0.000002, 0.000004, 0.000006, 0.000008, 0.00001, 0.000012]);
      expect(linearNiceNumbers(0, 0.000001, 6),
          [0, 0.0000002, 0.0000004, 0.0000006, 0.0000008, 0.000001]);
      expect(linearNiceNumbers(0, 1e-15, 6),
          [0, 2e-16, 4e-16, 6e-16, 8e-16, 1e-15]);

      expect(linearNiceNumbers(0, 1.2, 5), [0, 0.3, 0.6, 0.9, 1.2]);

      expect(linearNiceNumbers(-0.4, 0, 5), [-0.4, -0.3, -0.2, -0.1, 0]);

      expect(linearNiceNumbers(0.94, 1, 5),
          [0.93, 0.94, 0.95, 0.96, 0.97, 0.98, 0.99, 1]);
      expect(linearNiceNumbers(-1.11660058, 3.16329506, 5),
          [-1.2, 0, 1.2, 2.4, 3.6]);
      expect(linearNiceNumbers(-3.01805882, 1.407252466, 5),
          [-3.2, -2.4, -1.6, -0.8, 0, 0.8, 1.6]);
      expect(linearNiceNumbers(-1.02835066, 3.25839303, 5),
          [-1.2, 0, 1.2, 2.4, 3.6]);
    });
  });
}
