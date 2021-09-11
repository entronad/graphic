import 'package:graphic/graphic.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

import 'arena.dart';
import '../event.dart';

class GestureEvent extends Event {
  GestureEvent(this.gesture);

  @override
  EventType get type => EventType.gesture;

  final Gesture gesture;
}

class GestureOp extends Value<Gesture> {
  @override
  bool get consume => true;
}

void parseGesture(
  Spec spec,
  View view,
  Scope scope,
) {
  scope.gesture = view.add(GestureOp());

  view.listen<GestureEvent, Gesture>(
    view.gestureSource,
    scope.gesture,
    (event) => event.gesture,
  );
}
