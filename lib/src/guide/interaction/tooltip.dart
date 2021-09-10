import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/select/point.dart';
import 'package:graphic/src/scale/scale.dart';

class Tooltip {
  Tooltip({
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
  final String? select;

  /// Variables to show.
  /// Default to show all.
  final List<String>? variables;

  final List<bool>? followPointer;

  final Alignment? align;

  final Offset? offset;

  final EdgeInsets? padding;

  final Color? backgroundColor;

  final Radius? radius;

  final double? elevation;

  final TextStyle? textStyle;

  final int? zIndex;

  /// The tooltip can only refer to one element.
  /// This is the index in elements.
  final int? element;

  @override
  bool operator ==(Object other) =>
    other is Tooltip &&
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

class TooltipPainter extends Painter {
  TooltipPainter(
    this.anchor,
    this.align,
    this.offset,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.elevation,
    this.text,
  );

  final Offset anchor;  // Canvas point.

  final Alignment align;

  final Offset? offset;

  final EdgeInsets padding;

  final Color backgroundColor;

  final Radius? radius;

  final double? elevation;

  final TextSpan text;

  @override
  void paint(Canvas canvas) {
    final painter = TextPainter(
      text: text,
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    final width = padding.left + painter.width + padding.right;
    final height = padding.top + painter.height + padding.bottom;

    final paintPoint = getPaintPoint(
      anchor,
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
      : (Path()..addRRect(RRect.fromRectAndRadius(widow, radius!)));
    
    canvas.drawPath(
      widowPath,
      Paint()..color = backgroundColor
    );

    if (elevation != null) {
      canvas.drawShadow(
        widowPath,
        backgroundColor,
        elevation!,
        true,
      );
    }

    painter.paint(
      canvas,
      paintPoint + padding.topLeft,
    );
  }
}

class TooltipScene extends Scene {
  @override
  int get layer => Layers.tooltip;
}

class TooltipRenderOp extends Render<TooltipScene> {
  TooltipRenderOp(
    Map<String, dynamic> params,
    TooltipScene scene,
  ) : super(params, scene);

  @override
  void render() {
    final selectorName = params['selectorName'] as String;
    final selector = params['selector'] as PointSelector;
    final selects = params['selects'] as Set<int>;
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

    if (selector.name != selectorName) {
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
    var textContent = '$title:${scale.formatter!(original[field])}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      scale = scales[field]!;
      title = scale.title;
      textContent = textContent + '\n$title:${scale.formatter!(original[field])}';
    }
    
    final painter = TooltipPainter(
      coord.convert(Offset(
        followPointer[0] ? pointer.dx : selected!.dx,
        followPointer[1] ? pointer.dy : selected!.dy,
      )),
      align,
      offset,
      padding,
      backgroundColor,
      radius,
      elevation,
      TextSpan(text: textContent, style: textStyle),
    );

    scene
      ..zIndex = zIndex
      ..setRegionClip(coord.region, coord is PolarCoordConv)
      ..painter = painter;
  }
}
