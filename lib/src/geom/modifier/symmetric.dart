import 'base.dart';

class SymmetricModifier extends Modifier {
  @override
  bool operator ==(Object other) =>
    other is SymmetricModifier &&
    super == other;
}
