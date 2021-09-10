import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/geom/geom_element.dart';
import 'package:graphic/src/guide/guide.dart';
import 'package:graphic/src/interaction/gesture/gesture.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/variable/variable.dart';

import 'spec.dart';

class Scope<D> {
  Map<String, Scale> scaleSpecs = {};

  List<AlgForm> forms = [];

  GestureOp? gesture;

  SizeOp? size;

  DataOp<D>? data;

  SignalOp? signal;

  Operator<List<Original>>? originals;

  ScaleConvOp? scales;

  ScaleOp? scaleds;

  List<OriginOp> origins = [];

  List<AesOp> aesesList = [];

  CoordConvOp? coord;

  List<Operator<AesGroups>> geomsList = [];

  SelectorOp? selector;

  List<SelectOp> selectsList = [];

  List<Operator<AesGroups>> updateList = [];
}

void parse<D>(Spec<D> spec, View<D> view) {
  final scope = Scope<D>();
  parseGesture(spec, view, scope);
  parseSize(spec, view, scope);
  parseData(spec, view, scope);
  parseSignal(spec, view, scope);
  parseVariable(spec, view, scope);
  parseScale(spec, view, scope);
  parseAes(spec, view, scope);
  parseCoord(spec, view, scope);
  parseGeom(spec, view, scope);
  parseSelect(spec, view, scope);
  parseGuide(spec, view, scope);
}
