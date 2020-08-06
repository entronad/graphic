import 'dart:ui';

import 'base.dart';

class CartesianCoord extends Coord {
  CartesianCoord({
    bool transposed,
  }) {
    this['transposed'] = transposed;
  }

  @override
  CoordType get type => CoordType.cartesian;
}

class CartesianCoordState extends CoordState {}

class CartesianCoordComponent extends CoordComponent<CartesianCoordState> {
  CartesianCoordComponent([CartesianCoord props]) : super(props);

  // Dosen't need specific state subclass.
  @override
  CartesianCoordState get originalState => CartesianCoordState();

  @override
  List<double> get rangeX => [
    state.region.left,
    state.region.right,
  ];

  @override
  List<double> get rangeY => [
    state.region.bottom,
    state.region.top,
  ];

  @override
  Offset convertPoint(Offset abstractPoint) {
    final transposed = state.transposed;
    final xDim = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final yDim = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    return Offset(
      rangeX.first + (rangeX.last - rangeX.first) * xDim(abstractPoint),
      rangeY.first + (rangeY.last - rangeY.first) * yDim(abstractPoint),
    );
  }

  @override
  Offset invertPoint(Offset renderPoint) {
    final transposed = state.transposed;
    final x = (renderPoint.dx - rangeX.first) / (rangeX.last - rangeX.first);
    final y = (renderPoint.dy - rangeY.first) / (rangeY.last - rangeY.first);
    return transposed ? Offset(y, x) : Offset(x, y);
  }
}
