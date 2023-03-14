import 'dart:ui' hide Scene;

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/assert.dart';

import 'annotation.dart';

/// The Specification of a element annotation.
abstract class ElementAnnotation extends Annotation {
  /// Creates a element annotation.
  ElementAnnotation({
    this.variables,
    this.values,
    this.anchor,
    this.clip,
    int? layer,
  })  : assert(isSingle([variables, anchor], allowNone: true)),
        assert(isSingle([values, anchor])),
        super(
          layer: layer,
        );

  /// The variables in each dimension refered to for position.
  ///
  /// If null, the first variables assigned to each dimension are set by default.
  List<String>? variables;

  /// The values of [variables] for position.
  List? values;

  /// Indicates the anchor position of this annotation directly.
  ///
  /// This is a function with chart size as input that you may need to calculate
  /// the position.
  ///
  /// If set, this annotation's position will no longer determined by [variables]
  /// and [values].
  Offset Function(Size)? anchor;

  /// Whether this element annotation should be cliped within the coordinate region.
  ///
  /// If null, a default false is set.
  bool? clip;

  @override
  bool operator ==(Object other) =>
      other is ElementAnnotation &&
      super == other &&
      deepCollectionEquals(variables, other.variables) &&
      deepCollectionEquals(values, values) &&
      clip == other.clip;
}

/// The operator to create elements of a element annotation.
///
/// The elements value is nullable.
abstract class ElementAnnotOp extends Operator<List<MarkElement>?> {
  ElementAnnotOp(Map<String, dynamic> params) : super(params);
}

/// The operator to get element annotation's anchor if it is set directly.
class ElementAnnotSetAnchorOp extends Operator<Offset> {
  ElementAnnotSetAnchorOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final anchor = params['anchor'] as Offset Function(Size);
    final size = params['size'] as Size;

    return anchor(size);
  }
}

/// The operator to get element annotation's anchor if it is calculated.
class ElementAnnotCalcAnchorOp extends Operator<Offset> {
  ElementAnnotCalcAnchorOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final variables = params['variables'] as List<String>;
    final values = params['values'] as List;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    final scaleX = scales[variables[0]]!;
    final scaleY = scales[variables[1]]!;
    return coord.convert(Offset(
      scaleX.normalize(scaleX.convert(values[0])),
      scaleY.normalize(scaleY.convert(values[1])),
    ));
  }
}

/// The element annotation render operator.
class ElementAnnotRenderOp extends AnnotRenderOp {
  ElementAnnotRenderOp(
    Map<String, dynamic> params,
    Scene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final elements = params['elements'] as List<MarkElement>?;
    final clip = params['clip'] as bool;
    final coord = params['coord'] as CoordConv;

    if (clip) {
      scene.set(elements, RectElement(rect: coord.region));
    } else {
      scene.set(elements);
    }
  }
}
