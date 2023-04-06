import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:graphic/src/util/collection.dart';

import 'package:path_drawing/path_drawing.dart';
import 'package:graphic/src/util/assert.dart';

import 'segment/segment.dart';
import 'group.dart';
import 'path.dart';
import '../scene.dart';

/// The style of [MarkElement].
abstract class ElementStyle {
  /// Linearly interpolate between this style and [from].
  ElementStyle lerpFrom(covariant ElementStyle from, double t);

  @override
  bool operator ==(Object other) => other is ElementStyle;
}

/// The basic element to compose graphics on [MarkScene]s.
abstract class MarkElement<S extends ElementStyle> {
  /// Creates an element.
  MarkElement({
    required this.style,
    this.rotation,
    this.rotationAxis,
    this.tag,
  }) : assert(rotation == null || rotationAxis != null);

  /// The style of this element.
  final S style;

  /// The rotation of this element.
  final double? rotation;

  /// The rotation axis of this element.
  /// 
  /// If [rotation] is not null, this is required.
  final Offset? rotationAxis;

  /// The tag to indicate correspondence of this element in animation.
  /// 
  /// The element list dosen't cares about order and relation, which is different
  /// from [Segment] list. So to make a best morphing, the two element list only
  /// need to have the same tags set.
  final String? tag;

  /// Indicates how this element is drawn.
  @protected
  void draw(Canvas canvas);

  /// Paints this element on [canvas].
  void paint(Canvas canvas) {
    if (rotation == null) {
      draw(canvas);
    } else {
      canvas.save();

      canvas.translate(rotationAxis!.dx, rotationAxis!.dy);
      canvas.rotate(rotation!);
      canvas.translate(-rotationAxis!.dx, -rotationAxis!.dy);

      draw(canvas);

      canvas.restore();
    }
  }

  /// Linearly interpolate between this element and [from].
  MarkElement<S> lerpFrom(covariant MarkElement<S> from, double t);

  @override
  bool operator ==(Object other) =>
      other is MarkElement &&
      style == other.style &&
      rotation == other.rotation &&
      rotationAxis == other.rotationAxis &&
      tag == other.tag;
}

/// Linearly interpolate dash lists.
List<double>? _lerpDash(List<double>? a, List<double>? b, double t) {
  if (a == null || b == null || a.length != b.length) {
    return b;
  }
  final rst = <double>[];
  for (var i = 0; i < b.length; i++) {
    rst.add(lerpDouble(a[i], b[i], t)!);
  }
  return rst;
}

/// The style of [PrimitiveElement].
class PaintStyle extends ElementStyle {
  /// Creates a paint style.
  PaintStyle({
    this.fillColor,
    this.fillGradient,
    this.fillShader,
    this.strokeColor,
    this.strokeGradient,
    this.strokeShader,
    this.gradientBounds,
    this.blendMode,
    this.strokeWidth,
    this.strokeCap,
    this.strokeJoin,
    this.strokeMiterLimit,
    this.elevation,
    Color? shadowColor,
    this.dash,
    this.dashOffset,
  })  : assert(
            isSingle([fillColor, fillGradient, fillShader], allowNone: true)),
        assert(isSingle([strokeColor, strokeGradient, strokeShader],
            allowNone: true)),
        assert(strokeColor != null ||
            strokeGradient != null ||
            strokeShader != null ||
            (strokeWidth == null ||
                strokeCap == null ||
                strokeJoin == null ||
                strokeMiterLimit == null)),
        assert(elevation != null || shadowColor == null),
        assert(dash != null || dashOffset == null),
        shadowColor = elevation == null
            ? null
            : fillColor ?? (strokeColor ?? const Color(0xFF000000));

  /// The color to fill the shape.
  /// 
  /// Only one of [fillColor], [fillGradient], [fillShader] can be set.
  final Color? fillColor;

  /// The gradient to fill the shape.
  /// 
  /// Only one of [fillColor], [fillGradient], [fillShader] can be set.
  final painting.Gradient? fillGradient;

  /// The shader to fill the shape.
  /// 
  /// It won't be interpolated in animation.
  /// 
  /// Only one of [fillColor], [fillGradient], [fillShader] can be set.
  final Shader? fillShader;

  /// The color for shape's outlines.
  /// 
  /// Only one of [strokeColor], [strokeGradient], [strokeShader] can be set.
  final Color? strokeColor;

  /// The gradient for shape's outlines.
  /// 
  /// Only one of [strokeColor], [strokeGradient], [strokeShader] can be set.
  final painting.Gradient? strokeGradient;

  /// The shader for shape's outlines.
  /// 
  /// It won't be interpolated in animation.
  /// 
  /// Only one of [strokeColor], [strokeGradient], [strokeShader] can be set.
  final Shader? strokeShader;

  /// The bounds of [fillGradient] and [strokeGradient].
  final Rect? gradientBounds;

  /// The blend mode of the shape.
  final BlendMode? blendMode;

  /// Width of the shape's outlines.
  /// 
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final double? strokeWidth;

  /// The kind of finish to place on the end of the shape's outlines.
  /// 
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final StrokeCap? strokeCap;

