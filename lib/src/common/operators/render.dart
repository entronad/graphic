import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/graffiti/scene.dart';

/// The operator to render [Figure]s to a [Scene].
///
/// Render operators are sink nodes of the dataflow. It has no value, and the rendering
/// is a side effect. The [scene] is set in constructor and unchangable.
abstract class Render<S extends Scene> extends Operator {
  Render(
    Map<String, dynamic> params,
    this.scene,
    this.view,
  ) : super(params);

  /// The scene to render.
  final S scene;

  /// The view.
  ///
  /// It is imported to mark [View.dirty].
  final View view;

  @override
  evaluate() {
    // Render operators don't evalute values, they render the scene and mark view
    // dirty.

    render();
    view.dirty = true;
  }

  /// Renders the [scene].
  void render();
}
