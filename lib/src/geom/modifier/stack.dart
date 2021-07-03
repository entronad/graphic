import 'modifier.dart';

class StackModifier extends Modifier {
  @override
  bool operator ==(Object other) =>
    other is StackModifier &&
    super == other;
}
