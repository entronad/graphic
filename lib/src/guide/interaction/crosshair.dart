import 'dart:ui';

import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/chart_view.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/arc.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/line.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/collection.dart';

/// The specification of a crosshair
///
/// A corsshair indicates the position of the pointer or the selected point. If
/// no point is selected, it will not occur.
class CrosshairGuide {
  /// Creates a crosshair.
  CrosshairGuide({
    this.selections,
    this.styles,
    this.followPointer,
    this.layer,
    this.mark,
  });

  /// The selections this crosshair reacts to.
  ///
  /// Make sure this selections will not occur simultaneously.
  ///
  /// If null, it will reacts to all selections.
  Set<String>? selections;

  /// The stroke styles of crosshair lines for each dimension.
  ///
  /// The dimension means which a crosshair line stands on.
  ///
  /// If null a default `[PaintStyle(strokeColor: Color(0xffbfbfbf)), PaintStyle(strokeColor: Color(0xffbfbfbf))]`
  /// is set.
  List<PaintStyle?>? styles;

  /// Whether the position for each dimension follows the pointer or stick to selected
  /// points.
  ///
  /// If null, a default `[false, false]` is set.
  List<bool>? followPointer;

  /// The layer of this crosshair.
  ///
  /// If null, a default 0 is set.
  int? layer;

  /// Which mark series this crosshair reacts to.
  ///
  /// This is an index in [Chart.marks].
  ///
  /// The crosshair can only reacts to one mark series.
  ///
  /// If null, the first mark series is set by default.
  int? mark;

  @override
  bool operator ==(Object other) =>
      other is CrosshairGuide &&
      deepCollectionEquals(selections, other.selections) &&
      deepCollectionEquals(styles, other.styles) &&
      deepCollectionEquals(followPointer, other.followPointer) &&
      layer == other.layer &&
      mark == other.mark;
}

/// The crosshair render operator.
class CrosshairRenderOp extends Render {
  CrosshairRenderOp(
    Map<String, dynamic> params,
    MarkScene scene,
    ChartView view,
  ) : super(params, scene, view);

  @override
  void render() {
    final selections = params['selections'] as Set<String>;
    final selectors = params['selectors'] as Map<String, Selector>?;
    final selected = params['selected'] as Selected?;
    final coord = params['coord'] as CoordConv;
    final groups = params['groups'] as AttributesGroups;
    final styles = params['styles'] as List<PaintStyle?>;
    final followPointer = params['followPointer'] as List<bool>;

    // The main indicator is selected, if no selector, takes selectedPoint for pointer.
    final name = singleIntersection(selected?.keys, selections);
    final selects = name == null ? null : selected?[name];

    if (selects == null || selects.isEmpty) {
      scene.set(null);
      return;
    }

    Offset selectedPoint = Offset.zero;
    int count = 0;
    findPoint(int index) {
      for (var group in groups) {
        for (var attributes in group) {
          if (attributes.index == index) {
            count += 1;
            return attributes.representPoint;
          }
        }
      }
      return Offset.zero;
    }

    for (var index in selects) {
      selectedPoint += findPoint(index);
    }
    selectedPoint = selectedPoint / count.toDouble();

    final selector = selectors?[name];
    final pointer =
        selector == null ? selectedPoint : coord.invert(selector.points.last);

    final cross = Offset(
      followPointer[0] ? pointer.dx : selectedPoint.dx,
      followPointer[1] ? pointer.dy : selectedPoint.dy,
    );

    final elements = <MarkElement>[];

    final region = coord.region;
    final canvasStyleX = coord.transposed ? styles[1] : styles[0];
    final canvasStyleY = coord.transposed ? styles[0] : styles[1];
    if (coord is RectCoordConv) {
      final canvasCross = coord.convert(cross);
      if (canvasStyleX != null) {
        elements.add(LineElement(
            start: Offset(canvasCross.dx, region.top),
            end: Offset(canvasCross.dx, region.bottom),
            style: canvasStyleX));
      }
      if (canvasStyleY != null) {
        elements.add(LineElement(
            start: Offset(region.left, canvasCross.dy),
            end: Offset(region.right, canvasCross.dy),
            style: canvasStyleY));
      }
    } else {
      final polarCoord = coord as PolarCoordConv;
      if (canvasStyleX != null) {
        final angle = polarCoord
            .convertAngle(polarCoord.transposed ? cross.dy : cross.dx);
        elements.add(LineElement(
            start: polarCoord.polarToOffset(angle, coord.startRadius),
            end: polarCoord.polarToOffset(angle, coord.endRadius),
            style: canvasStyleX));
      }
      if (canvasStyleY != null) {
        final r = polarCoord
            .convertRadius(polarCoord.transposed ? cross.dx : cross.dy);
        elements.add(ArcElement(
            oval: Rect.fromCircle(center: coord.center, radius: r),
            startAngle: coord.startAngle,
            endAngle: coord.endAngle,
            style: canvasStyleY));
      }
    }

    scene.set(elements, RectElement(rect: coord.region, style: PaintStyle()));
  }
}
