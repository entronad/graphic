import 'package:graphic/src/chart/chart_view.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/graffiti/scene.dart';

/// The specification of an annotation.
abstract class Annotation {
  /// Creates an annotation.
  Annotation({
    this.layer,
  });

  /// The layer of this annotation.
  ///
  /// If null, a default 0 is set.
  int? layer;

  @override
  bool operator ==(Object other) => other is Annotation && layer == other.layer;
}

/// The annotation render operator.
abstract class AnnotRenderOp extends Render {
  AnnotRenderOp(
    Map<String, dynamic> params,
    MarkScene scene,
    ChartView view,
  ) : super(params, scene, view);
}
