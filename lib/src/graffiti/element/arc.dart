import 'dart:ui';
import 'dart:math';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/arc.dart';

/// Gets the arc point by [angle] on an [oval].
///
/// The algrithom is from https://blog.csdn.net/chenlu5201314/article/details/99678398
Offset getArcPoint(Rect oval, double angle) {
  final a = oval.width / 2;
  final b = oval.height / 2;
  final yc = sin(angle);
  final xc = cos(angle);
  final radio = (a * b) / sqrt(pow(yc * a, 2) + pow(xc * b, 2));

  return oval.center.translate(radio * xc, radio * yc);
}

/// An arc element
class ArcElement extends PrimitiveElement {
  /// Creates an arc element.
  ArcElement({
    required this.oval,
    required this.startAngle,
    required this.endAngle,
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
    String? tag,
  }) : super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
          tag: tag,
        );

  /// The bounds of the oval this arc belongs to.
  final Rect oval;

  /// The start angle of this arc.
  final double startAngle;

  /// The end angle of this arc.
  final double endAngle;

  @override
  void drawPath(Path path) =>
      path.addArc(oval, startAngle, endAngle - startAngle);

  @override
  ArcElement lerpFrom(covariant ArcElement from, double t) => ArcElement(
        oval: Rect.lerp(from.oval, oval, t)!,
        startAngle: lerpDouble(from.startAngle, startAngle, t)!,
        endAngle: lerpDouble(from.endAngle, endAngle, t)!,
        style: style.lerpFrom(from.style, t),
        rotation: lerpDouble(from.rotation, rotation, t),
        rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
        tag: tag,
      );

  @override
  List<Segment> toSegments() => [
        MoveSegment(end: getArcPoint(oval, startAngle)),
        ArcSegment(
            oval: oval,
            startAngle: startAngle,
            endAngle: endAngle,
            tag: SegmentTags.top),
      ];

  @override
  bool operator ==(Object other) =>
      other is ArcElement &&
      super == other &&
      oval == other.oval &&
      startAngle == other.startAngle &&
      endAngle == other.endAngle;
}