  /// The kind of finish to place on the joins between segments of the shape's outlines.
  /// 
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final StrokeJoin? strokeJoin;

  /// The limit for miters to be drawn on segments of the shape's outlines.
  /// 
  /// It can only be set when [strokeColor], [strokeGradient], or [strokeShader]
  /// is not null.
  final double? strokeMiterLimit;

  /// The elevation of the shape's shadow.
  final double? elevation;

  /// The color of the shape's shadow.
  /// 
  /// It can only be set when [elevation] is not null. If null, it will be same
  /// as [fillColor] (if fillColor is set) or Color(0xFF000000).
  final Color? shadowColor;

  /// The dash list of the shape's outlines.
  final List<double>? dash;

  /// The dash offset of the shape's outlines.
  /// 
  /// It can only be set when [dash] is not null.
  final DashOffset? dashOffset;

  @override
  PaintStyle lerpFrom(covariant PaintStyle from, double t) => PaintStyle(
        fillColor: Color.lerp(from.fillColor, fillColor, t),
        fillGradient:
            painting.Gradient.lerp(from.fillGradient, fillGradient, t),
        fillShader: fillShader,
        strokeColor: Color.lerp(from.strokeColor, strokeColor, t),
        strokeGradient:
            painting.Gradient.lerp(from.strokeGradient, strokeGradient, t),
        strokeShader: strokeShader,
        gradientBounds: Rect.lerp(from.gradientBounds, gradientBounds, t),
        blendMode: blendMode,
        strokeWidth: lerpDouble(from.strokeWidth, strokeWidth, t),
        strokeCap: strokeCap,
        strokeJoin: strokeJoin,
        strokeMiterLimit:
            lerpDouble(from.strokeMiterLimit, strokeMiterLimit, t),
        elevation: lerpDouble(from.elevation, elevation, t),
        shadowColor: Color.lerp(from.shadowColor, shadowColor, t),
        dash: _lerpDash(from.dash, dash, t),
        dashOffset: dashOffset,
      );

  @override
  bool operator ==(Object other) =>
      other is PaintStyle &&
      super == other &&
      fillColor == other.fillColor &&
      fillGradient == other.fillGradient &&
      // fillShader will not check.
      strokeColor == other.strokeColor &&
      strokeGradient == other.strokeGradient &&
      // strokeShader will not check
      gradientBounds == other.gradientBounds &&
      blendMode == other.blendMode &&
      strokeWidth == other.strokeWidth &&
      strokeCap == other.strokeCap &&
      strokeJoin == other.strokeJoin &&
      strokeMiterLimit == other.strokeMiterLimit &&
      elevation == other.elevation &&
      shadowColor == other.shadowColor &&
      deepCollectionEquals(dash, other.dash) &&
      dashOffset == other.dashOffset;
}

/// The graphical primitive element of a basic shape.
abstract class PrimitiveElement extends MarkElement<PaintStyle> {
  /// Creates a primitive element.
  PrimitiveElement({
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
    String? tag,
  }) : super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
          tag: tag,
        ) {
    drawPath(path);

    if (style.fillColor != null ||
        style.fillGradient != null ||
        style.fillShader != null) {
      _fillPaint = Paint();

      if (style.fillShader != null) {
        _fillPaint!.shader = style.fillShader;
      } else if (style.fillGradient != null) {
        _fillPaint!.shader = style.fillGradient!
            .createShader(style.gradientBounds ?? path.getBounds());
      } else {
        _fillPaint!.color = style.fillColor!;
      }
      if (style.blendMode != null) {
        _fillPaint!.blendMode = style.blendMode!;
      }
    }

    if (style.strokeColor != null || style.strokeGradient != null) {
      _strokePaint = Paint();
      _strokePaint!.style = PaintingStyle.stroke;

      if (style.strokeShader != null) {
        _strokePaint!.shader = style.strokeShader;
      } else if (style.strokeGradient != null) {
        _strokePaint!.shader = style.strokeGradient!
            .createShader(style.gradientBounds ?? path.getBounds());
      } else {
        _strokePaint!.color = style.strokeColor!;
      }

      if (style.blendMode != null) {
        _strokePaint!.blendMode = style.blendMode!;
      }
      if (style.strokeWidth != null) {
        _strokePaint!.strokeWidth = style.strokeWidth!;
      }
      if (style.strokeCap != null) {
        _strokePaint!.strokeCap = style.strokeCap!;
      }
      if (style.strokeJoin != null) {
        _strokePaint!.strokeJoin = style.strokeJoin!;
      }
      if (style.strokeMiterLimit != null) {
        _strokePaint!.strokeMiterLimit = style.strokeMiterLimit!;
      }
    }

    if (style.dash != null) {
      _dashPath = dashPath(path,
          dashArray: CircularIntervalList(style.dash!),
          dashOffset: style.dashOffset);
    }
  }

  /// The path of this shape.
  final path = Path();

  /// The paint to fill the shape.
  Paint? _fillPaint;

  /// The paint of the shape's outlines.
  Paint? _strokePaint;

  /// The dash path converted from [path].
  Path? _dashPath;

  /// How to draw [path] of this shape.
  void drawPath(Path path);

  @override
  void draw(Canvas canvas) {
    if (style.elevation != null) {
      canvas.drawShadow(path, style.shadowColor!, style.elevation!, true);
    }

    if (_fillPaint != null) {
      canvas.drawPath(path, _fillPaint!);
    }

    if (_strokePaint != null) {
      canvas.drawPath(_dashPath ?? path, _strokePaint!);
    }
  }

  @override
  PrimitiveElement lerpFrom(covariant PrimitiveElement from, double t);

  /// Converts this shape to path segments.
  List<Segment> toSegments();

  @override
  bool operator ==(Object other) => other is PrimitiveElement && super == other;
}

