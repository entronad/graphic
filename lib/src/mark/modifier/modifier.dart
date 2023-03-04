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
abstract class Modifier extends CustomizableSpec {
  /// Modifies the position of mark items.
  ///
  /// The aesthetic encodes are in the [groups].
  void modify(
    AesGroups groups,
    Map<String, ScaleConv> scales,
    AlgForm form,
    CoordConv coord,
    Offset origin,
  );
}

/// The operator to modify aeses with a modifier.
class ModifyOp extends Operator<AesGroups> {
  ModifyOp(Map<String, dynamic> params) : super(params);

  @override
  AesGroups evaluate() {
    final modifier = params['modifier'] as Modifier;
    final groups = params['groups'] as AesGroups;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final form = params['form'] as AlgForm;
    final coord = params['coord'] as CoordConv;
    final origin = params['origin'] as Offset;

    modifier.modify(groups, scales, form, coord, origin);

    return groups;
  }
}
