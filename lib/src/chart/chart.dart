import 'package:flutter/widgets.dart' hide Axis;
import 'package:graphic/src/scale/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/geom/base.dart';

import 'component.dart';
import 'theme.dart';

class Chart<D> extends StatefulWidget {
  Chart({
    this.theme,
    this.padding,
    this.margin,
    this.data,
    this.scales,
    this.coord,
    this.axes,
    this.geoms,
  });
  final Theme theme;

  final EdgeInsets padding;

  final EdgeInsets margin;

  final List<D> data;

  final Map<String, Scale> scales;

  final Coord coord;

  final Map<String, Axis> axes;

  final List<Geom> geoms;

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
      delegate: _ChartLayoutDelegate(_component),
      child: CustomPaint(
        painter: _component.state.renderer.painter,
      ),
    );
  }
}

// build -> getPositionForChild -> paint

class _ChartLayoutDelegate extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate(this.component);

  final ChartComponent component;  

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) => false;
  
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    component.state.size = childSize;
    component.update();

    return super.getPositionForChild(size, childSize);
  }
}
