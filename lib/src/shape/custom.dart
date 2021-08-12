import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/shape/util/aes_basic_item.dart';

import 'shape.dart';

abstract class CustomShape extends Shape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Designate default size in your own custom shape');
}

/// position: [star, end, max, min]
class CandlestickShape extends CustomShape {
  CandlestickShape({
    this.hollow = true,
    this.strokeWidth = 2,
  });

  final bool hollow;

  final double strokeWidth;

  @override
  bool equalTo(Object other) =>
    other is CandlestickShape &&
    hollow == other.hollow &&
    strokeWidth == other.strokeWidth;
  
  @override
  double get defaultSize => 10;

  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Canvas canvas,
  ) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    for (var item in group) {
      item.shape.paintItem(item, coord, canvas);
    }
  }

  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  ) {
    // candle stick shape dosen't allow NaN measure value.

    final path = Path();
    
    // [star, end, max, min]
    final points = item.position.map(
      (p) => coord.convert(p)
    ).toList();
    final x = points.first.dx;
    final ys = points.map((p) => p.dy).toList()..sort();
    final bias = (item.size ?? defaultSize) / 2;
    final top = ys[0];
    final topEdge = ys[1];
    final bottomEdge = ys[2];
    final bottom = ys[3];
    
    path.moveTo(x, top);
    path.lineTo(x, topEdge);
    path.moveTo(x, bottomEdge);
    path.lineTo(x, bottom);

    path.addRect(Rect.fromPoints(
      Offset(x - bias, topEdge),
      Offset(x + bias, bottomEdge),
    ));

    // Color should be set by color attr encode.
    aesBasicItem(
      path,
      item,
      hollow,
      strokeWidth,
      canvas,
    );

    // No label.
  }
}
