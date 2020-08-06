import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/scale/base.dart';

class ChartState<D> with TypedMap {
  List<D> get data => this['data'] as List<D>;
  set data(List<D> value) => this['data'] = value;

  Map<String, ScaleComponent> get scales => this['scales'] as Map<String, ScaleComponent>;
  set scales(Map<String, ScaleComponent> value) => this['scales'] = value;
}

class ChartComponent<D> extends Component<ChartState<D>> {
  @override
  // TODO: implement originalState
  ChartState<D> get originalState => throw UnimplementedError();
  
}
