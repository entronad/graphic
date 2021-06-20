import 'package:collection/collection.dart';
import 'package:graphic/src/scale/base.dart';

import 'base.dart';

class Proportion extends Transform {
  Proportion({
    required this.variable,
    this.groupBy,
    required this.as,
    this.scale,
  });

  final String variable;

  final List<String>? groupBy;

  final String as;

  final Scale? scale;

  @override
  bool operator ==(Object other) =>
    other is Proportion &&
    super == other &&
    variable == other.variable &&
    DeepCollectionEquality().equals(groupBy, other.groupBy) &&
    as == other.as &&
    scale == other.scale;
}
