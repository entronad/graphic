import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/src/scale/identity/string.dart';

main() {
  group('scale', () {
    final scale = StringIdentityScaleComponent(IdentScale(
      value: 'const',
    ));

    test('scale', () {
      expect(scale.scale('Jan'), null);
      expect(scale.scale('const'), 0);
    });

    test('get text', () {
      expect(scale.getText('const'), 'const');
    });

    test('invert', () {
      expect(scale.invert(0), 'const');
      expect(scale.invert(0.5), 'const');
      expect(scale.invert(1), 'const');
      expect(scale.invert(-1), 'const');
      expect(scale.invert(2), 'const');
    });

    test('ticks', () {
      final ticks = scale.state.ticks;
      expect(ticks, ['const']);
      expect(scale.scale(ticks.first), 0);
      expect(scale.scale(ticks.last), 0);
    });

    test('set props', () {
      scale.setProps(IdentScale(
        value: 'var',
      ));
      expect(scale.scale('var'), 0);
      expect(scale.scale('const'), null);
      expect(scale.state.ticks, ['var']);
    });
  });
}
