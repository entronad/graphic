import 'dart:math';
import 'dart:ui';

import 'package:graphic/src/graffiti/element/arc.dart';
import 'package:graphic/src/graffiti/element/line.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/scale/scale.dart';

/// The specification of a crosshair
///
/// A corsshair indicates the position of the pointer or the selected point. If
/// no point is selected, it will not occur.
class CrosshairGuide {
  /// Creates a crosshair.
  CrosshairGuide({
    this.selections,
    this.styles,
    this.labelStyles,
    this.labelBackgroundStyles,
    this.showLabel,
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

  /// The label styles of crosshair lines for each dimension.
  List<LabelStyle?>? labelStyles;

  /// The labelBackground styles of crosshair lines for each dimension.
  List<PaintStyle?>? labelBackgroundStyles;

  /// Whether to show label on axis.
  ///
  /// If null, a default `[false, false]` is set.
  List<bool>? showLabel;

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
      deepCollectionEquals(labelStyles, other.labelStyles) &&
      deepCollectionEquals(
          labelBackgroundStyles, other.labelBackgroundStyles) &&
      deepCollectionEquals(showLabel, other.showLabel) &&
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
    final tuples = params['tuples'] as List<Tuple>;
    final styles = params['styles'] as List<PaintStyle?>;
    final labelStyles = params['labelStyles'] as List<LabelStyle?>;
    final labelBackgroundStyles =
        params['labelBackgroundStyles'] as List<PaintStyle?>;
    final showLabel = params['showLabel'] as List<bool>;
    final followPointer = params['followPointer'] as List<bool>;
    final scales = params['scales'] as Map<String, ScaleConv>;

    // The main indicator is selected, if no selector, takes selectedPoint for pointer.
    final name = singleIntersection(selected?.keys, selections);
    final selects = name == null ? null : selected?[name];

    if (selects == null || selects.isEmpty) {
      scene.set(null);
      return;
    }

    final selectedTuples = <int, Tuple>{};
    for (var index in selects) {
      selectedTuples[index] = tuples[index];
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
    final labelStyleX = coord.transposed ? labelStyles[1] : labelStyles[0];
    final labelStyleY = coord.transposed ? labelStyles[0] : labelStyles[1];
    final labelBackgroundStyleX =
        coord.transposed ? labelBackgroundStyles[1] : labelBackgroundStyles[0];
    final labelBackgroundStyleY =
        coord.transposed ? labelBackgroundStyles[0] : labelBackgroundStyles[1];
    final fields = scales.keys.toList();
    final selectedTupleList = selectedTuples.values;
    final tuple = selectedTupleList.last;

    if (coord is RectCoordConv) {
      final canvasCross = coord.convert(cross);
      if (canvasStyleX != null) {
        final canvasCrossX =
            max(min(canvasCross.dx, region.right), region.left);
        elements.add(LineElement(
          start: Offset(canvasCrossX, region.top),
          end: Offset(canvasCrossX, region.bottom),
          style: canvasStyleX,
        ));

        if (showLabel[0] && !canvasCross.dx.isNaN && labelStyleX != null) {
          final fieldX = coord.transposed ? fields[1] : fields[0];
          final scaleX = scales[fieldX];
          final text = scaleX?.format(scaleX.invert(cross.dx)) ?? '';
          final rect = _getLabelBlock(text: text, style: labelStyleX);

          double posX = canvasCrossX;
          if (posX - rect.width / 2 <= region.left) {
            posX = region.left + rect.width / 2;
          }

          if (posX + rect.width / 2 >= region.right) {
            posX = region.right - rect.width / 2;
          }

          final label = LabelElement(
            text: text,
            anchor: Offset(posX, region.bottom + rect.height / 2),
            style: labelStyleX,
          );

          if (labelBackgroundStyleX != null) {
            elements.add(RectElement(
              rect: label.getBlock(),
              style: labelBackgroundStyleX,
            ));
          }

          elements.add(label);
        }
      }
      if (canvasStyleY != null) {
        final canvasCrossY =
            max(min(canvasCross.dy, region.bottom), region.top);
        elements.add(LineElement(
          start: Offset(region.left, canvasCrossY),
          end: Offset(region.right, canvasCrossY),
          style: canvasStyleY,
        ));

        if (showLabel[1] && !canvasCross.dy.isNaN && labelStyleY != null) {
          final fieldY = coord.transposed ? fields[0] : fields[1];
          final scaleY = scales[fieldY];
          final text = scaleY?.format(scaleY.invert(cross.dy)) ?? '';
          final rect = _getLabelBlock(text: text, style: labelStyleY);

          double posY = canvasCrossY;
          if (posY - rect.height / 2 <= region.top) {
            posY = region.top + rect.height / 2;
          }

          if (posY + rect.height / 2 >= region.bottom) {
            posY = region.bottom - rect.height / 2;
          }

          final label = LabelElement(
            text: text,
            anchor: Offset(region.left - rect.width / 2, posY),
            style: labelStyleY,
          );

          if (labelBackgroundStyleY != null) {
            elements.add(RectElement(
              rect: label.getBlock(),
              style: labelBackgroundStyleY,
            ));
          }

          elements.add(label);
        }
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

        if (showLabel[0] && labelStyleX != null) {
          final fieldX = coord.transposed ? fields[2] : fields[0];
          final scaleX = scales[fieldX];
          final text = scaleX?.format(tuple[fieldX]) ?? '';
          final diagonal = _getLabelDiagonal(text: text, style: labelStyleX);

          final label = LabelElement(
            text: text,
            anchor:
                polarCoord.polarToOffset(angle, coord.endRadius + diagonal / 2),
            style: labelStyleX,
          );

          if (labelBackgroundStyleX != null) {
            elements.add(RectElement(
              rect: label.getBlock(),
              style: labelBackgroundStyleX,
            ));
          }

          elements.add(label);
        }
      }
      if (canvasStyleY != null) {
        final abstractRadius =
            min(polarCoord.transposed ? cross.dx : cross.dy, 1.0);
        final r = polarCoord.convertRadius(abstractRadius);
        elements.add(ArcElement(
            oval: Rect.fromCircle(center: coord.center, radius: r),
            startAngle: coord.startAngle,
            endAngle: coord.endAngle,
            style: canvasStyleY));

        if (showLabel[1] && labelStyleY != null) {
          final fieldY = coord.transposed ? fields[0] : fields[2];
          final scaleY = scales[fieldY];
          final value = scaleY?.invert(abstractRadius);
          final text = scaleY?.format(value) ?? '';
          final rect = _getLabelBlock(text: text, style: labelStyleY);

          final label = LabelElement(
            text: text,
            anchor:
                Offset(coord.center.dx - rect.width / 2, coord.center.dy - r),
            style: labelStyleY,
          );

          if (labelBackgroundStyleY != null) {
            elements.add(RectElement(
              rect: label.getBlock(),
              style: labelBackgroundStyleY,
            ));
          }

          elements.add(label);
        }
      }
    }

    scene.set(elements);
  }

  Rect _getLabelBlock({required String text, required LabelStyle style}) =>
      LabelElement(
        text: text,
        anchor: const Offset(0, 0),
        style: style,
      ).getBlock();

  double _getLabelDiagonal({required String text, required LabelStyle style}) {
    final rect = _getLabelBlock(text: text, style: style);

    return sqrt(pow(rect.height, 2) + pow(rect.width, 2));
  }
}
