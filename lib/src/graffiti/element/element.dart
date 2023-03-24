import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:graphic/src/util/collection.dart';

import 'package:path_drawing/path_drawing.dart';
import 'package:graphic/src/util/assert.dart';

import 'segment/segment.dart';
import 'group.dart';
import 'path.dart';

abstract class ElementStyle {
  ElementStyle lerpFrom(covariant ElementStyle from, double t);

  @override
  bool operator ==(Object other) => other is ElementStyle;
}

abstract class MarkElement<S extends ElementStyle> {
  MarkElement({
    required this.style,
    this.rotation,
    this.rotationAxis,
  }) : assert(rotation == null || rotationAxis != null);

  final S style;

  final double? rotation;

  final Offset? rotationAxis;

  @protected
  void draw(Canvas canvas);

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

  MarkElement<S> lerpFrom(covariant MarkElement<S> from, double t);

  @override
  bool operator ==(Object other) =>
      other is MarkElement &&
      style == other.style &&
      rotation == other.rotation &&
      rotationAxis == other.rotationAxis;
}

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

class PaintStyle extends ElementStyle {
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

  final Color? fillColor;

  final painting.Gradient? fillGradient;

  final Shader? fillShader; // won't lerp

  final Color? strokeColor;

  final painting.Gradient? strokeGradient;

  final Shader? strokeShader; // won't lerp

  final Rect? gradientBounds;

  final BlendMode? blendMode;

  final double? strokeWidth;

  final StrokeCap? strokeCap;

  final StrokeJoin? strokeJoin;

  final double? strokeMiterLimit;

  final double? elevation;

  final Color? shadowColor;

  final List<double>? dash;

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

abstract class PrimitiveElement extends MarkElement<PaintStyle> {
  PrimitiveElement({
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
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
      _dathPath = dashPath(path,
          dashArray: CircularIntervalList(style.dash!),
          dashOffset: style.dashOffset);
    }
  }

  final path = Path();

  Paint? _fillPaint;

  Paint? _strokePaint;

  Path? _dathPath;

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
      canvas.drawPath(_dathPath ?? path, _strokePaint!);
    }
  }

  @override
  PrimitiveElement lerpFrom(covariant PrimitiveElement from, double t);

  List<Segment> toSegments();

  @override
  bool operator ==(Object other) => other is PrimitiveElement && super == other;
}

abstract class BlockStyle extends ElementStyle {
  BlockStyle({
    this.offset,
    this.rotation,
    this.align,
  }) : super();

  /// The offset of the box from the anchor.
  final Offset? offset;

  /// The rotation of the box.
  ///
  /// The rotation axis is the anchor point with [offset].
  final double? rotation;

  /// How the box align to the anchor point.
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

abstract class BlockElement<S extends BlockStyle> extends MarkElement<S> {
  BlockElement({
    required this.anchor,
    required this.defaultAlign,
    required S style,
  }) : super(
          style: style,
          rotation: style.rotation,
          rotationAxis: style.offset == null ? anchor : anchor + style.offset!,
        );

  final Offset anchor;

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

// No predicate, call only when needed.
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

  // use runtimeType because of PathElemnet's sub classes.
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

List<List<MarkElement>> nomalizeElementList(
    List<MarkElement> from, List<MarkElement> to) {
  final fromRst = <MarkElement>[];
  final toRst = <MarkElement>[];
  assert(from.length == to.length);
  for (var i = 0; i < to.length; i++) {
    final elementPair = nomalizeElement(from[i], to[i]);
    fromRst.add(elementPair.first);
    toRst.add(elementPair.last);
  }
  return [fromRst, toRst];
}
