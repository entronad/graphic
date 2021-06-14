import 'package:graphic/src/parse/spec.dart';

abstract class Coord extends Spec {
  Coord({
    this.dim,
    this.transposed,
  });

  final int? dim;

  final bool? transposed;
}
