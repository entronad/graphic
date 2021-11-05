import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/guide/guide.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/variable/variable.dart';

/// The context scope for [parse].
///
/// It records middle products and only exists in parsing.
class Scope<D> {
  /// Scale specifications.
  Map<String, Scale> scaleSpecs = {};

  /// Algebracal forms of all geometory elements.
  List<AlgForm> forms = [];

  /// The gesture operator.
  late GestureOp gesture;

  /// The size operator.
  late SizeOp size;

  /// The data operator.
  late DataOp<D> data;

  /// The signal operator
  late SignalOp signal;

  /// The operator providing tuples.
  ///
  /// It is the final operator of variable stage.
  late Operator<List<Tuple>> tuples;

  /// The scale converter operator.
  late ScaleConvOp scales;

  /// The scale operator.
  ///
  /// It is the final operator of scale stage.
  late ScaleOp scaleds;

  /// Origin operators of all geometory elements.
  List<OriginOp> origins = [];

  /// aesthetic operators of all geometory elements.
  ///
  /// They are the final operators of aesthetic stage.
  List<AesOp> aesesList = [];

  /// The coordinate converter operator.
  late CoordConvOp coord;

  /// Operators providing aesthetic groups of all geometory elements.
  ///
  /// They are the final operators of group stage.
  List<Operator<AesGroups>> groupsList = [];

  /// The selector operator.
  late SelectorOp selector;

  /// The select operator of all geometory elements.
  List<SelectOp> selectsList = [];
}

/// Parses the specification for a view.
void parse<D>(Chart<D> spec, View<D> view) {
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
  parseSelection(spec, view, scope);
  parseGuide(spec, view, scope);
}
