import 'dart:ui';
import 'dart:math';

import 'package:flutter/widgets.dart' hide Axis;
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/engine/group.dart';
import 'package:graphic/src/engine/renderer.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/scale/category/base.dart';
import 'package:graphic/src/scale/linear/base.dart';
import 'package:graphic/src/geom/base.dart';

import 'theme.dart';

class ChartProps<D> with TypedMap {
  Size get size => this['size'] as Size;
  set size(Size value) => this['size'] = value;

  Theme get theme => this['theme'] as Theme;
  set theme(Theme value) => this['theme'] = value;

  EdgeInsets get padding => this['padding'] as EdgeInsets;
  set padding(EdgeInsets value) => this['padding'] = value;

  EdgeInsets get margin => this['margin'] as EdgeInsets;
  set margin(EdgeInsets value) => this['margin'] = value;

  List<D> get data => this['data'] as List<D>;
  set data(List<D> value) => this['data'] = value;

  Map<String, Scale> get scales => this['scales'] as Map<String, Scale>;
  set scales(Map<String, Scale> value) => this['scales'] = value;

  Coord get coord => this['coord'] as Coord;
  set coord(Coord value) => this['coord'] = value;

  List<Geom> get geoms => this['geoms'] as List<Geom>;
  set geoms(List<Geom> value) => this['geoms'] = value;

  Map<String, Axis> get axes => this['axes'] as Map<String, Axis>;
  set axes(Map<String, Axis> value) => this['axes'] = value;
}

class ChartState<D> with TypedMap {
  Group get frontPlot => this['frontPlot'] as Group;
  set frontPlot(Group value) => this['frontPlot'] = value;

  Group get middlePlot => this['middlePlot'] as Group;
  set middlePlot(Group value) => this['middlePlot'] = value;

  Group get backPlot => this['backPlot'] as Group;
  set backPlot(Group value) => this['backPlot'] = value;

  Renderer get renderer => this['renderer'] as Renderer;
  set renderer(Renderer value) => this['renderer'] = value;

  Size get size => this['size'] as Size;
  set size(Size value) => this['size'] = value;

  Theme get theme => this['theme'] as Theme;
  set theme(Theme value) => this['theme'] = value;

  List<D> get data => this['data'] as List<D>;
  set data(List<D> value) => this['data'] = value;

  Map<String, ScaleComponent> get scales => this['scales'] as Map<String, ScaleComponent>;
  set scales(Map<String, ScaleComponent> value) => this['scales'] = value;

  CoordComponent get coord => this['coord'] as CoordComponent;
  set coord(CoordComponent value) => this['coord'] = value;

  List<GeomComponent> get geoms => this['geoms'] as List<GeomComponent>;
  set geoms(List<GeomComponent> value) => this['geoms'] = value;
}

class ChartComponent<D> extends Component<ChartState<D>> {
  @override
  ChartState<D> get originalState => ChartState<D>();

  @override
  void initDefaultState() {
    super.initDefaultState();

    state.renderer = Renderer();
    state.backPlot = state.renderer.addGroup();
    state.middlePlot = state.renderer.addGroup();
    state.frontPlot = state.renderer.addGroup();

    state
      ..scales = {}
      ..geoms = [];
  }

  void setProps(ChartProps props) {
    
  }

  void _setData(List<D> data) {
    state.data = data;
  }

  void _setCoord(
    Coord coord,
    Size size,
    EdgeInsets padding,
    EdgeInsets margin,
  ) {
    coord = coord ?? CartesianCoord();

    final coordComponent = CoordComponent.create(coord);

    var region = Rect.fromLTWH(0, 0, size.width, size.height);

    if (padding == null) {
      if (coordComponent is PolarCoordComponent) {
        padding = EdgeInsets.all(15);
      } else {
        padding = EdgeInsets.fromLTRB(15, 0, 0, 15);
      }
    }
    region = padding.deflateRect(region);

    margin = margin ?? EdgeInsets.all(5);
    region = margin.deflateRect(region);

    coordComponent.setRegion(region);

    state.coord = coordComponent;
  }

  void _setScales(Map<String, Scale> scales) {
    state.scales.clear();

    for (var field in scales.keys) {
      final scale = scales[field];

      if (scale is CategoryScale) {
        if (scale['values'] == null) {
          final accessor = scale['accessor'];
          final values = state.data.map(accessor).toSet().toList();
          scale['values'] = values;
        }
        if (scale['scaledRange'] == null) {
          final count = (scale['values'] as List).length;
          if (state.coord is PolarCoordComponent) {
            scale['scaledRange'] = [0, 1 - 1 / count];
          } else {
            scale['scaledRange'] = [1 / count / 2, 1 - 1 / count / 2];
          }
        }
      } else if(scale is LinearScale) {
        if (scale['max'] == null || scale['min'] == null) {
          final accessor = scale['accessor'];
          final values = state.data.map(accessor).toList() as List<num>;
          scale['max'] = scale['max'] ?? values.reduce(max);
          scale['min'] = scale['min'] ?? values.reduce(min);
        }
      }

      state.scales[field] = ScaleComponent.create(scale);
    }
  }

  void _setGeoms(List<Geom> geoms) {
    state.geoms.clear();

    for (var geom in geoms) {
      final geomComponent = GeomComponent.create(geom);

      geomComponent
        ..state.chart = this
        ..setColor(geom['color'])
        ..setShape(geom['shape'])
        ..setSize(geom['size'])
        ..setPosition(geom['position']);

      state.geoms.add(geomComponent);
    }
  }

  void update() {
    _render();
  }

  void _render() {

  }
}
