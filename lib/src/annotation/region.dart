import 'dart:ui';

import 'package:collection/collection.dart';

import 'annotation.dart';

class RegionAnnotation extends Annotation {
  RegionAnnotation({
    this.dim,
    this.variable,
    required this.values,
    this.color,

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

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
