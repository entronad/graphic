import 'package:flutter/widgets.dart' hide Axis;
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/geom/base.dart';
import 'package:graphic/src/interaction/gesture_arena.dart';
import 'package:graphic/src/interaction/interaction.dart';

import 'component.dart';
import 'theme.dart';

class Chart<D> extends StatefulWidget {
  Chart({
    Theme theme,
    EdgeInsets padding,
    EdgeInsets margin,
    List<D> data,
    Map<String, Scale> scales,
    Coord coord,
    Map<String, Axis> axes,
    List<Geom> geoms,
    List<ChartInteraction> interactions,
  }) : props = ChartProps<D>()
    ..theme = theme
    ..padding = padding
    ..margin = margin
    ..data = data
    ..scales = scales
    ..coord = coord
    ..axes = axes
    ..geoms = geoms
    ..interactions = interactions;

  final ChartProps<D> props;

  @override
  ChartContainer<D> createState() => ChartContainer<D>();
}

class ChartContainer<D> extends State<Chart<D>> {
  ChartComponent _component;

  void rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _component = ChartComponent(this);
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ChartLayoutDelegate(_component, widget.props),
      child: Listener(
        child: CustomPaint(
          painter: _ChartPainter(_component),
        ),
        onPointerDown: (e) {
          _component.gestureArena
            .emit(ListenerEvent(ListenerEventType.pointerDown, e));
        },
        onPointerMove: (e) {
          _component.gestureArena
            .emit(ListenerEvent(ListenerEventType.pointerMove, e));
        },
        onPointerUp: (e) {
          _component.gestureArena
            .emit(ListenerEvent(ListenerEventType.pointerUp, e));
        },
        onPointerCancel: (e) {
          _component.gestureArena
            .emit(ListenerEvent(ListenerEventType.pointerCancel, e));
        },
        onPointerSignal: (e) {
          _component.gestureArena
            .emit(ListenerEvent(ListenerEventType.pointerSignal, e));
        },
      ),
    );
  }
}

// build -> getPositionForChild -> paint

class _ChartLayoutDelegate extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate(this.component, this.props);

  final ChartComponent component;

  final ChartProps props;

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) => false;
  
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    props.size = childSize;
    component.initProps(props);

    return super.getPositionForChild(size, childSize);
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.component);

  final ChartComponent component;

  @override
  void paint(Canvas canvas, Size size) {
    component.state.renderer.paint(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
    this != oldDelegate;
}
