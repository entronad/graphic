import 'package:graphic/src/common/modifier.dart' as common;
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';

abstract class Modifier {
  @override
  bool operator ==(Object other) =>
    other is Modifier;
}

abstract class GeomModifier extends common.Modifier<AesGroups> {}

abstract class GeomModifierOp<M extends GeomModifier> extends Operator<M> {
  GeomModifierOp(Map<String, dynamic> params) : super(params);
}

/// params:
/// - groups: AesGroups
/// - modifier: GeomModifer
/// 
/// value: AesGroups, tuple groups
class ModifyOp extends Operator<AesGroups> {
  ModifyOp(Map<String, dynamic> params) : super(params);

  @override
  AesGroups evaluate() {
    final groups = params['groups'] as AesGroups;
    final modifier = params['modifier'] as GeomModifier;

    modifier.modify(groups);

    return groups;
  }
}
