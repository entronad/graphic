import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'util/draw_basic_item.dart';
import 'shape.dart';

abstract class CustomShape extends Shape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Designate default size in your own custom shape');
}

/// The order of position points dosen't affect the shape.
class CandlestickShape extends CustomShape {
  CandlestickShape({
    this.hollow = true,
    this.strokeWidth = 1,
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
  List<Figure> drawGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    final rst = <Figure>[];
    for (var item in group) {
      rst.addAll(item.shape.drawItem(item, coord, origin));
    }
    return rst;
  }

  @override
  List<Figure> drawItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) {
    assert(item.shape is CandlestickShape);
    // candle stick shape dosen't allow NaN measure value.

    final path = Path();
    
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

    if (hollow) {
      path.moveTo(x, top);
      path.lineTo(x, topEdge);
      path.moveTo(x, bottomEdge);
      path.lineTo(x, bottom);
    } else {
      // Fill will not draw path.lineTo.
      final strokeBias = strokeWidth / 2;
      path.addRect(Rect.fromPoints(
        Offset(x - strokeBias, top),
        Offset(x + strokeBias, topEdge),
      ));
      path.addRect(Rect.fromPoints(
        Offset(x - strokeBias, bottomEdge),
        Offset(x + strokeBias, bottom),
      ));
    }

    path.addRect(Rect.fromPoints(
      Offset(x - bias, topEdge),
      Offset(x + bias, bottomEdge),
    ));

    // Color should be set by color attr encode.
    return drawBasicItem(
      path,
      item,
      hollow,
      strokeWidth,
    );

    // No label.
  }

  @override
  Offset representPoint(List<Offset> position) =>
    position[1];  // end
}
