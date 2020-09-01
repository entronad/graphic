import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'cartesian.dart';
import 'polar.dart';

enum CoordType {
  cartesian,
  polar,
}

abstract class Coord extends Props<CoordType> {}

abstract class CoordState with TypedMap {
  Rect get region => this['region'] as Rect;
  set region(Rect value) => this['region'] = value;

  bool get transposed => this['transposed'] as bool ?? false;
  set transposed(bool value) => this['transposed'] = value;
}

abstract class CoordComponent<S extends CoordState>
  extends Component<S>
{
  static CoordComponent create(Coord props) {
    switch (props.type) {
      case CoordType.cartesian:
        return CartesianCoordComponent(props);
      case CoordType.polar:
        return PolarCoordComponent(props);
      default: return null;
    }
  }

  CoordComponent([TypedMap props]) : super(props);
  
  @protected
  List<double> get rangeX;

  @protected
  List<double> get rangeY;

  Offset convertPoint(Offset abstractPoint);

  Offset invertPoint(Offset renderPoint);

  void setRegion(Rect region) {
    state.region = region;
    onSetRegion();
  }

  @protected
  void onSetRegion() {}
}
