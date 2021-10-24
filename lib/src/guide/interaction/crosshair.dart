import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/layers.dart';
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
/// A corsshair indicates the position of the pointer or the selected point.
class CrosshairGuide {
  /// Creates a crosshair.
  CrosshairGuide({
    this.selection,
    this.styles,
    this.followPointer,
    this.zIndex,
    this.element,
  });

  /// The selection this crosshair reacts to.
  /// 
  /// If null, the first selection is set by default.
  String? selection;

  /// The stroke styles of crosshair lines for each dimension.
  /// 
  /// If null a default `[StrokeStyle(color: Color(0xffbfbfbf)), StrokeStyle(color: Color(0xffbfbfbf))]`
  /// is set.
  List<StrokeStyle?>? styles;

  /// Whether the position for each dimension follows the pointer or stick to selected
  /// points.
  /// 
  /// If null, a default `[false, false]` is set.
  List<bool>? followPointer;

  /// The z index of this crosshair.
  /// 
  /// If null, a default 0 is set.
  int? zIndex;

  /// Which element series this crosshair reacts to.
  /// 
  /// This is an index in [Spec.elements].
  /// 
  /// The crosshair can only reacts to one element series.
  /// 
  /// If null, the first element series is set by default.
  int? element;

  @override
  bool operator ==(Object other) =>
    other is CrosshairGuide &&
    selection == other.selection &&
    DeepCollectionEquality().equals(styles, other.styles) &&
    DeepCollectionEquality().equals(followPointer, other.followPointer) &&
    zIndex == other.zIndex &&
    element == other.element;
}

class CrosshairScene extends Scene {
  @override
  int get layer => Layers.crosshair;
}

class CrosshairRenderOp extends Render<CrosshairScene> {
  CrosshairRenderOp(
    Map<String, dynamic> params,
    CrosshairScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final selectorName = params['selectorName'] as String;
    final selector = params['selector'] as Selector?;
    final selects = params['selects'] as Set<int>?;
    final zIndex = params['zIndex'] as int;
    final coord = params['coord'] as CoordConv;
    final groups = params['groups'] as AesGroups;
    final styles = params['styles'] as List<StrokeStyle?>;
    final followPointer = params['followPointer'] as List<bool>;

    if (
      selector == null ||
      selects == null ||
      selector.name != selectorName
    ) {
      scene.figures = null;
      return;
    }

    final pointer = coord.invert(selector.eventPoints.last);

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
          Paths.line(
            from: Offset(canvasCross.dx, region.top),
            to: Offset(canvasCross.dx, region.bottom),
          ),
          canvasStyleX.toPaint(),
        ));
      }
      if (canvasStyleY != null) {
        figures.add(PathFigure(
          Paths.line(
            from: Offset(region.left, canvasCross.dy),
            to: Offset(region.right, canvasCross.dy),
          ),
          canvasStyleY.toPaint(),
        ));
      }
    } else {
      final polarCoord = coord as PolarCoordConv;
      if (canvasStyleX != null) {
        final angle = polarCoord.convertAngle(
          polarCoord.transposed ? cross.dy : cross.dx
        );
        figures.add(PathFigure(
          Paths.line(
            from: polarCoord.polarToOffset(angle, coord.startRadius),
            to: polarCoord.polarToOffset(angle, coord.endRadius),
          ),
          canvasStyleX.toPaint(),
        ));
      }
      if (canvasStyleY != null) {
        final r = polarCoord.convertRadius(
          polarCoord.transposed ? cross.dx : cross.dy
        );
        figures.add(PathFigure(
          Path()..addArc(
            Rect.fromCircle(center: coord.center, radius: r),
            coord.startAngle,
            coord.endAngle - coord.startAngle,
          ),
          canvasStyleY.toPaint()
            ..style = PaintingStyle.stroke,
        ));
      }
    }

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region)
      ..figures = figures.isEmpty ? null : figures;
  }
}
