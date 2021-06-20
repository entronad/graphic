import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/util/assert.dart';

abstract class Coord {
  Coord({
    this.dim,
    this.transposed,
    this.backgroundColor,
    this.backgroundGradient,
  }) : assert(isSingle([backgroundColor, backgroundGradient], allowNone: true));

  final int? dim;

  final bool? transposed;

  final Color? backgroundColor;

  final Gradient? backgroundGradient;

  @override
  bool operator ==(Object other) =>
    other is Coord &&
    dim == other.dim &&
    transposed == other.transposed &&
    backgroundColor == other.backgroundColor &&
    backgroundGradient == other.backgroundGradient;
}
