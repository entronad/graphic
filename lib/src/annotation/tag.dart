import 'package:collection/collection.dart';

import 'base.dart';

class TagAnnotation extends Annotation {
  TagAnnotation({
    this.variables,
    required this.values,
    this.width,

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

  /// Default to the dim 1 and dim 2 variables.
  final List<String>? variables;

  final List values;

  final double? width;

  @override
  bool operator ==(Object other) =>
    other is TagAnnotation &&
    super == other &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(values, values) &&
    width == other.width;
}
