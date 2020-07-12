import 'dart:ui';

import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'base.dart';

class CartesianCoord extends Props<CoordType> {
  CartesianCoord({
    bool transposed,
  }) {
    this['transposed'] = transposed;
  }

  @override
  CoordType get type => CoordType.cartesian;
}

// No additional states, so just use CoordState
class CartesianCoordComponent extends CoordComponent<CoordState> {
  CartesianCoordComponent(TypedMap props) : super(props);

  // Dosen't need specific state subclass.
  @override
  CoordState get originalState => CoordState();

  @override
  List<double> get rangeX => [
    state.plot.left,
    state.plot.right,
  ];

  @override
  List<double> get rangeY => [
    state.plot.bottom,
    state.plot.top,
  ];

  @override
  Offset convertPoint(Offset point) {
    final transposed = state.transposed;
    final xDim = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final yDim = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    return Offset(
      rangeX.first + (rangeX.last - rangeX.first) * xDim(point),
      rangeY.first + (rangeY.last - rangeY.first) * yDim(point),
    );
  }

  @override
  Offset invertPoint(Offset point) {
    final transposed = state.transposed;
    final x = (point.dx - rangeX.first) / (rangeX.last - rangeX.first);
    final y = (point.dy - rangeY.first) / (rangeY.last - rangeY.first);
    return transposed ? Offset(y, x) : Offset(x, y);
  }
}
