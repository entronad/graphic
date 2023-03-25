import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/mark/mark.dart';
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
  List<Offset> position;

  /// The shape of the tuple.
  Shape shape;

  /// The color of the tuple.
  Color? color;

  /// The gradient of the tuple.
  Gradient? gradient;

  /// The shadow elevation of the tuple.
  double? elevation;

  /// The label of the tuple.
  Label? label;

  /// The size of the tuple.
  double? size;

  /// The represent point of [position] points.
  Offset get representPoint => shape.representPoint(position);

  Attributes deflate(MarkEntrance entrance) {
    switch (entrance) {
      case MarkEntrance.x:
        return Attributes(
          index: index,
          tag: tag,
          position: position.map((p) => Offset(0, p.dy)).toList(),
          shape: shape,
          color: color,
          gradient: gradient,
          elevation: elevation,
          label: label,
          size: size,
        );
      case MarkEntrance.y:
        return Attributes(
          index: index,
          tag: tag,
          position: position.map((p) => Offset(p.dx, 0)).toList(),
          shape: shape,
          color: color,
          gradient: gradient,
          elevation: elevation,
          label: label,
          size: size,
        );
      case MarkEntrance.xy:
        return Attributes(
          index: index,
          tag: tag,
          position: position.map((p) => Offset.zero).toList(),
          shape: shape,
          color: color,
          gradient: gradient,
          elevation: elevation,
          label: label,
          size: size,
        );
      case MarkEntrance.size:
        return Attributes(
          index: index,
          tag: tag,
          position: position,
          shape: shape,
          color: color,
          gradient: gradient,
          elevation: elevation,
          label: label,
          size: 0,
        );
      case MarkEntrance.alpha:
        final labelColor = label?.style.textStyle?.color;
        final labelRst = labelColor == null
            ? label
            : Label(
                label!.text,
                LabelStyle(
                  textStyle: label!.style.textStyle!.apply(color: labelColor),
                  span: label!.style.span,
                  textAlign: label!.style.textAlign,
                  textDirection: label!.style.textDirection,
                  textScaleFactor: label!.style.textScaleFactor,
                  maxLines: label!.style.maxLines,
                  ellipsis: label!.style.ellipsis,
                  locale: label!.style.locale,
                  strutStyle: label!.style.strutStyle,
                  textWidthBasis: label!.style.textWidthBasis,
                  textHeightBehavior: label!.style.textHeightBehavior,
                  minWidth: label!.style.minWidth,
                  maxWidth: label!.style.maxWidth,
                  offset: label!.style.offset,
                  rotation: label!.style.rotation,
                  align: label!.style.align,
                ));

        if (gradient != null) {
          final colorsRst =
              gradient!.colors.map((color) => color.withAlpha(0)).toList();
          Gradient gradientRst;
          if (gradient is LinearGradient) {
            gradientRst = LinearGradient(
              begin: (gradient as LinearGradient).begin,
              end: (gradient as LinearGradient).end,
              colors: colorsRst,
              stops: (gradient as LinearGradient).stops,
              tileMode: (gradient as LinearGradient).tileMode,
              transform: (gradient as LinearGradient).transform,
            );
          } else if (gradient is RadialGradient) {
            gradientRst = RadialGradient(
              center: (gradient as RadialGradient).center,
              radius: (gradient as RadialGradient).radius,
              colors: colorsRst,
              stops: (gradient as RadialGradient).stops,
              tileMode: (gradient as RadialGradient).tileMode,
              focal: (gradient as RadialGradient).focal,
              focalRadius: (gradient as RadialGradient).focalRadius,
              transform: (gradient as RadialGradient).transform,
            );
          } else if (gradient is SweepGradient) {
            gradientRst = SweepGradient(
              center: (gradient as SweepGradient).center,
              startAngle: (gradient as SweepGradient).startAngle,
              endAngle: (gradient as SweepGradient).endAngle,
              colors: colorsRst,
              stops: (gradient as SweepGradient).stops,
              tileMode: (gradient as SweepGradient).tileMode,
              transform: (gradient as SweepGradient).transform,
            );
          } else {
            throw ArgumentError('Wrong gradient type.');
          }
          return Attributes(
            index: index,
            tag: tag,
            position: position,
            shape: shape,
            color: color,
            gradient: gradientRst,
            elevation: elevation,
            label: labelRst,
            size: size,
          );
        } else {
          return Attributes(
            index: index,
            tag: tag,
            position: position,
            shape: shape,
            color: color!.withAlpha(0),
            gradient: gradient,
            elevation: elevation,
            label: labelRst,
            size: size,
          );
        }
      default:
        throw ArgumentError('Wrong entrance type.');
    }
  }
}

/// Attributes lists for groups.
typedef AttributesGroups = List<List<Attributes>>;

extension AttributesGroupsExt on AttributesGroups {
  /// Gets an attributes form attributes groups by [Aes.index].
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
