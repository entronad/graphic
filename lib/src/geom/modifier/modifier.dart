import 'package:graphic/src/common/modifier.dart' as common;
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';

/// The specification of a collision modifier.
///
/// A collision modifier defines a method to modify the position of element items,
/// avoiding visual overlapping.
abstract class Modifier {
  @override
  bool operator ==(Object other) => other is Modifier;
}

/// The base class of geometry modifiers.
///
/// A geometry modifier executes a corresponding [Modifier].
abstract class GeomModifier extends common.Modifier<AesGroups> {}

/// The operator to create a geometry modifier.
abstract class GeomModifierOp<M extends GeomModifier> extends Operator<M> {
  GeomModifierOp(Map<String, dynamic> params) : super(params);
}

/// The operator to modify aeses with a geometry modifier.
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
