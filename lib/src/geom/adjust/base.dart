import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/common/typed_map.dart';

import '../base.dart';

enum AdjustType {
  dodge,
  stack,
  symmetric,
}

abstract class Adjust extends Props<AdjustType> {}

abstract class AdjustState with TypedMap {}

abstract class AdjustComponent<S extends AdjustState> extends Component<S> {
  AdjustComponent([TypedMap props]) : super(props);

  void adjust(List<List<AttrValueRecord>> recordsGroup);
}
