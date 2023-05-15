import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/mark/mark.dart';
import 'package:graphic/src/mark/modifier/modifier.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/variable/variable.dart';

/// The tuple to store the original values of a datum.
///
/// The key strings are variable names. The value types can only be [num], [String],
/// or [DateTime].
///
/// See also:
///
/// - [Variable], which creates original value tuple fields from input datum.
typedef Tuple = Map<String, dynamic>;

/// The tuple to store the scaled values of a datum.
///
/// The key strings are variable names.
///
/// See also:
///
/// - [Scale], which converts original value tuples to scaled value tuples.
/// - [Tuple], original value tuple.
typedef Scaled = Map<String, num>;

/// The aesthetic attribute values of a tuple.
class Attributes {
  /// Creates a attributes.
  Attributes({
    required this.index,
    this.tag,
    required this.position,
    required this.shape,
    this.color,
    this.gradient,
    this.elevation,
    this.label,
    this.size,
  }) : assert(isSingle([color, gradient]));

  /// The index of the tuple in all tuples list.
  final int index;

  final String? tag;

  /// Position points of the tuple.
  ///
  /// The count of points is determined by the geometry mark type. The values
  /// of each point dimension is scaled and normalized value of `[0, 1]`. the position
  /// points can be converted to canvas points by [CoordConv].
  final List<Offset> position;

  /// The shape of the tuple.
  final Shape shape;

  /// The color of the tuple.
  final Color? color;

  /// The gradient of the tuple.
  final Gradient? gradient;

  /// The shadow elevation of the tuple.
  final double? elevation;

  /// The label of the tuple.
  final Label? label;

  /// The size of the tuple.
  final double? size;

  /// The represent point of [position] points.
  Offset get representPoint => shape.representPoint(position);

  /// Returns a new attributes that matches this attributes with the position replaced
  /// with [p].
  ///
  /// This method is mainly used for [Modifier]s.
  Attributes withPosition(List<Offset> p) => Attributes(
        index: index,
        tag: tag,
        position: p,
        shape: shape,
        color: color,
        gradient: gradient,
        elevation: elevation,
        label: label,
        size: size,
      );

  /// Returns the original state of an item attributes in animation according to
  /// [entrance] type.
  Attributes deflate(Set<MarkEntrance> entrance) {
    var rst = this;

    if (entrance.contains(MarkEntrance.x)) {
      rst = Attributes(
        index: rst.index,
        tag: rst.tag,
        position: rst.position
            .map((p) => Offset(p.dx.isFinite ? 0 : p.dx, p.dy))
            .toList(),
        shape: rst.shape,
        color: rst.color,
        gradient: rst.gradient,
        elevation: rst.elevation,
        label: rst.label,
        size: rst.size,
      );
    }

    if (entrance.contains(MarkEntrance.y)) {
      rst = Attributes(
        index: rst.index,
        tag: rst.tag,
        position: rst.position
            .map((p) => Offset(p.dx, p.dy.isFinite ? 0 : p.dy))
            .toList(),
        shape: rst.shape,
        color: rst.color,
        gradient: rst.gradient,
        elevation: rst.elevation,
        label: rst.label,
        size: rst.size,
      );
    }

    if (entrance.contains(MarkEntrance.size)) {
      rst = Attributes(
        index: rst.index,
        tag: rst.tag,
        position: rst.position,
        shape: rst.shape,
        color: rst.color,
        gradient: rst.gradient,
        elevation: rst.elevation,
        label: rst.label,
        size: 0,
      );
    }

    if (entrance.contains(MarkEntrance.opacity)) {
      final labelColor = rst.label?.style.textStyle?.color;
      final labelRst = labelColor == null
          ? rst.label
          : Label(
              rst.label!.text,
              LabelStyle(
                textStyle: rst.label!.style.textStyle!.apply(color: labelColor),
                span: rst.label!.style.span,
                textAlign: rst.label!.style.textAlign,
                textDirection: rst.label!.style.textDirection,
                textScaleFactor: rst.label!.style.textScaleFactor,
                maxLines: rst.label!.style.maxLines,
                ellipsis: rst.label!.style.ellipsis,
                locale: rst.label!.style.locale,
                strutStyle: rst.label!.style.strutStyle,
                textWidthBasis: rst.label!.style.textWidthBasis,
                textHeightBehavior: rst.label!.style.textHeightBehavior,
                minWidth: rst.label!.style.minWidth,
                maxWidth: rst.label!.style.maxWidth,
                offset: rst.label!.style.offset,
                rotation: rst.label!.style.rotation,
                align: rst.label!.style.align,
              ));

      if (rst.gradient != null) {
        final colorsRst =
            rst.gradient!.colors.map((color) => color.withAlpha(0)).toList();
        Gradient gradientRst;
        if (rst.gradient is LinearGradient) {
          gradientRst = LinearGradient(
            begin: (rst.gradient as LinearGradient).begin,
            end: (rst.gradient as LinearGradient).end,
            colors: colorsRst,
            stops: (rst.gradient as LinearGradient).stops,
            tileMode: (rst.gradient as LinearGradient).tileMode,
            transform: (rst.gradient as LinearGradient).transform,
          );
        } else if (rst.gradient is RadialGradient) {
          gradientRst = RadialGradient(
            center: (rst.gradient as RadialGradient).center,
            radius: (rst.gradient as RadialGradient).radius,
            colors: colorsRst,
            stops: (rst.gradient as RadialGradient).stops,
            tileMode: (rst.gradient as RadialGradient).tileMode,
            focal: (rst.gradient as RadialGradient).focal,
            focalRadius: (rst.gradient as RadialGradient).focalRadius,
            transform: (rst.gradient as RadialGradient).transform,
          );
        } else if (rst.gradient is SweepGradient) {
          gradientRst = SweepGradient(
            center: (rst.gradient as SweepGradient).center,
            startAngle: (rst.gradient as SweepGradient).startAngle,
            endAngle: (rst.gradient as SweepGradient).endAngle,
            colors: colorsRst,
            stops: (rst.gradient as SweepGradient).stops,
            tileMode: (rst.gradient as SweepGradient).tileMode,
            transform: (rst.gradient as SweepGradient).transform,
          );
        } else {
          throw ArgumentError('Wrong gradient type.');
        }
        rst = Attributes(
          index: rst.index,
          tag: rst.tag,
          position: rst.position,
          shape: rst.shape,
          color: rst.color,
          gradient: gradientRst,
          elevation: rst.elevation,
          label: labelRst,
          size: rst.size,
        );
      } else {
        rst = Attributes(
          index: rst.index,
          tag: rst.tag,
          position: rst.position,
          shape: rst.shape,
          color: color!.withAlpha(0),
          gradient: rst.gradient,
          elevation: rst.elevation,
          label: labelRst,
          size: rst.size,
        );
      }
    }

    return rst;
  }
}

/// Attributes lists for groups.
typedef AttributesGroups = List<List<Attributes>>;

extension AttributesGroupsExt on AttributesGroups {
  /// Gets an attributes form attributes groups by [Attributes.index].
  Attributes getAttributes(int index) {
    for (var group in this) {
      for (var attributes in group) {
        if (attributes.index == index) {
          return attributes;
        }
      }
    }
    throw ArgumentError('No attributes of index $index.');
  }
}
