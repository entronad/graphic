import 'package:graphic/src/common/modifier.dart' as common;
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';

abstract class Modifier {
  @override
  bool operator ==(Object other) =>
    other is Modifier;
}

abstract class GeomModifer extends common.Modifier<List<List<Tuple>>> {}

abstract class GeomModiferOp<M extends GeomModifer> extends Updater<M> {
  GeomModiferOp(Map<String, dynamic> params) : super(params);
}

/// params:
/// - groups: List<List<Tuple>>
/// - modifier: GeomModifer
/// 
/// value: List<List<Tuple>>, tuple groups
class ModifyOp extends Updater<List<List<Tuple>>> {
  ModifyOp(Map<String, dynamic> params) : super(params);

  @override
  List<List<Tuple>> update(Pulse pulse) {
    final groups = params['groups'] as List<List<Tuple>>;
    final modifier = params['modifier'] as GeomModifer;

    modifier.modify(groups);

    return groups;
  }
}
