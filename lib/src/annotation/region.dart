import 'dart:ui';

import 'package:collection/collection.dart';

import 'base.dart';

class RegionAnnotation extends Annotation {
  RegionAnnotation({
    this.dim,
    this.variable,
    required this.values,
    this.color,
  });

  final int? dim;

  final String? variable;

  final List values;

  final Color? color;

  @override
  bool operator ==(Object other) =>
    other is RegionAnnotation &&
    super == other &&
    dim == other.dim &&
    variable == other.variable &&
    DeepCollectionEquality().equals(values, other.values) &&
    color == color;
}
