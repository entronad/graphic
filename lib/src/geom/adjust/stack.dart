import 'dart:ui';

import 'package:graphic/src/geom/base.dart';

import 'base.dart';

class StackAdjust extends Adjust {
  @override
  AdjustType get type => AdjustType.stack;
}

class StackAdjustState extends AdjustState {}

class StackAdjustComponent extends AdjustComponent<StackAdjustState> {
  StackAdjustComponent([StackAdjust props]) : super(props);

  @override
  StackAdjustState get originalState => StackAdjustState();

  @override
  void adjust(List<List<AttrValueRecord>> recordsGroup, Offset origin) {
    final originY = origin.dy;

    // To be meaningfull, y must be all positive or all negtive.
    for (var i = 1; i < recordsGroup.length; i++) {
      final records = recordsGroup[i];
      final preRecords = recordsGroup[i - 1];
      for (var j = 0; j < records.length; j++) {
        final position = records[j].position;
        final prePosition = preRecords[j].position;

        final preTop = prePosition.reduce(
          (a, b) => (a.dy - originY).abs() >= (b.dy - originY).abs() ? a : b
        );

        for (var k = 0; k < position.length; k++) {
          position[k] = Offset(
            position[k].dx,
            position[k].dy + (preTop.dy - originY),
          );
        }
      }
    }
  }
}
