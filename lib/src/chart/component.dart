import 'dart:ui';

import 'package:flutter/widgets.dart' hide Axis;
import 'package:graphic/src/attr/position.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/engine/group.dart';
import 'package:graphic/src/engine/renderer.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/axis/circular.dart';
import 'package:graphic/src/axis/horizontal.dart';
import 'package:graphic/src/axis/radial.dart';
import 'package:graphic/src/axis/vertical.dart';
import 'package:graphic/src/geom/base.dart';
import 'package:graphic/src/geom/adjust/base.dart';
import 'package:graphic/src/defaults.dart';

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

  Set<String> get xFields => this['xFields'] as Set<String>;
  set xFields(Set<String> value) => this['xFields'] = value;

  Set<String> get yFields => this['yFields'] as Set<String>;
  set yFields(Set<String> value) => this['yFields'] = value;

  Map<String, AxisComponent> get xAxes => this['xAxes'] as Map<String, AxisComponent>;
  set xAxes(Map<String, AxisComponent> value) => this['xAxes'] = value;

  Map<String, AxisComponent> get yAxes => this['yAxes'] as Map<String, AxisComponent>;
  set yAxes(Map<String, AxisComponent> value) => this['yAxes'] = value;
}

class ChartComponent<D> extends Component<ChartState<D>> {
  @override
  ChartState<D> createState() => ChartState<D>();

  @override
  void initDefaultState() {
    super.initDefaultState();

    state.renderer = Renderer();
    state.backPlot = state.renderer.addGroup();
    state.middlePlot = state.renderer.addGroup();
    state.frontPlot = state.renderer.addGroup();

    state
      ..scales = {}
      ..geoms = []
      ..xFields = Set()
      ..yFields = Set()
      ..xAxes = {}
      ..yAxes = {};
  }

  void setProps(ChartProps props) {
    _setTheme(props.theme);
    _setData(props.data);
    _setCoord(
      props.coord,
      props.size,
      props.padding,
      props.margin,
    );
    _setScales(props.scales);
    _setGeoms(props.geoms);
    _setAxes(
      props.axes,
      state.coord,
      state.theme,
      state.scales,
      state.xFields,
      state.yFields,
    );

    _render();
  }

  void _setTheme(Theme theme) {
    state.theme = Theme()
      ..mix(Defaults.theme)
      ..mix(theme);
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

    margin = margin ?? EdgeInsets.all(5);
    region = margin.deflateRect(region);
    state.backPlot.state.clip = Path()..addRect(region);
    state.frontPlot.state.clip = Path()..addRect(region);

    if (padding == null) {
      if (coordComponent is PolarCoordComponent) {
        padding = EdgeInsets.all(40);
      } else {
        padding = EdgeInsets.fromLTRB(40, 5, 10, 20);
      }
    }
    region = padding.deflateRect(region);
    state.middlePlot.state.clip = Path()..addRect(region);
    
    coordComponent.setRegion(region);

    state.coord = coordComponent;
  }

  void _setScales(Map<String, Scale> scales) {
    state.scales.clear();

    for (var field in scales.keys) {
      final scale = scales[field];
      scale.complete(state.data, state.coord);

      state.scales[field] = ScaleComponent.create(scale);
    }
  }

  void _setGeoms(List<Geom> geoms) {
    state.geoms.clear();
    state.xFields.clear();
    state.yFields.clear();

    for (var geom in geoms) {
      final geomComponent = GeomComponent.create(geom);

      geomComponent
        ..state.chart = this
        ..setColor(geom['color'])
        ..setShape(geom['shape'])
        ..setSize(geom['size'])
        ..setPosition(geom['position']);
      
      if (geom['adjust'] != null) {
        final adjustComponent = AdjustComponent.create(geom['adjust']);
        geomComponent.state.adjust = adjustComponent;
      }

      state.geoms.add(geomComponent);
      final positionAttr = geomComponent.state.position;
      state.xFields.addAll(positionAttr.state.xFields);
      state.yFields.addAll(positionAttr.state.yFields);
    }
  }

  void _setAxes(
    Map<String, Axis> axes,
    CoordComponent coord,
    Theme theme,
    Map<String, ScaleComponent> scales,
    Set<String> xFields,
    Set<String> yFields,
  ) {
    state.xAxes.clear();
    state.yAxes.clear();

    if (axes == null) {
      return;
    }

    for (var field in axes.keys) {
      final axis = axes[field];
      final scale = scales[field];

      if (xFields.contains(field)) {
        AxisComponent axisComponent;
        if (coord is PolarCoordComponent) {
          if (coord.state.transposed) {
            axisComponent = RadialAxisComponent();
          } else {
            axisComponent = CircularAxisComponent();
          }
        } else {
          if (coord.state.transposed) {
            axisComponent = VerticalAxisComponent();
          } else {
            axisComponent = HorizontalAxisComponent();
          }
        }

        axisComponent
          ..mixProps(axis)
          ..state.chart = this
          ..state.scale = scale;
        state.xAxes[field] = axisComponent;
      }

      if (yFields.contains(field)) {
        AxisComponent axisComponent;
        if (coord is PolarCoordComponent) {
          if (coord.state.transposed) {
            axisComponent = CircularAxisComponent();
          } else {
            axisComponent = RadialAxisComponent();
          }
        } else {
          if (coord.state.transposed) {
            axisComponent = HorizontalAxisComponent();
          } else {
            axisComponent = VerticalAxisComponent();
          }
        }

        axisComponent
          ..mixProps(axis)
          ..state.chart = this
          ..state.scale = scale;
        state.yAxes[field] = axisComponent;
      }
    }
  }

  void _render() {
    for (var axis in state.xAxes.values) {
      axis.render();
    }
    for (var axis in state.yAxes.values) {
      axis.render();
    }
    for (var geom in state.geoms) {
      geom.render();
    }
  }
}
