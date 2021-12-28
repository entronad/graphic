import 'package:graphic/src/chart/view.dart';
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

/// The annotation scene.
abstract class AnnotScene extends Scene {
  AnnotScene(int layer) : super(layer);
}

/// The annotation render operator.
abstract class AnnotRenderOp<S extends AnnotScene> extends Render<S> {
  AnnotRenderOp(
    Map<String, dynamic> params,
    S scene,
    View view,
  ) : super(params, scene, view);
}
