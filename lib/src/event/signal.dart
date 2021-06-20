import 'event.dart';

typedef SignalUpdate<V, E extends Event> = V Function(V initialValue, V preValue, E event);

typedef Signal<V> = Map<EventType, SignalUpdate<V, Event>>;
