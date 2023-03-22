import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/group.dart';
import 'package:graphic/src/graffiti/element/path.dart';
import 'package:graphic/src/graffiti/element/segment/close.dart';
import 'package:graphic/src/graffiti/element/segment/line.dart';
import 'package:graphic/src/graffiti/element/segment/move.dart';

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
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(coord is RectCoordConv);
    assert(!coord.transposed);

    final primitives = <MarkElement>[];

    for (var item in group) {
      assert(item.shape is CandlestickShape);

      final style = getPaintStyle(item, hollow, strokeWidth);

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
        primitives.add(PathElement(segments: [
          MoveSegment(end: Offset(x, top)),
          LineSegment(end: Offset(x, topEdge)),
          MoveSegment(end: Offset(x - bias, topEdge)),
          LineSegment(end: Offset(x + bias, topEdge)),
          LineSegment(end: Offset(x + bias, bottomEdge)),
          LineSegment(end: Offset(x - bias, bottomEdge)),
          CloseSegment(),
          MoveSegment(end: Offset(x, bottomEdge)),
          LineSegment(end: Offset(x, bottom)),
        ], style: style));
      } else {
        // If the stoke style is fill, the lines created by Path.lineTo will not
        // be rendered.
        final strokeBias = strokeWidth / 2;
        primitives.add(PathElement(segments: [
          MoveSegment(end: Offset(x + strokeBias, top)),
          LineSegment(end: Offset(x + strokeBias, topEdge)),
          LineSegment(end: Offset(x + bias, topEdge)),
          LineSegment(end: Offset(x + bias, bottomEdge)),
          LineSegment(end: Offset(x + strokeBias, bottomEdge)),
          LineSegment(end: Offset(x + strokeBias, bottom)),
          LineSegment(end: Offset(x - strokeBias, bottom)),
          LineSegment(end: Offset(x - strokeBias, bottomEdge)),
          LineSegment(end: Offset(x - bias, bottomEdge)),
          LineSegment(end: Offset(x - bias, topEdge)),
          LineSegment(end: Offset(x - strokeBias, topEdge)),
          LineSegment(end: Offset(x - strokeBias, top)),
          CloseSegment(),
        ], style: style));
      }
      // No labels.
    }

    return primitives;
  }

  @override
  List<MarkElement> drawGroupLabels(List<Attributes> group, CoordConv coord, Offset origin) => [];

  @override
  Offset representPoint(List<Offset> position) => position[1];
}
