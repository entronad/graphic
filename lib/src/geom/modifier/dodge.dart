import 'base.dart';

class DodgeModifier extends Modifier {
  DodgeModifier({
    this.ratio,
  });

  final double? ratio;

  @override
  bool operator ==(Object other) =>
    other is DodgeModifier &&
    super == other &&
    ratio == other.ratio;
}
