import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/geom/base.dart';

import 'base.dart';

class SymmetricAdjust extends Adjust {
  @override
  AdjustType get type => AdjustType.stack;
}

class SymmetricAdjustState extends AdjustState {}

class SymmetricAdjustComponent extends AdjustComponent<SymmetricAdjustState> {
  SymmetricAdjustComponent([SymmetricAdjust props]) : super(props);

  @override
  SymmetricAdjustState get originalState => SymmetricAdjustState();

  @override
  void adjust(List<List<AttrValueRecord>> recordsGroup) {
    for (var records in recordsGroup) {
      for (var record in records) {
        var originalPosition = record.position;

        if (originalPosition.length == 1) {
          final singlePoint = originalPosition.first;
          originalPosition = [
            Offset(singlePoint.dx, 0),
            singlePoint,
          ];
        }

        var maxY = double.negativeInfinity;
        var minY = double.infinity;
        for (var point in originalPosition) {
          maxY = max(maxY, point.dy);
          minY = min(minY, point.dy);
        }

        final offsetY = -(minY + maxY) / 2;
        record.position = originalPosition.map(
          (point) => Offset(point.dx, point.dy + offsetY)
        ).toList();
      }
    }
  }
}
