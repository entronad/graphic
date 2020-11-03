import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';

import '../base.dart';

abstract class Shape {
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  );
}
