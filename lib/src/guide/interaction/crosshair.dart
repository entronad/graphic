import 'dart:ui';

import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/intrinsic_layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/path.dart';

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
    this.element,
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
  /// If null a default `[StrokeStyle(color: Color(0xffbfbfbf)), StrokeStyle(color: Color(0xffbfbfbf))]`
  /// is set.
  List<StrokeStyle?>? styles;

  /// Whether the position for each dimension follows the pointer or stick to selected
  /// points.
  ///
  /// If null, a default `[false, false]` is set.
  List<bool>? followPointer;

  /// The layer of this crosshair.
  ///
  /// If null, a default 0 is set.
  int? layer;

  /// Which element series this crosshair reacts to.
  ///
  /// This is an index in [Chart.elements].
  ///
  /// The crosshair can only reacts to one element series.
  ///
  /// If null, the first element series is set by default.
  int? element;

  @override
  bool operator ==(Object other) =>
      other is CrosshairGuide &&
      deepCollectionEquals(selections, other.selections) &&
      deepCollectionEquals(styles, other.styles) &&
      deepCollectionEquals(followPointer, other.followPointer) &&
      layer == other.layer &&
      element == other.element;
}

/// The crosshair scene.
class CrosshairScene extends Scene {
  CrosshairScene(int layer) : super(layer);

  @override
  int get intrinsicLayer => IntrinsicLayers.crosshair;
}

/// The crosshair render operator.
class CrosshairRenderOp extends Render<CrosshairScene> {
  CrosshairRenderOp(
    Map<String, dynamic> params,
    CrosshairScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final selections = params['selections'] as Set<String>;
    final selectors = params['selectors'] as Map<String, Selector>?;
    final selected = params['selected'] as Selected?;
    final coord = params['coord'] as CoordConv;
    final groups = params['groups'] as AesGroups;
    final styles = params['styles'] as List<StrokeStyle?>;
    final followPointer = params['followPointer'] as List<bool>;

    // The main indicator is selected, if no selector, takes selectedPoint for pointer.
    final name = singleIntersection(selected?.keys, selections);
    final selects = name == null ? null : selected?[name];

    if (selects == null || selects.isEmpty) {
      scene.figures = null;
      return;
    }

    Offset selectedPoint = Offset.zero;
    int count = 0;
    final findPoint = (int index) {
      for (var group in groups) {
        for (var aes in group) {
          if (aes.index == index) {
            count += 1;
            return aes.representPoint;
          }
        }
      }
      return Offset.zero;
    };
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

    final figures = <Figure>[];

    final region = coord.region;
    final canvasStyleX = coord.transposed ? styles[1] : styles[0];
    final canvasStyleY = coord.transposed ? styles[0] : styles[1];
    if (coord is RectCoordConv) {
      final canvasCross = coord.convert(cross);
      if (canvasStyleX != null) {
        figures.add(PathFigure(
          canvasStyleX.dashPath(Paths.line(
            from: Offset(canvasCross.dx, region.top),
            to: Offset(canvasCross.dx, region.bottom),
          )),
          canvasStyleX.toPaint(),
        ));
      }
      if (canvasStyleY != null) {
        figures.add(PathFigure(
          canvasStyleY.dashPath(Paths.line(
            from: Offset(region.left, canvasCross.dy),
            to: Offset(region.right, canvasCross.dy),
          )),
          canvasStyleY.toPaint(),
        ));
      }
    } else {
      final polarCoord = coord as PolarCoordConv;
      if (canvasStyleX != null) {
        final angle = polarCoord
            .convertAngle(polarCoord.transposed ? cross.dy : cross.dx);
        figures.add(PathFigure(
          canvasStyleX.dashPath(Paths.line(
            from: polarCoord.polarToOffset(angle, coord.startRadius),
            to: polarCoord.polarToOffset(angle, coord.endRadius),
          )),
          canvasStyleX.toPaint(),
        ));
      }
      if (canvasStyleY != null) {
        final r = polarCoord
            .convertRadius(polarCoord.transposed ? cross.dx : cross.dy);
        figures.add(PathFigure(
          canvasStyleY.dashPath(Path()
            ..addArc(
              Rect.fromCircle(center: coord.center, radius: r),
              coord.startAngle,
              coord.endAngle - coord.startAngle,
            )),
          canvasStyleY.toPaint()..style = PaintingStyle.stroke,
        ));
      }
    }

    scene
      ..setRegionClip(coord.region)
      ..figures = figures.isEmpty ? null : figures;
  }
}
