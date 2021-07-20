import 'package:graphic/src/scale/scale.dart';

import 'transform.dart';

class Proportion extends Transform {
  Proportion({
    required this.variable,
    this.groupBy,
    required this.as,
    this.scale,
  });

  final String variable;

  final String? groupBy;

  final String as;

  final Scale? scale;

  @override
  bool operator ==(Object other) =>
    other is Proportion &&
    super == other &&
    variable == other.variable &&
    groupBy == other.groupBy &&
    as == other.as &&
    scale == other.scale;
}
