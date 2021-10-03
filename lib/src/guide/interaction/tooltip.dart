import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/select/point.dart';
import 'package:graphic/src/scale/scale.dart';

class TooltipGuide {
  TooltipGuide({
    this.select,
    this.variables,
    this.followPointer,
    this.align,
    this.offset,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.elevation,
    this.textStyle,
    this.zIndex,
    this.element,
  });

  /// The select must:
  ///     Be a PointSelection.
  ///     Toggle is false.
  ///     No variable.
  String? select;

  /// Variables to show.
  /// Default to show all.
  List<String>? variables;

  List<bool>? followPointer;

  Alignment? align;

  Offset? offset;

  EdgeInsets? padding;

  Color? backgroundColor;

  Radius? radius;

  double? elevation;

  TextStyle? textStyle;

  int? zIndex;

  /// The tooltip can only refer to one element.
  /// This is the index in elements.
  int? element;

  @override
  bool operator ==(Object other) =>
    other is TooltipGuide &&
    select == other.select &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(followPointer, other.followPointer) &&
    align == other.align &&
    offset == other.offset &&
    padding == other.padding &&
    backgroundColor == other.backgroundColor &&
    radius == other.radius &&
    elevation == other.elevation &&
    textStyle == other.textStyle &&
    zIndex == other.zIndex &&
    element == other.element;
}

class TooltipScene extends Scene {
  @override
  int get layer => Layers.tooltip;
}

class TooltipRenderOp extends Render<TooltipScene> {
  TooltipRenderOp(
    Map<String, dynamic> params,
    TooltipScene scene,
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
    final originals = params['originals'] as List<Original>;
    final align = params['align'] as Alignment;
    final offset = params['offset'] as Offset?;
    final padding = params['padding'] as EdgeInsets;
    final backgroundColor = params['backgroundColor'] as Color;
    final radius = params['radius'] as Radius?;
    final elevation = params['elevation'] as double?;
    final textStyle = params['textStyle'] as TextStyle;
    final followPointer = params['followPointer'] as List<bool>;
    final variables = params['variables'] as List<String>?;
    final scales = params['scales'] as Map<String, ScaleConv>;

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

    final fields = variables ?? scales.keys.toList();

    final original = originals[index];
    var field = fields.first;
    var scale = scales[field]!;
    var title = scale.title;
    var textContent = '$title:${scale.formatter(original[field])}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      scale = scales[field]!;
      title = scale.title;
      textContent = textContent + '\n$title:${scale.formatter(original[field])}';
    }

    final painter = TextPainter(
      text: TextSpan(text: textContent, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    final width = padding.left + painter.width + padding.right;
    final height = padding.top + painter.height + padding.bottom;

    final paintPoint = getPaintPoint(
      coord.convert(Offset(
        followPointer[0] ? pointer.dx : selected!.dx,
        followPointer[1] ? pointer.dy : selected!.dy,
      )),
      width,
      height,
      align,
      offset,
    );

    final widow = Rect.fromLTWH(
      paintPoint.dx,
      paintPoint.dy,
      width,
      height,
    );

    final widowPath = radius == null
      ? (Path()..addRect(widow))
      : (Path()..addRRect(RRect.fromRectAndRadius(widow, radius)));
    
    final figures = <Figure>[];

    if (elevation != null) {
      figures.add(ShadowFigure(
        widowPath,
        backgroundColor,
        elevation,
      ));
    }
    figures.add(PathFigure(
      widowPath,
      Paint()..color = backgroundColor,
    ));
    figures.add(TextFigure(
      painter,
      paintPoint + padding.topLeft,
    ));

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region)
      ..figures = figures.isEmpty ? null : figures;
  }
}
