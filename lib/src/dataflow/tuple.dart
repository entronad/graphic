import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
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
class Aes {
  /// Creates a aes.
  Aes({
    required this.index,
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

  /// Position points of the tuple.
  ///
  /// The count of points is determined by the geometry element type. The values
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
}

/// Aes lists for groups.
typedef AesGroups = List<List<Aes>>;

extension AesGroupsExt on AesGroups {
  /// Gets an aes form aes groups by [Aes.index].
  Aes getAes(int index) {
    for (var group in this) {
      for (var aes in group) {
        if (aes.index == index) {
          return aes;
        }
      }
    }
    throw ArgumentError('No aes of index $index.');
  }
}
