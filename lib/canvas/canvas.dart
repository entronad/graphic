import 'package:flutter/widgets.dart';

import 'renderer.dart' show Renderer;
import './event/event_arena.dart' show ListenerEvent, ListenerEventType;

class Canvas extends StatefulWidget {
  Canvas({Key key, this.renderer}) : super(key: key);

  final Renderer renderer;

  @override
  _CanvasState createState() => _CanvasState();
}

class _CanvasState extends State<Canvas> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    widget.renderer.cfg.repaintTrigger = () {setState(() {});};
    widget.renderer.cfg.tickerProvider = this;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: CustomPaint(
        painter: widget.renderer.painter,
      ),
      onPointerDown: (e) {
        widget.renderer.eventArena
          .emit(ListenerEvent(ListenerEventType.pointerDown, e));
      },
      onPointerMove: (e) {
        widget.renderer.eventArena
          .emit(ListenerEvent(ListenerEventType.pointerMove, e));
      },
      onPointerUp: (e) {
        widget.renderer.eventArena
          .emit(ListenerEvent(ListenerEventType.pointerUp, e));
      },
      onPointerCancel: (e) {
        widget.renderer.eventArena
          .emit(ListenerEvent(ListenerEventType.pointerCancel, e));
      },
      onPointerSignal: (e) {
        widget.renderer.eventArena
          .emit(ListenerEvent(ListenerEventType.pointerSignal, e));
      },
    );
  }
}
