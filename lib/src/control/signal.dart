import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/util/assert.dart';

import 'event.dart';

typedef EventUpdate<V, E extends Event> = V Function(V preValue, E event);

class Signal<V> extends Spec {
  Signal({
    required this.value,
    this.onEvent,
    this.bindState,
  }) : assert(isSingle([onEvent, bindState])) ;

  final V value;

  final Map<EventType, EventUpdate<V, Event>>? onEvent;

  final V Function()? bindState;
}
