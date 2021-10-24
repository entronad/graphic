import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';

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
  /// The count of points is determined by the geometory element type. The values
  /// of each point dimension is scaled and normalized value of `[0, 1]`. the position
  /// points can be converted to canvas points by [CoordConv].
  List<Offset> position;

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
  Offset get representPoint =>
    shape.representPoint(position);
}

typedef AesGroups = List<List<Aes>>;

extension AesGroupsExt on AesGroups {
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
