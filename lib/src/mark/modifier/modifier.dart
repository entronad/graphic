import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/common/customizable_spec.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/shape/shape.dart';

/// The specification of a collision modifier.
///
/// A collision modifier defines a method to modify the position of mark items,
/// avoiding visual overlapping.
///
/// Modifiers could be customized by extending this class. Although all aesthetic
/// encodes can be modified in a modifier, only the position is recommended.
/// Rendering customization should be in the [Shape].
/// 
/// Note that the modifier should be functional, which means to return a new groups
/// list as result, not to change the input groups.
abstract class Modifier extends CustomizableSpec {
  /// Modifies the position of mark items.
  ///
  /// The aesthetic encodes are in the [groups].
  /// 
  /// Note that the modifier should be functional, which means to return a new groups
  /// list as result, not to change the input groups.
  AttributesGroups modify(
    AttributesGroups groups,
    Map<String, ScaleConv> scales,
    AlgForm form,
    CoordConv coord,
    Offset origin,
  );
}

/// The operator to modify attributes with a modifier.
class ModifyOp extends Operator<AttributesGroups> {
  ModifyOp(Map<String, dynamic> params) : super(params);

  @override
  AttributesGroups evaluate() {
    final modifier = params['modifier'] as Modifier;
    final groups = params['groups'] as AttributesGroups;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final form = params['form'] as AlgForm;
    final coord = params['coord'] as CoordConv;
    final origin = params['origin'] as Offset;

    return modifier.modify(groups, scales, form, coord, origin);
  }
}
