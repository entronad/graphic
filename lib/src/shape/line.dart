import 'package:graphic/graphic.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/util/path.dart';

/// The shape for the line mark.
///
/// See also:
///
/// - [LineMark], which this shape is for.
abstract class LineShape extends FunctionShape {
  @override
  double get defaultSize => 2;
}

/// A basic line shape.
class BasicLineShape extends LineShape {
  /// Creates a basic line shape.
  BasicLineShape({
    this.smooth = false,
    this.loop = false,
    this.dash,
  });

  /// Whether this line is smooth.
  final bool smooth;

  /// Whether to connect the last point to the first point.
  ///
  /// It is usefull in the polar coordinate.
  final bool loop;

  /// The circular array of dash offsets and lengths.
  ///
  /// For example, the array `[5, 10]` would result in dashes 5 pixels long
  /// followed by blank spaces 10 pixels long.  The array `[5, 10, 5]` would
  /// result in a 5 pixel dash, a 10 pixel gap, a 5 pixel dash, a 5 pixel gap,
  /// a 10 pixel dash, etc.
  final List<double>? dash;

  @override
  bool equalTo(Object other) =>
      other is BasicLineShape &&
      smooth == other.smooth &&
      loop == other.loop &&
      deepCollectionEquals(dash, other.dash);

  @override
  List<MarkElement> renderGroup(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    assert(!(coord is PolarCoordConv && coord.transposed));

    final contours = <List<Offset>>[];
    final labels = <Attributes, Offset>{};

    var currentContour = <Offset>[];
    for (var item in group) {
      assert(item.shape is BasicLineShape);

      if (item.position.last.dy.isFinite) {
        final point = coord.convert(item.position.last);
        currentContour.add(point);
        labels[item] = point;
      } else if (currentContour.isNotEmpty) {
        contours.add(currentContour);
        currentContour = [];
      }
    }
    if (currentContour.isNotEmpty) {
      contours.add(currentContour);
    }

    if (loop &&
        group.first.position.last.dy.isFinite &&
        group.last.position.last.dy.isFinite) {
      // Because lines may be broken by NaN, don't loop by Path.close.
      contours.last.add(contours.first.first);
    }

    final basicElements = <MarkElement>[];
    final labelElements = <MarkElement>[];

    final represent = group.first;
    final style = getPaintStyle(represent, true, represent.size ?? defaultSize, coord.region);

    for (var contour in contours) {
      if (smooth) {
        basicElements.add(SplineElement(start: contour.first, cubics: getCubicControls(contour, false, true), style: style));
      } else {
        basicElements.add(PolylineElement(points: contour, style: style));
      }
    }

    for (var item in labels.keys) {
      if (item.label != null && item.label!.haveText) {
        labelElements.add(LabelElement(text: item.label!.text!, anchor: labels[item]!, defaultAlign: coord.transposed ? Alignment.centerRight : Alignment.topCenter, style: item.label!.style));
      }
    }
    
    return [GroupElement(elements: basicElements), GroupElement(elements: labelElements)];
  }
}
