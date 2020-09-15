import 'dart:ui';
import 'dart:math';

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
  void adjust(List<List<AttrValueRecord>> recordsGroup, Offset origin) {
    var minX = 1.0;
    var maxX = 0.0;
    final values = Set();
    for (var records in recordsGroup) {
      for (var record in records) {
        final x = record.position.first.dx;
        minX = min(x, minX);
        maxX = max(x, maxX);
        values.add(x);
      }
    }
    final range = maxX - minX;
    final step = range / (values.length - 1);

    final totalGroup = recordsGroup.length;
    final dodgeRatio = state.dodgeRatio ?? (1 / totalGroup);
    final bias = (totalGroup - 1) * dodgeRatio * step / 2;

    for (var i = 0; i < totalGroup; i++) {
      final records = recordsGroup[i];
      final dodgeWidth = i * dodgeRatio * step;
      for (var record in records) {
        final originalPosition = record.position;
        record.position = originalPosition.map(
          (point) => Offset(point.dx + dodgeWidth - bias, point.dy)
        ).toList();
      }
    }
  }
}
