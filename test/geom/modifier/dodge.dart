import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart';

final _color = Color(0x00000000);
final _shape = RectShape();

Aes _createAes({required int index, required List<Offset> position}) {
  return Aes(index: index, position: position, shape: _shape, color: _color);
}

final epsilon = 0.0001;

Matcher _matchesOffsets(List<List<List<Offset>>> expectedOffsets) {
  return predicate<AesGroups>((groups) {
    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) {
      final groupLength = groups[groupIndex].length;
      for (var valueIndex = 0; valueIndex < groupLength; valueIndex++) {
        final position = groups[groupIndex][valueIndex].position;
        for (var positionIndex = 0;
            positionIndex < position.length;
            positionIndex++) {
          final actual = position[positionIndex];
          final expected =
              expectedOffsets[groupIndex][valueIndex][positionIndex];

          expect(actual.dx, closeTo(expected.dx, epsilon));
          expect(actual.dy, closeTo(expected.dy, epsilon));
        }
      }
    }

    return true;
  });
}

void main() {
  group('equalTo', () {
    test('returns true when type is `DodgeModifier` and properties are equal',
        () {
      expect(DodgeModifier() == DodgeModifier(), true);
      expect(
          DodgeModifier(ratio: 0.5, symmetric: false) ==
              DodgeModifier(ratio: 0.5, symmetric: false),
          true);
    });

    test('returns false when type is not `DodgeModifier`', () {
      expect(DodgeModifier() == SymmetricModifier(), false);
    });

    test('returns false when some property differs', () {
      expect(DodgeModifier(ratio: 0.1) == DodgeModifier(ratio: 0.2), false);
      expect(DodgeModifier(symmetric: true) == DodgeModifier(symmetric: false),
          false);
    });
  });

  group('non-symmetric', () {
    test('shifts every X position by ratio*band', () {
      final AesGroups groups = [
        [
          _createAes(index: 0, position: [Offset(0.1, 0.1)]),
          _createAes(index: 1, position: [Offset(0.3, 0.1)]),
          _createAes(index: 2, position: [Offset(0.5, 0.1)]),
          _createAes(index: 3, position: [Offset(0.7, 0.1)]),
          _createAes(index: 4, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 5, position: [Offset(0.1, 0.1)]),
          _createAes(index: 6, position: [Offset(0.3, 0.1)]),
          _createAes(index: 7, position: [Offset(0.5, 0.1)]),
          _createAes(index: 8, position: [Offset(0.7, 0.1)]),
          _createAes(index: 9, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 10, position: [Offset(0.1, 0.1)]),
          _createAes(index: 11, position: [Offset(0.3, 0.1)]),
          _createAes(index: 12, position: [Offset(0.5, 0.1)]),
          _createAes(index: 13, position: [Offset(0.7, 0.1)]),
          _createAes(index: 14, position: [Offset(0.9, 0.1)]),
        ],
      ];

      final ratio = 1.0 / groups.length;
      final symmetric = false;
      final band = 1.0 / groups.first.length;
      final modifier = DodgeModifier(ratio: ratio, symmetric: symmetric);
      final bias = ratio * band;

      modifier.performModification(groups: groups, band: band);

      final expectedOffsets = [
        [
          [Offset(.1, .1)],
          [Offset(.3, .1)],
          [Offset(.5, .1)],
          [Offset(.7, .1)],
          [Offset(.9, .1)],
        ],
        [
          [Offset(.1 + bias, .1)],
          [Offset(.3 + bias, .1)],
          [Offset(.5 + bias, .1)],
          [Offset(.7 + bias, .1)],
          [Offset(.9 + bias, .1)],
        ],
        [
          [Offset(.1 + 2 * bias, .1)],
          [Offset(.3 + 2 * bias, .1)],
          [Offset(.5 + 2 * bias, .1)],
          [Offset(.7 + 2 * bias, .1)],
          [Offset(.9 + 2 * bias, .1)],
        ],
      ];

      expect(groups, _matchesOffsets(expectedOffsets));
    });
  });
  group('symmetric', () {
    test('centers the middle Aes when there is an odd numbers of groups', () {
      final AesGroups groups = [
        [
          _createAes(index: 0, position: [Offset(0.1, 0.1)]),
          _createAes(index: 1, position: [Offset(0.3, 0.1)]),
          _createAes(index: 2, position: [Offset(0.5, 0.1)]),
          _createAes(index: 3, position: [Offset(0.7, 0.1)]),
          _createAes(index: 4, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 5, position: [Offset(0.1, 0.1)]),
          _createAes(index: 6, position: [Offset(0.3, 0.1)]),
          _createAes(index: 7, position: [Offset(0.5, 0.1)]),
          _createAes(index: 8, position: [Offset(0.7, 0.1)]),
          _createAes(index: 9, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 10, position: [Offset(0.1, 0.1)]),
          _createAes(index: 11, position: [Offset(0.3, 0.1)]),
          _createAes(index: 12, position: [Offset(0.5, 0.1)]),
          _createAes(index: 13, position: [Offset(0.7, 0.1)]),
          _createAes(index: 14, position: [Offset(0.9, 0.1)]),
        ],
      ];

      final ratio = 1.0 / groups.length;
      final symmetric = true;
      final band = 1.0 / groups.first.length;
      final modifier = DodgeModifier(ratio: ratio, symmetric: symmetric);

      modifier.performModification(groups: groups, band: band);

      final expectedOffsets = [
        [
          [Offset(.1 - .2 / 3, .1)],
          [Offset(.3 - .2 / 3, .1)],
          [Offset(.5 - .2 / 3, .1)],
          [Offset(.7 - .2 / 3, .1)],
          [Offset(.9 - .2 / 3, .1)],
        ],
        [
          [Offset(.1, .1)],
          [Offset(.3, .1)],
          [Offset(.5, .1)],
          [Offset(.7, .1)],
          [Offset(.9, .1)],
        ],
        [
          [Offset(.1 + .2 / 3, .1)],
          [Offset(.3 + .2 / 3, .1)],
          [Offset(.5 + .2 / 3, .1)],
          [Offset(.7 + .2 / 3, .1)],
          [Offset(.9 + .2 / 3, .1)],
        ],
      ];

      expect(groups, _matchesOffsets(expectedOffsets));
    });

    test(
        'centers the middle Aes when there is an odd numbers of groups and ratio is 0.1',
        () {
      final AesGroups groups = [
        [
          _createAes(index: 0, position: [Offset(0.1, 0.1)]),
          _createAes(index: 1, position: [Offset(0.3, 0.1)]),
          _createAes(index: 2, position: [Offset(0.5, 0.1)]),
          _createAes(index: 3, position: [Offset(0.7, 0.1)]),
          _createAes(index: 4, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 5, position: [Offset(0.1, 0.1)]),
          _createAes(index: 6, position: [Offset(0.3, 0.1)]),
          _createAes(index: 7, position: [Offset(0.5, 0.1)]),
          _createAes(index: 8, position: [Offset(0.7, 0.1)]),
          _createAes(index: 9, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 10, position: [Offset(0.1, 0.1)]),
          _createAes(index: 11, position: [Offset(0.3, 0.1)]),
          _createAes(index: 12, position: [Offset(0.5, 0.1)]),
          _createAes(index: 13, position: [Offset(0.7, 0.1)]),
          _createAes(index: 14, position: [Offset(0.9, 0.1)]),
        ],
      ];

      final ratio = 0.1;
      final symmetric = true;
      final band = 1.0 / groups.first.length;
      final modifier = DodgeModifier(ratio: ratio, symmetric: symmetric);

      modifier.performModification(groups: groups, band: band);

      final expectedOffsets = [
        [
          [Offset(.08, .1)],
          [Offset(.28, .1)],
          [Offset(.48, .1)],
          [Offset(.68, .1)],
          [Offset(.88, .1)],
        ],
        [
          [Offset(.1, .1)],
          [Offset(.3, .1)],
          [Offset(.5, .1)],
          [Offset(.7, .1)],
          [Offset(.9, .1)],
        ],
        [
          [Offset(.12, .1)],
          [Offset(.32, .1)],
          [Offset(.52, .1)],
          [Offset(.72, .1)],
          [Offset(.92, .1)],
        ],
      ];

      expect(groups, _matchesOffsets(expectedOffsets));
    });

    test(
        'positions the groups equidistant from the center point when there is an even numbers of groups',
        () {
      final AesGroups groups = [
        [
          _createAes(index: 0, position: [Offset(0.1, 0.1)]),
          _createAes(index: 1, position: [Offset(0.3, 0.1)]),
          _createAes(index: 2, position: [Offset(0.5, 0.1)]),
          _createAes(index: 3, position: [Offset(0.7, 0.1)]),
          _createAes(index: 4, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 5, position: [Offset(0.1, 0.1)]),
          _createAes(index: 6, position: [Offset(0.3, 0.1)]),
          _createAes(index: 7, position: [Offset(0.5, 0.1)]),
          _createAes(index: 8, position: [Offset(0.7, 0.1)]),
          _createAes(index: 9, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 10, position: [Offset(0.1, 0.1)]),
          _createAes(index: 11, position: [Offset(0.3, 0.1)]),
          _createAes(index: 12, position: [Offset(0.5, 0.1)]),
          _createAes(index: 13, position: [Offset(0.7, 0.1)]),
          _createAes(index: 14, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 15, position: [Offset(0.1, 0.1)]),
          _createAes(index: 16, position: [Offset(0.3, 0.1)]),
          _createAes(index: 17, position: [Offset(0.5, 0.1)]),
          _createAes(index: 18, position: [Offset(0.7, 0.1)]),
          _createAes(index: 19, position: [Offset(0.9, 0.1)]),
        ],
      ];

      final ratio = 1.0 / groups.length;
      final symmetric = true;
      final band = 1.0 / groups.first.length;
      final modifier = DodgeModifier(ratio: ratio, symmetric: symmetric);

      modifier.performModification(groups: groups, band: band);

      final expectedOffsets = [
        [
          [Offset(.1 - 0.075, .1)],
          [Offset(.3 - 0.075, .1)],
          [Offset(.5 - 0.075, .1)],
          [Offset(.7 - 0.075, .1)],
          [Offset(.9 - 0.075, .1)],
        ],
        [
          [Offset(.1 - 0.025, .1)],
          [Offset(.3 - 0.025, .1)],
          [Offset(.5 - 0.025, .1)],
          [Offset(.7 - 0.025, .1)],
          [Offset(.9 - 0.025, .1)],
        ],
        [
          [Offset(.1 + 0.025, .1)],
          [Offset(.3 + 0.025, .1)],
          [Offset(.5 + 0.025, .1)],
          [Offset(.7 + 0.025, .1)],
          [Offset(.9 + 0.025, .1)],
        ],
        [
          [Offset(.1 + 0.075, .1)],
          [Offset(.3 + 0.075, .1)],
          [Offset(.5 + 0.075, .1)],
          [Offset(.7 + 0.075, .1)],
          [Offset(.9 + 0.075, .1)],
        ],
      ];

      expect(groups, _matchesOffsets(expectedOffsets));
    });

    test(
        'positions the groups equidistant from the center point when there is an even numbers of groups and ratio is 0.1',
        () {
      final AesGroups groups = [
        [
          _createAes(index: 0, position: [Offset(0.1, 0.1)]),
          _createAes(index: 1, position: [Offset(0.3, 0.1)]),
          _createAes(index: 2, position: [Offset(0.5, 0.1)]),
          _createAes(index: 3, position: [Offset(0.7, 0.1)]),
          _createAes(index: 4, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 5, position: [Offset(0.1, 0.1)]),
          _createAes(index: 6, position: [Offset(0.3, 0.1)]),
          _createAes(index: 7, position: [Offset(0.5, 0.1)]),
          _createAes(index: 8, position: [Offset(0.7, 0.1)]),
          _createAes(index: 9, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 10, position: [Offset(0.1, 0.1)]),
          _createAes(index: 11, position: [Offset(0.3, 0.1)]),
          _createAes(index: 12, position: [Offset(0.5, 0.1)]),
          _createAes(index: 13, position: [Offset(0.7, 0.1)]),
          _createAes(index: 14, position: [Offset(0.9, 0.1)]),
        ],
        [
          _createAes(index: 15, position: [Offset(0.1, 0.1)]),
          _createAes(index: 16, position: [Offset(0.3, 0.1)]),
          _createAes(index: 17, position: [Offset(0.5, 0.1)]),
          _createAes(index: 18, position: [Offset(0.7, 0.1)]),
          _createAes(index: 19, position: [Offset(0.9, 0.1)]),
        ],
      ];

      final ratio = 0.1;
      final symmetric = true;
      final band = 1.0 / groups.first.length;
      final modifier = DodgeModifier(ratio: ratio, symmetric: symmetric);

      modifier.performModification(groups: groups, band: band);

      final expectedOffsets = [
        [
          [Offset(.07, .1)],
          [Offset(.27, .1)],
          [Offset(.47, .1)],
          [Offset(.67, .1)],
          [Offset(.87, .1)],
        ],
        [
          [Offset(.09, .1)],
          [Offset(.29, .1)],
          [Offset(.49, .1)],
          [Offset(.69, .1)],
          [Offset(.89, .1)],
        ],
        [
          [Offset(.11, .1)],
          [Offset(.31, .1)],
          [Offset(.51, .1)],
          [Offset(.71, .1)],
          [Offset(.91, .1)],
        ],
        [
          [Offset(.13, .1)],
          [Offset(.33, .1)],
          [Offset(.53, .1)],
          [Offset(.73, .1)],
          [Offset(.93, .1)],
        ],
      ];

      expect(groups, _matchesOffsets(expectedOffsets));
    });
  });
}
