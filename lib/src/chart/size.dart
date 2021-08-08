import 'dart:ui';

import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/event/event.dart';

class ResizeEvent extends Event {
  ResizeEvent(this.size);

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

class SizeOp extends Updater<Size> {
  SizeOp(Size value) : super(null, value);

  // Size value is only set by ResizeSource.
  @override
  Size update(Pulse pulse) => value!;
}
