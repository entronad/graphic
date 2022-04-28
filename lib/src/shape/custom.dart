import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'util/render_basic_item.dart';
import 'shape.dart';

/// A candle stick shape.
///
/// The points order of measure dimension is appointed as:
///
/// ```
/// [star, end, max, min]
/// ```
///
/// And the end point is regarded as represent point.
///
/// ** We insist that the price of a subject matter of investment is determined
/// by its intrinsic value. Too much attention to the short-term fluctuations in
/// prices is harmful. Thus a candlestick chart may misslead your investment decision.**
class CandlestickShape extends Shape {
  /// Creates a candle stick shape.
  CandlestickShape({
    this.hollow = true,
    this.strokeWidth = 1,
  });

  /// whether the sticks are hollow.
  final bool hollow;

  /// The stroke width of the stick.
  final double strokeWidth;

  @override
  bool equalTo(Object other) =>
      other is CandlestickShape &&
      hollow == other.hollow &&
      strokeWidth == other.strokeWidth;

  @override
  double get defaultSize => 10;

  @override
  List<Figure> renderGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    final rst = <Figure>[];
    for (var item in group) {
      rst.addAll(item.shape.renderItem(item, coord, origin));
    }
    return rst;
  }

  @override
  List<Figure> renderItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) {
    assert(item.shape is CandlestickShape);

    final path = Path();

    // Candle stick shape dosen't allow NaN value.
    final points = item.position.map((p) => coord.convert(p)).toList();
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
      // If the stoke style is fill, the lines created by Path.lineTo will not
      // be rendered.
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

    // Color variation should be controled by color attribute.
    return renderBasicItem(
      path,
      item,
      hollow,
      strokeWidth,
    );

    // No labels.
  }

  @override
  Offset representPoint(List<Offset> position) => position[1];
}
