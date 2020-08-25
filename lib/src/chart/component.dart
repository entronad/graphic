import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/engine/group.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';

import 'theme.dart';

class ChartState<D> with TypedMap {
  List<D> get data => this['data'] as List<D>;
  set data(List<D> value) => this['data'] = value;

  Map<String, ScaleComponent> get scales => this['scales'] as Map<String, ScaleComponent>;
  set scales(Map<String, ScaleComponent> value) => this['scales'] = value;

  CoordComponent get coord => this['coord'] as CoordComponent;
  set coord(CoordComponent value) => this['coord'] = value;

  Theme get theme => this['theme'] as Theme;
  set theme(Theme value) => this['theme'] = value;

  Group get frontPlot => this['frontPlot'] as Group;
  set frontPlot(Group value) => this['frontPlot'] = value;

  Group get middlePlot => this['middlePlot'] as Group;
  set middlePlot(Group value) => this['middlePlot'] = value;

  Group get backPlot => this['backPlot'] as Group;
  set backPlot(Group value) => this['backPlot'] = value;
}

class ChartComponent<D> extends Component<ChartState<D>> {
  @override
  ChartState<D> get originalState => ChartState<D>();
}
