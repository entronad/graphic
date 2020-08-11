import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';

class ChartState<D> with TypedMap {
  List<D> get data => this['data'] as List<D>;
  set data(List<D> value) => this['data'] = value;

  Map<String, ScaleComponent> get scales => this['scales'] as Map<String, ScaleComponent>;
  set scales(Map<String, ScaleComponent> value) => this['scales'] = value;

  CoordComponent get coord => this['coord'] as CoordComponent;
  set coord(CoordComponent value) => this['coord'] = value;
}

class ChartComponent<D> extends Component<ChartState<D>> {
  @override
  // TODO: implement originalState
  ChartState<D> get originalState => throw UnimplementedError();
  
}
