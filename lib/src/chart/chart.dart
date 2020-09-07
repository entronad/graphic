import 'package:flutter/widgets.dart' hide Axis;
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/geom/base.dart';

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
  }) : props = ChartProps<D>()
    ..theme = theme
    ..padding = padding
    ..margin = margin
    ..data = data
    ..scales = scales
    ..coord = coord
    ..axes = axes
    ..geoms = geoms;

  final ChartProps<D> props;

  @override
  _ChartState<D> createState() => _ChartState<D>();
}

class _ChartState<D> extends State<Chart<D>> {
  ChartComponent _component;

  @override
  void initState() {
    super.initState();

    _component = ChartComponent();

    _component.state.renderer.mount(
      () { setState(() {}); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ChartLayoutDelegate(_component, widget.props),
      child: CustomPaint(
        painter: _component.state.renderer.painter,
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
    component.setProps(props);

    return super.getPositionForChild(size, childSize);
  }
}
