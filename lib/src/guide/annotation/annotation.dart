import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/graffiti/graffiti.dart';

abstract class Annotation {
  Annotation({
    this.zIndex,
  });

  final int? zIndex;

  @override
  bool operator ==(Object other) =>
    other is Annotation &&
    zIndex == other.zIndex;
}

abstract class AnnotPainter extends Painter {
  
}

abstract class AnnotScene extends Scene {
  
}

abstract class AnnotRenderOp<S extends AnnotScene> extends Render<S> {
  AnnotRenderOp(
    Map<String, dynamic> params,
    S value,
  ) : super(params, value);
}
