import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';

typedef Original = Map<String, dynamic>;

typedef Scaled = Map<String, num>;

/// All fields can be modified by select of modifier.
class Aes {
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

  final int index;

  /// Composed of normal value of each dim, result of the position operator.
  /// It can be converted to canvas position by coord in shape.
  List<Offset> position;

  final Shape shape;

  final Color? color;

  final Gradient? gradient;

  final double? elevation;

  final Label? label;

  /// If needed, default to shape's defaultSize.
  final double? size;

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
