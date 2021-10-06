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
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/assert.dart';

typedef RenderTooltip = List<Figure> Function(
  Offset anchor,
  List<Original> selectedTuples,
  Map<String, ScaleConv> scales,
);

class TooltipGuide {
  TooltipGuide({
    this.select,
    this.variables,
    this.followPointer,
    this.zIndex,
    this.element,
    this.align,
    this.offset,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.elevation,
    this.textStyle,
    this.render,
  })
    : assert(isSingle([render, align], allowNone: true)),
      assert(isSingle([render, offset], allowNone: true)),
      assert(isSingle([render, padding], allowNone: true)),
      assert(isSingle([render, backgroundColor], allowNone: true)),
      assert(isSingle([render, radius], allowNone: true)),
      assert(isSingle([render, elevation], allowNone: true)),
      assert(isSingle([render, textStyle], allowNone: true));

  String? select;

  /// Variables to show.
  /// Default to show all.
  List<String>? variables;

  List<bool>? followPointer;

  int? zIndex;

  /// The tooltip can only refer to one element.
  /// This is the index in elements.
  int? element;

  // Render params.

  Alignment? align;

  Offset? offset;

  EdgeInsets? padding;

  Color? backgroundColor;

  Radius? radius;

  double? elevation;

  TextStyle? textStyle;

  RenderTooltip? render;

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
    // render is Function.
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
    final selector = params['selector'] as Selector?;
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
    final render = params['render'] as RenderTooltip?;
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

    final pointer = coord.invert(selector.eventPoints.last);

    Offset selectedPoint = Offset.zero;
    final selectedOriginals = <Original>[];
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
      selectedOriginals.add(originals[index]);
    }
    selectedPoint = selectedPoint / count.toDouble();

    final fields = variables ?? scales.keys.toList();

    final anchor = coord.convert(Offset(
      followPointer[0] ? pointer.dx : selectedPoint.dx,
      followPointer[1] ? pointer.dy : selectedPoint.dy,
    ));

    List<Figure> figures;
    if (render != null) {
      figures = render(
        anchor,
        selectedOriginals,
        scales,
      );
    } else {
      String textContent = '';
      if (selectedOriginals.length == 1) {
        final original = selectedOriginals.single;
        var field = fields.first;
        var scale = scales[field]!;
        var title = scale.title;
        textContent += '$title: ${scale.formatter(original[field])}';
        for (var i = 1; i < fields.length; i++) {
          field = fields[i];
          scale = scales[field]!;
          title = scale.title;
          textContent += '\n$title: ${scale.formatter(original[field])}';
        }
      } else {
        var field = selector.variable;
        var scale;
        var title;
        if (field != null) {
          scale = scales[field]!;
          title = scale.title;
          textContent += '$title: ${scale.formatter(selectedOriginals.first[field])}';
        }
        for (var field in fields) {
          scale = scales[field]!;
          title = scale.title;
          textContent += '\n$title:';
          for (var original in selectedOriginals) {
            textContent += ' ${scale.formatter(original[field])}';
          }
        }
      }

      final painter = TextPainter(
        text: TextSpan(text: textContent, style: textStyle),
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
        : (Path()..addRRect(RRect.fromRectAndRadius(widow, radius)));
      
      figures = <Figure>[];

      if (elevation != null && elevation != 0) {
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
    }

    scene
      ..zIndex = zIndex
      // Tooltip dosent't need to clip within region.
      ..figures = figures.isEmpty ? null : figures;
  }
}
