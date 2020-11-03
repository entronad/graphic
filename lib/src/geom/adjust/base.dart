import 'dart:ui';

import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/common/typed_map.dart';

import '../base.dart';
import 'dodge.dart';
import 'stack.dart';
import 'symmetric.dart';

enum AdjustType {
  dodge,
  stack,
  symmetric,
}

abstract class Adjust extends Props<AdjustType> {}

abstract class AdjustState with TypedMap {}

abstract class AdjustComponent<S extends AdjustState>
  extends Component<S>
{
  static AdjustComponent create(Adjust props) {
    switch (props.type) {
      case AdjustType.dodge:
        return DodgeAdjustComponent(props);
      case AdjustType.stack:
        return StackAdjustComponent(props);
      case AdjustType.symmetric:
        return SymmetricAdjustComponent(props);
      default: return null;
    }
  }

  AdjustComponent([TypedMap props]) : super(props);

  void adjust(List<List<ElementRecord>> recordsGroup, Offset origin);
}
