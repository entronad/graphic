import 'package:graphic/src/util/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/intrinsic_layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/selection/interval.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/assert.dart';

/// Gets the figures of a tooltip.
///
/// The [anchor] is the result either set directly or calculated. The keys of [selectedTuples]
/// are indexes of the tuples in the whole data set.
typedef TooltipRenderer = List<Figure> Function(
  Size size,
  Offset anchor,
  Map<int, Tuple> selectedTuples,
);

/// The specification of a tooltip
///
/// A default tooltip construct and style is provided with slight configurations,
/// But you can deeply custom your own tooltip with [renderer] property.
class TooltipGuide {
  /// Creates a tooltip.
  TooltipGuide({
    this.selections,
    this.followPointer,
    this.anchor,
    this.layer,
    this.mark,
    this.align,
    this.offset,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.elevation,
    this.textStyle,
    this.multiTuples,
    this.variables,
    this.constrained,
    this.renderer,
  })  : assert(isSingle([renderer, align], allowNone: true)),
        assert(isSingle([renderer, offset], allowNone: true)),
        assert(isSingle([renderer, padding], allowNone: true)),
        assert(isSingle([renderer, backgroundColor], allowNone: true)),
        assert(isSingle([renderer, radius], allowNone: true)),
        assert(isSingle([renderer, elevation], allowNone: true)),
        assert(isSingle([renderer, textStyle], allowNone: true)),
        assert(isSingle([renderer, multiTuples], allowNone: true)),
        assert(isSingle([renderer, constrained], allowNone: true)),
        assert(isSingle([renderer, variables], allowNone: true));

  /// The selections this crosshair reacts to.
  ///
  /// Make sure this selections will not occur simultaneously.
  ///
  /// If null, it will reacts to all selections.
  Set<String>? selections;

  /// Whether the position for each dimension follows the pointer or stick to selected
  /// points.
  ///
  /// If null, a default `[false, false]` is set.
  List<bool>? followPointer;

  /// Indicates the anchor position of this tooltip directly.
  ///
  /// This is a function with chart size as input that you may need to calculate
  /// the position.
  ///
  /// If set, this tooltip will no longer follow the pointer or the selected point.
  Offset Function(Size)? anchor;

  /// The layer of this tooltip.
  ///
  /// If null, a default 0 is set.
  int? layer;

  /// Which mark series this tooltip reacts to.
  ///
  /// This is an index in [Chart.marks].
  ///
  /// The crosshair can only reacts to one mark series.
  ///
  /// If null, the first mark series is set by default.
  int? mark;

  /// How this tooltip align to the anchor.
  ///
  /// If null, a default `Alignment.center` is set.
  Alignment? align;

  /// The offset of the tooltip form the anchor.
  Offset? offset;

  /// The padding form the content to the window border of this tooltip.
  ///
  /// If null, a default `EdgeInsets.all(5)` is set.
  EdgeInsets? padding;

  /// The background color of this tooltip window.
  ///
  /// If null, a default `Color(0xf0ffffff)` is set.
  Color? backgroundColor;

  /// The border radius of this tooltip window.
  ///
  /// If null, a default `Radius.circular(3)` is set.
  Radius? radius;

  /// The shadow elevation of this tooltip window.
  ///
  /// If null, a default 3 is set.
  double? elevation;

  /// The text style of this tooltip content.
  ///
  /// If null, a default `TextStyle(color: Color(0xff595959), fontSize: 12,)` is
  /// set.
  TextStyle? textStyle;

  /// Whether to show multiple tuples or only single tuple in this tooltip.
  ///
  /// For single tuple, [variables] are layed in rows showing title and value. For
  /// multiple tuples, tuples are layed in rows showing the 2 [variables] values.
  ///
  /// If null, it will varies according to triggering selector, that true for an
  /// [IntervalSelection] or [Selection.variable] is set, and false otherwise.
  bool? multiTuples;

  /// The variable values of tuples to show on in this tooltip.
  ///
  /// The layout of variable displaying is determined by [multiTuples]. For multiple
  /// tuples, the varable counts must be 2.
  ///
  /// If null, It will be set to all variables for single tuple and first 2 variables
  /// except [Selection.variable] for multiple tuples.
  List<String>? variables;

  /// Whether the tooltip should be constrained within the chart widget border.
  ///
  /// If constrained, the position will be adjusted if the tooltip may overflow
  /// the chart widget border. If not, the outside part will be clipped.
  ///
  /// If null, a default true is set.
  bool? constrained;

  /// Indicates a custom render funcion of this tooltip.
  ///
  /// If set, [align], [offset], [padding], [backgroundColor], [radius], [elevation],
  /// [textStyle], [multiTuples], [variables], and [constrained] are useless and
  /// not allowed.
  TooltipRenderer? renderer;

  @override
  bool operator ==(Object other) =>
      other is TooltipGuide &&
      deepCollectionEquals(selections, other.selections) &&
      deepCollectionEquals(followPointer, other.followPointer) &&
      layer == other.layer &&
      mark == other.mark &&
      align == other.align &&
      offset == other.offset &&
      padding == other.padding &&
      backgroundColor == other.backgroundColor &&
      radius == other.radius &&
      elevation == other.elevation &&
      textStyle == other.textStyle &&
      multiTuples == other.multiTuples &&
      deepCollectionEquals(variables, other.variables) &&
      constrained == other.constrained;
}

/// The tooltip scene.
class TooltipScene extends Scene {
  TooltipScene(int layer) : super(layer);

