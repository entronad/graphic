import 'annotation.dart';

class LineAnnotation extends Annotation {
  LineAnnotation({
    this.dim,
    this.variable,
    required this.value,

    int? zIndex,
  }) : super(
    zIndex: zIndex,
  );

  /// The dim where the line stands.
  final int? dim;

  /// The measure variable.
  final String? variable;

  /// The variable value where the line stands.
  final dynamic value;

  @override
  bool operator ==(Object other) =>
    other is LineAnnotation &&
    super == other &&
    dim == other.dim &&
    variable == other.variable &&
    value == other.value;
}
