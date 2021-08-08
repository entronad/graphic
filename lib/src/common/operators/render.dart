import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/graffiti/graffiti.dart';

/// Render operator holds scene as value.
/// The scene is set in constructor an can not be reset.
/// Modify the scene by render method.
abstract class Render<S extends Scene> extends Updater<S> {
  Render(
    Map<String, dynamic> params,
    S value,
  ) : super(params, value);

  @override
  S update(Pulse pulse) {
    render(this.value!);
    return this.value!;
  }

  void render(S scene);
  
  @override
  bool set(S value) =>
    throw UnimplementedError('Do not set scene directly');
}
