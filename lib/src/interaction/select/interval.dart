import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/interaction/gesture/arena.dart';
import 'package:graphic/src/util/math.dart';

import 'select.dart';

class IntervalSelect extends Select {
  IntervalSelect({
    this.color,
    this.zIndex,

    int? dim,
    String? variable,
    Set<GestureType>? clear,
  }) : super(
    dim: dim,
    variable: variable,
    clear: clear,
  );

  final Color? color;

  final int? zIndex;

  @override
  bool operator ==(Object other) =>
    other is IntervalSelect &&
    super == other &&
    color == other.color &&
    zIndex == other.zIndex;
}

class IntervalSelector extends Selector {
  IntervalSelector(
    this.color,
    this.zIndex,

    String name,
    int? dim,
    String? variable,
    List<Offset> eventPoints,  // [start, end]
  ) : super(
    name,
    dim,
    variable,
    eventPoints,
  );

  final Color color;

  final int zIndex;

  @override
  Set<int>? select(
    AesGroups groups,
    List<Original> originals,
    Set<int>? preSelects,
    CoordConv coord,
  ) {
    final start = coord.invert(eventPoints.first);
    final end = coord.invert(eventPoints.last);

    bool Function(Aes) test;
    if (dim == null) {
      final testRegion = Rect.fromPoints(start, end);
      test = (aes) {
        final p = aes.representPoint;
        return testRegion.contains(p);
      };
    } else {
      if (dim == 1) {
        test = (aes) {
          final p = aes.representPoint;
          return p.dx.between(start.dx, end.dx);
        };
      } else {
        test = (aes) {
          final p = aes.representPoint;
          return p.dx.between(start.dy, end.dy);
        };
      }
    }

    final rst = <int>{};
    for (var group in groups) {
      for (var aes in group) {
        if (test(aes)) {
          rst.add(aes.index);
        }
      }
    }

    if (rst.isEmpty) {
      return null;
    }

    if (variable != null) {
      final values = Set();
      for (var index in rst) {
        values.add(originals[index][variable]);
      }
      for (var i = 0; i < originals.length; i++) {
        if (values.contains(originals[i][variable])) {
          rst.add(i);
        }
      }
    }

    return rst;
  }
}

class IntervalSelectorPainter extends SelectorPainter {
  IntervalSelectorPainter(
    this.start,
    this.end,
    this.color,
  );

  final Offset start;

  final Offset end;

  final Color color;

  @override
  void paint(Canvas canvas) {
    canvas.drawRect(
      Rect.fromPoints(start, end),
      Paint()..color = color,
    );
  }
}
