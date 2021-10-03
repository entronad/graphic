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
import 'package:graphic/src/interaction/select/point.dart';
import 'package:graphic/src/util/path.dart';

class CrosshairGuide {
  CrosshairGuide({
    this.select,
    this.styles,
    this.followPointer,
    this.zIndex,
    this.element,
  });

  /// The selection must:
  ///     Be a PointSelection.
  ///     Toggle is false.
  ///     No variable.
  String? select;

  /// [dim1, dim2]
  List<StrokeStyle?>? styles;

  /// [dim1, dim2]
  List<bool>? followPointer;

  int? zIndex;

  /// The tooltip can only refer to one element.
  /// This is the index in elements.
  int? element;

  @override
  bool operator ==(Object other) =>
    other is CrosshairGuide &&
    select == other.select &&
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
    final selector = params['selector'] as PointSelector?;
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

    final pointer = coord.invert(selector.eventPoints.first);
    final index = selects.first;

    Offset? selected;
    for (var group in groups) {
      for (var aes in group) {
        if (aes.index == index) {
          selected = aes.representPoint;
          break;
        }
      }
    }

    final figures = <Figure>[];

    final cross = Offset(
      followPointer[0] ? pointer.dx : selected!.dx,
      followPointer[1] ? pointer.dy : selected!.dy,
    );
    final region = coord.region;
    final canvasStyleX = coord.transposed ? styles[1] : styles[0];
    final canvasStyleY = coord.transposed ? styles[0] : styles[1];
    if (coord is RectCoordConv) {
      final canvasCross = coord.convert(cross);
      if (canvasStyleX != null) {
        final canvasX = coord.transposed ? canvasCross.dy : canvasCross.dx;
        figures.add(PathFigure(
          Paths.line(
            from: Offset(canvasX, region.top),
            to: Offset(canvasX, region.bottom),
          ),
          canvasStyleX.toPaint(),
        ));
      }
      if (canvasStyleY != null) {
        final canvasY = coord.transposed ? canvasCross.dx : canvasCross.dy;
        figures.add(PathFigure(
          Paths.line(
            from: Offset(region.left, canvasY),
            to: Offset(region.right, canvasY),
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
            from: region.center,
            to: polarCoord.polarToOffset(angle, region.shortestSide),
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
