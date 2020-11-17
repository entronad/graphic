import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/util/math.dart';

import 'base.dart';
import '../base.dart';

class SymmetricAdjust extends Adjust {
  @override
  AdjustType get type => AdjustType.symmetric;
}

class SymmetricAdjustState extends AdjustState {}

class SymmetricAdjustComponent extends AdjustComponent<SymmetricAdjustState> {
  SymmetricAdjustComponent([SymmetricAdjust props]) : super(props);

  @override
  SymmetricAdjustState createState() => SymmetricAdjustState();

  @override
  void adjust(List<List<ElementRecord>> recordsGroup, Offset origin) {
    final originY = origin.dy;
    
    for (var records in recordsGroup) {
      // Symmetric means to redistribute position points of
      // a sigle record around originY, keeping the relative distance.
      // Single postion point will fall to the origin y.
      for (var record in records) {
        var originalPosition = record.position;

        var maxY = double.negativeInfinity;
        var minY = double.infinity;
        for (var point in originalPosition) {
          final y = point.dy;
          if (isValid(y)) {
            maxY = max(maxY, y);
            minY = min(minY, y);
          }
        }

        final offsetY = originY - (minY + maxY) / 2;
        record.position = originalPosition.map(
          (point) => Offset(point.dx, point.dy + offsetY)
        ).toList();
      }
    }
  }
}
