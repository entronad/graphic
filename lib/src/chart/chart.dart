import 'package:flutter/widgets.dart';
import 'package:graphic/src/component/axis/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/event/event_arena.dart';
import 'package:graphic/src/geom/base.dart';
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';

import 'chart_controller.dart';

class ChartCfg with TypedMapMixin {
  ChartCfg({
    double width,
    double height,
    EdgeInsets padding,
    EdgeInsets appendPadding,
    bool syncY,
    bool animate,
    Map<String, AxisCfg> axes,
    CoordCfg coord,
    List<Map<String, Object>> data,
    Map<String, DataFilter> filters,
    List<GeomCfg> geoms,
    Map<String, ScaleCfg> scales
  }) {
    if (width != null) this['width'] = width;
    if (height != null) this['height'] = height;
    this['padding'] = padding ?? EdgeInsets.all(null);
    this['appendPadding'] = appendPadding ?? EdgeInsets.all(15);
    if (syncY != null) this['syncY'] = syncY;
    if (animate != null) this['animate'] = animate;
    if (axes != null) this['axes'] = axes;
    if (coord != null) this['coord'] = coord;
    if (data != null) this['data'] = data;
    if (filters != null) this['filters'] = filters;
    if (geoms != null) this['geoms'] = geoms;
    if (scales != null) this['scales'] = scales;
  }

  double get width => this['width'] as double;
  set width(double value) => this['width'] = value;

  double get height => this['height'] as double;
  set height(double value) => this['height'] = value;

  EdgeInsets get padding => this['padding'] as EdgeInsets;
  set padding(EdgeInsets value) => this['padding'] = value;

  EdgeInsets get appendPadding => this['appendPadding'] as EdgeInsets;
  set appendPadding(EdgeInsets value) => this['appendPadding'] = value;

  bool get syncY => this['syncY'] as bool ?? false;
  set syncY(bool value) => this['syncY'] = value;

  bool get animate => this['animate'] as bool ?? false;
  set animate(bool value) => this['animate'] = value;

  Map<String, AxisCfg> get axes => this['axes'] as Map<String, AxisCfg>;
  set axes(Map<String, AxisCfg> value) => this['axes'] = value;

  CoordCfg get coord => this['coord'] as CoordCfg;
  set coord(CoordCfg value) => this['coord'] = value;

  List<Map<String, Object>> get data => this['data'] as List<Map<String, Object>>;
  set data(List<Map<String, Object>> value) => this['data'] = value;

  Map<String, DataFilter> get filters => this['filters'] as Map<String, DataFilter>;
  set filters(Map<String, DataFilter> value) => this['filters'] = value;

  List<GeomCfg> get geoms => this['geoms'] as List<GeomCfg>;
  set geoms(List<GeomCfg> value) => this['geoms'] = value;

  // TODO: interactions

  // TODO: legends

  Map<String, ScaleCfg> get scales => this['scales'] as Map<String, ScaleCfg>;
  set scales(Map<String, ScaleCfg> value) => this['scales'] = value;

  // TODO: tooltip

  // TODO: guide
}

class Chart extends StatefulWidget {
  Chart(this.cfg);

  final ChartCfg cfg;

  @override
  ChartState createState() => ChartState();
}

class ChartState extends State<Chart> with TickerProviderStateMixin {
  ChartController _controller;

  EventArena _eventArena;

  @override
  void initState() {
    super.initState();

    _controller = ChartController(widget.cfg);
    _controller.renderer.mount(
      () { setState(() {}); },
      this,
      _eventArena,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: CustomPaint(
        painter: _controller.cfg.renderer.painter,
      ),
      onPointerDown: (e) {
        _eventArena.emit(ListenerEvent(ListenerEventType.pointerDown, e));
      },
      onPointerMove: (e) {
        _eventArena.emit(ListenerEvent(ListenerEventType.pointerMove, e));
      },
      onPointerUp: (e) {
        _eventArena.emit(ListenerEvent(ListenerEventType.pointerUp, e));
      },
      onPointerCancel: (e) {
        _eventArena.emit(ListenerEvent(ListenerEventType.pointerCancel, e));
      },
      onPointerSignal: (e) {
        _eventArena.emit(ListenerEvent(ListenerEventType.pointerSignal, e));
      },
    );
  }
}
