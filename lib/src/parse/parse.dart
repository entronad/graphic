import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/guide/guide.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/variable/variable.dart';

import 'spec.dart';

class Scope<D> {
  Map<String, Scale> scaleSpecs = {};

  List<AlgForm> forms = [];

  late GestureOp gesture;

  late SizeOp size;

  late DataOp<D> data;

  late SignalOp signal;

  late Operator<List<Original>> originals;

  late ScaleConvOp scales;

  late ScaleOp scaleds;

  List<OriginOp> origins = [];

  List<AesOp> aesesList = [];

  late CoordConvOp coord;

  List<Operator<AesGroups>> groupsList = [];

  late SelectorOp selector;

  List<SelectOp> selectsList = [];
}

void parse<D>(Spec<D> spec, View<D> view) {
  final scope = Scope<D>();
  parseSize(spec, view, scope);
  parseGesture(spec, view, scope);
  parseData<D>(spec, view, scope);
  parseSignal<D>(spec, view, scope);
  parseCoord(spec, view, scope);
  parseVariable<D>(spec, view, scope);
  parseScale(spec, view, scope);
  parseAes(spec, view, scope);
  parseGeom(spec, view, scope);
  parseSelect(spec, view, scope);
  parseGuide(spec, view, scope);
}