  @override
  int get intrinsicLayer => IntrinsicLayers.tooltip;
}

/// The tooltip render operator.
class TooltipRenderOp extends Render<TooltipScene> {
  TooltipRenderOp(
    Map<String, dynamic> params,
    TooltipScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final selections = params['selections'] as Set<String>;
    final selectors = params['selectors'] as Map<String, Selector>?;
    final selected = params['selected'] as Selected?;
    final selectionSpecs = params['selectionSpecs'] as Map<String, Selection>;
    final coord = params['coord'] as CoordConv;
    final groups = params['groups'] as AesGroups;
    final tuples = params['tuples'] as List<Tuple>;
    final align = params['align'] as Alignment;
    final offset = params['offset'] as Offset?;
    final padding = params['padding'] as EdgeInsets;
    final backgroundColor = params['backgroundColor'] as Color;
    final radius = params['radius'] as Radius?;
    final elevation = params['elevation'] as double?;
    final textStyle = params['textStyle'] as TextStyle;
    final multiTuples = params['multiTuples'] as bool?;
    final renderer = params['renderer'] as TooltipRenderer?;
    final followPointer = params['followPointer'] as List<bool>;
    final anchor = params['anchor'] as Offset Function(Size)?;
    final size = params['size'] as Size;
    final variables = params['variables'] as List<String>?;
    final constrained = params['constrained'] as bool;
    final scales = params['scales'] as Map<String, ScaleConv>;

    // The main indicator is selected, if no selector, takes selectedPoint for pointer.
    final name = singleIntersection(selected?.keys, selections);
    final selects = name == null ? null : selected?[name];

    if (selects == null || selects.isEmpty) {
      scene.figures = null;
      return;
    }

    final selectedTuples = <int, Tuple>{};
    for (var index in selects) {
      selectedTuples[index] = tuples[index];
    }

    Offset anchorRst;
    if (anchor != null) {
      anchorRst = anchor(size);
    } else {
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

      anchorRst = coord.convert(Offset(
        followPointer[0] ? pointer.dx : selectedPoint.dx,
        followPointer[1] ? pointer.dy : selectedPoint.dy,
      ));
    }

    List<Figure> figures;
    if (renderer != null) {
      figures = renderer(
        size,
        anchorRst,
        selectedTuples,
      );
    } else {
      String textContent = '';
      final selectedTupleList = selectedTuples.values;

      final selectionSpec = selectionSpecs[name]!;
      final multiTuplesRst = multiTuples ??
          (selectionSpec is IntervalSelection ||
              selectionSpec.variable != null);

      if (!multiTuplesRst) {
        final fields = variables ?? scales.keys.toList();
        final tuple = selectedTupleList.last;
        var field = fields.first;
        var scale = scales[field]!;
        var title = scale.title;
        textContent += '$title: ${scale.format(tuple[field])}';
        for (var i = 1; i < fields.length; i++) {
          field = fields[i];
          scale = scales[field]!;
          title = scale.title;
          textContent += '\n$title: ${scale.format(tuple[field])}';
        }
      } else {
        final groupField = selectionSpec.variable;

        var fields = variables;
        if (fields == null) {
          fields = [];
          for (var variable in scales.keys) {
            if (variable != groupField) {
              fields.add(variable);
            }
            if (fields.length == 2) {
              break;
            }
          }
        }

        assert(fields.length == 2);

        if (groupField != null) {
          textContent +=
              scales[groupField]!.format(selectedTupleList.first[groupField]) ??
                  '';
        }
        for (var tuple in selectedTupleList) {
          final domainField = fields.first;
          final measureField = fields.last;
          final domainScale = scales[domainField]!;
          final measureScale = scales[measureField]!;
          textContent +=
              '\n${domainScale.format(tuple[domainField])}: ${measureScale.format(tuple[measureField])}';
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
        offset == null ? anchorRst : anchorRst + offset,
        width,
        height,
        align,
      );

      var windowRect = Rect.fromLTWH(
        paintPoint.dx,
        paintPoint.dy,
        width,
        height,
      );

      var textPaintPoint = paintPoint + padding.topLeft;

      if (constrained) {
        final horizontalAdjust = windowRect.left < 0
            ? -windowRect.left
            : (windowRect.right > size.width
                ? size.width - windowRect.right
                : 0.0);
        final verticalAdjust = windowRect.top < 0
            ? -windowRect.top
            : (windowRect.bottom > size.height
                ? size.height - windowRect.bottom
                : 0.0);
        if (horizontalAdjust != 0 || verticalAdjust != 0) {
          windowRect = windowRect.translate(horizontalAdjust, verticalAdjust);
          textPaintPoint =
              textPaintPoint.translate(horizontalAdjust, verticalAdjust);
        }
      }

      final windowPath = radius == null
          ? (Path()..addRect(windowRect))
          : (Path()..addRRect(RRect.fromRectAndRadius(windowRect, radius)));

      figures = <Figure>[];

      if (elevation != null && elevation != 0) {
        figures.add(ShadowFigure(
          windowPath,
          backgroundColor,
          elevation,
        ));
      }
      figures.add(PathFigure(
        windowPath,
        Paint()..color = backgroundColor,
      ));
      figures.add(TextFigure(
        painter,
        textPaintPoint,
      ));
    }

    // Tooltip dosent't need to be cliped within the coordinate region.
    scene.figures = figures.isEmpty ? null : figures;
  }
}
