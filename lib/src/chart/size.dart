import 'dart:ui';

import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/event.dart';

class ResizeEvent extends Event {
  ResizeEvent(this.size);

  @override
  EventType get type => EventType.resize;

  final Size size;
}

class ResizeSouce extends EventSource<ResizeEvent> {
  final _listeners = <EventListener<ResizeEvent>>{};

  @override
  void on(EventType type, EventListener<ResizeEvent> listener) {
    assert(type == EventType.resize);
    _listeners.add(listener);
  }

  @override
  void off([EventType? type, EventListener<ResizeEvent>? listener]) {
    assert(type == null || type == EventType.resize);
    if (listener != null) {
      _listeners.remove(listener);
    } else {
      _listeners.clear();
    }
  }

  @override
  void emit(ResizeEvent event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }
}

class SizeOp extends Value<Size> {
  SizeOp(Size value) : super(value);
}
