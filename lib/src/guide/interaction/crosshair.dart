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
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/select/point.dart';

class CrosshairGuide {
  CrosshairGuide({
    this.select,
    this.dim,
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

  int? dim;

  /// Single means both.
  List<StrokeStyle>? styles;

  /// Single means both.
  List<bool>? followPointer;

  int? zIndex;

  /// The tooltip can only refer to one element.
  /// This is the index in elements.
  int? element;

  @override
  bool operator ==(Object other) =>
    other is CrosshairGuide &&
    select == other.select &&
    dim == other.dim &&
    DeepCollectionEquality().equals(styles, other.styles) &&
    DeepCollectionEquality().equals(followPointer, other.followPointer) &&
    zIndex == other.zIndex &&
    element == other.element;
}

class CrosshairPainter extends Painter {
  CrosshairPainter(
    this.cross,
    this.styles,
    this.coord,
  );

  // Abstract point.
  // Created by item represent point, pointer, and follwoPointer.
  final Offset cross;

  // Abstract dim order.
  // Created by spec styles and dim.
  final List<StrokeStyle?> styles;

  final CoordConv coord;

  @override
  void paint(Canvas canvas) {
    final region = coord.region;
    final canvasStyleX = coord.transposed ? styles[1] : styles[0];
    final canvasStyleY = coord.transposed ? styles[0] : styles[1];
    if (coord is RectCoordConv) {
      final canvasCross = coord.convert(cross);
      if (canvasStyleX != null) {
        final canvasX = coord.transposed ? canvasCross.dy : canvasCross.dx;
        canvas.drawLine(
          Offset(canvasX, region.top),
          Offset(canvasX, region.bottom),
          canvasStyleX.toPaint(),
        );
      }
      if (canvasStyleY != null) {
        final canvasY = coord.transposed ? canvasCross.dx : canvasCross.dy;
        canvas.drawLine(
          Offset(region.left, canvasY),
          Offset(region.right, canvasY),
          canvasStyleY.toPaint(),
        );
      }
    } else {
      final polarCoord = coord as PolarCoordConv;
      if (canvasStyleX != null) {
        final angle = polarCoord.convertAngle(polarCoord.transposed ? cross.dy : cross.dx);
        canvas.drawLine(
          region.center,
          polarCoord.polarToOffset(angle, region.shortestSide),
          canvasStyleX.toPaint(),
        );
      }
      if (canvasStyleY != null) {
        final r = polarCoord.convertRadius(polarCoord.transposed ? cross.dx : cross.dy);
        canvas.drawCircle(
          region.center,
          r,
          canvasStyleY.toPaint(),
        );
      }
    }
  }
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
    final styles = params['styles'] as List<StrokeStyle>;
    final followPointer = params['followPointer'] as List<bool>;

    if (
      selector == null ||
      selects == null ||
      selector.name != selectorName
    ) {
      scene.painter = null;
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

    final painter = CrosshairPainter(
      Offset(
        followPointer[0] ? pointer.dx : selected!.dx,
        followPointer[1] ? pointer.dy : selected!.dy,
      ),
      styles,
      coord,
    );

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region)
      ..painter = painter;
  }
}
