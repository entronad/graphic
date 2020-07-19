import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';
import '../category/base.dart';

abstract class OrdinalScaleState<V> extends CategoryScaleState<V> {
  bool get isSorted => this['isSorted'] as bool ?? false;
  set isSorted(bool value) => this['isSorted'] = value;
}

abstract class OrdinalScaleComponent<S extends OrdinalScaleState<V>, V>
  extends CategoryScaleComponent<S, V>
{
  OrdinalScaleComponent([Props<ScaleType> props]) : super(props);

  // operations

  int compare(V a, V b);

  @override
  void assign() {
    if (!state.isSorted) {
      state.values.sort(compare);
    }

    super.assign();
  }
}
