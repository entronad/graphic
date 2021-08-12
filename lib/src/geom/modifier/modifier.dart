import 'package:graphic/src/common/modifier.dart' as common;
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';

abstract class Modifier {
  @override
  bool operator ==(Object other) =>
    other is Modifier;
}

abstract class GeomModifer extends common.Modifier<List<List<Aes>>> {}

abstract class GeomModiferOp<M extends GeomModifer> extends Operator<M> {
  GeomModiferOp(Map<String, dynamic> params) : super(params);
}

/// params:
/// - groups: List<List<Aes>>
/// - modifier: GeomModifer
/// 
/// value: List<List<Aes>>, tuple groups
class ModifyOp extends Operator<List<List<Aes>>> {
  ModifyOp(Map<String, dynamic> params) : super(params);

  @override
  List<List<Aes>> evaluate() {
    final groups = params['groups'] as List<List<Aes>>;
    final modifier = params['modifier'] as GeomModifer;

    modifier.modify(groups);

    return groups;
  }
}
