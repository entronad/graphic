import 'dart:async';

import '../event_stream.dart';

EventReceive debounce(Duration delay, EventReceive receive) {
  Timer? timer;

  return (e) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(delay, () {
      receive(e);
      timer = null;
    });
  };
}
