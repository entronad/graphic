import 'dart:ui';

import 'base.dart';
import '../base.dart';

class StackAdjust extends Adjust {
  @override
  AdjustType get type => AdjustType.stack;
}

class StackAdjustState extends AdjustState {}

class StackAdjustComponent extends AdjustComponent<StackAdjustState> {
  StackAdjustComponent([StackAdjust props]) : super(props);

  @override
  StackAdjustState createState() => StackAdjustState();

  @override
  void adjust(List<List<ElementRecord>> recordsGroup, Offset origin) {
    final originY = origin.dy;

    // Stack means every points in a record position add the top
    // point y of prior record position points.
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
