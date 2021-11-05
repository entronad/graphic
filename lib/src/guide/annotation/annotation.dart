import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/graffiti/scene.dart';

/// The specification of an annotation.
abstract class Annotation {
  /// Creates an annotation.
  Annotation({
    this.zIndex,
  });

  /// The z index of this annotation.
  ///
  /// If null, a default 0 is set.
  int? zIndex;

  @override
  bool operator ==(Object other) =>
      other is Annotation && zIndex == other.zIndex;
}

/// The annotation scene.
abstract class AnnotScene extends Scene {
  AnnotScene(int zIndex) : super(zIndex);
}

/// The annotation render operator.
abstract class AnnotRenderOp<S extends AnnotScene> extends Render<S> {
  AnnotRenderOp(
    Map<String, dynamic> params,
    S scene,
    View view,
  ) : super(params, scene, view);
}