/// The style of a [BlockElement].
abstract class BlockStyle extends ElementStyle {
  /// Creates a block style.
  BlockStyle({
    this.offset,
    this.rotation,
    this.align,
  }) : super();

  /// The offset of the block element from the anchor.
  final Offset? offset;

  /// The rotation of the block element.
  ///
  /// The rotation axis is the anchor point with [offset].
  final double? rotation;

  /// How the block element align to the anchor point.
  final painting.Alignment? align;

  @override
  bool operator ==(Object other) =>
      other is BlockStyle &&
      super == other &&
      offset == other.offset &&
      rotation == other.rotation &&
      align == other.align;
}

/// Calculates the real painting offset point for [BlockElement].
///
/// The [axis] is the anchor point with the [BlockElement]'s offset.
Offset getBlockPaintPoint(
  Offset axis,
  double width,
  double height,
  painting.Alignment align,
) =>
    Offset(
      axis.dx - (width / 2) + ((width / 2) * align.x),
      axis.dy - (height / 2) + ((height / 2) * align.y),
    );

/// The element displayed in a block.
abstract class BlockElement<S extends BlockStyle> extends MarkElement<S> {
  /// Creates a block element.
  BlockElement({
    required this.anchor,
    required this.defaultAlign,
    required S style,
    String? tag,
  }) : super(
          style: style,
          rotation: style.rotation,
          rotationAxis: style.offset == null ? anchor : anchor + style.offset!,
          tag: tag,
        );

  /// The anchor position of this block.
  final Offset anchor;

  /// The default align of this block to anchor when [BlockStyle.align] is not set.
  /// 
  /// This is useful because a block may need different default aligns for different
  /// anchor position.
  painting.Alignment defaultAlign;

  @protected
  late final Offset paintPoint;

  @override
  bool operator ==(Object other) =>
      other is BlockElement &&
      super == other &&
      anchor == other.anchor &&
      defaultAlign == other.defaultAlign;
}

/// Normalizes two [PrimitiveElement]s to a pair of [PathElement]s.
List<PathElement> _nomalizeShape(PrimitiveElement from, PrimitiveElement to) {
  final segmentsPair = nomalizeSegments(from.toSegments(), to.toSegments());
  return [
    PathElement(
        segments: segmentsPair.first,
        style: from.style,
        rotation: from.rotation,
        rotationAxis: from.rotationAxis),
    PathElement(
        segments: segmentsPair.last,
        style: to.style,
        rotation: to.rotation,
        rotationAxis: to.rotationAxis),
  ];
}

/// Normalizes two [MarkElement]s into same runtimeType for lerping.
List<MarkElement> nomalizeElement(MarkElement from, MarkElement to) {
  if (from is GroupElement && to is GroupElement) {
    final elementsPair = nomalizeElementList(from.elements, to.elements);
    return [
      GroupElement(
          elements: elementsPair.first,
          rotation: from.rotation,
          rotationAxis: from.rotationAxis),
      GroupElement(
          elements: elementsPair.last,
          rotation: to.rotation,
          rotationAxis: to.rotationAxis),
    ];
  }

  // Using runtimeType instead of is because there may be PathElemnet's sub classes.
  if (from.runtimeType == PathElement && to.runtimeType == PathElement) {
    return _nomalizeShape(from as PathElement, to as PathElement);
  }

  if (from.runtimeType == to.runtimeType) {
    return [from, to];
  }

  if (from is PrimitiveElement && to is PrimitiveElement) {
    return _nomalizeShape(from, to);
  }

  return [to, to];
}

/// Normalizes two element list into same corresponding item runtimeTypes for lerping.
/// 
/// The [from] may be reorded by tags to match [to].
List<List<MarkElement>> nomalizeElementList(
    List<MarkElement> from, List<MarkElement> to) {
  final fromRst = <MarkElement>[];
  final toRst = <MarkElement>[];
  assert(from.length == to.length);
  final fromCopy = [...from];
  for (var elementTo in to) {
    MarkElement? elementFrom;

    for (var i = 0; i < fromCopy.length; i++) {
      if (fromCopy[i].tag == elementTo.tag) {
        elementFrom = fromCopy.removeAt(i);
        break;
      }
    }
    elementFrom ??= fromCopy.removeAt(0);

    final elementPair = nomalizeElement(elementFrom, elementTo);
    fromRst.add(elementPair.first);
    toRst.add(elementPair.last);
  }
  return [fromRst, toRst];
}
