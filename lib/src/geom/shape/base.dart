import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';

import '../base.dart';

typedef Shape = List<RenderShape> Function(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
);
