import 'dart:ui';

import 'package:graphic/src/geom/base.dart';

import 'base.dart';

class DodgeAdjust extends Adjust {
  DodgeAdjust({
    double dodgeRatio,
  }) {
    this['dodgeRatio'] = dodgeRatio;
  }

  @override
  AdjustType get type => AdjustType.dodge;
}

class DodgeAdjustState extends AdjustState {
  double get dodgeRatio => this['dodgeRatio'] as double;
  set dodgeRatio(double value) => this['dodgeRatio'] = value;
}

class DodgeAdjustComponent extends AdjustComponent<DodgeAdjustState> {
  DodgeAdjustComponent([DodgeAdjust props]) : super(props);

  @override
  DodgeAdjustState get originalState => DodgeAdjustState();

  @override
  void adjust(List<List<AttrValueRecord>> recordsGroup) {
    final totalGroup = recordsGroup.length;
    final dodgeRatio = state.dodgeRatio ?? (1 / totalGroup);
    final step = 1 / (recordsGroup.first.length - 1);
    final groupWidth = (totalGroup - 1) * dodgeRatio * step;

    for (var i = 0; i < totalGroup; i++) {
      final records = recordsGroup[i];
      final dodgeWidth = i * dodgeRatio * step;
      for (var record in records) {
        final originalPosition = record.position;
        record.position = originalPosition.map(
          (point) => Offset(point.dx + dodgeWidth - groupWidth, point.dy)
        ).toList();
      }
    }
  }
}
