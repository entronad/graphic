import 'package:graphic/src/base.dart' show Base;
import 'package:graphic/src/engine/event/event_emitter.dart' show EventEmitter;
import 'package:graphic/src/scale/base.dart' show Scale;

class ChartController extends Base with EventEmitter {
  Scale createScale(String field) => null;

  bool get destroyed => cfg.destroyed;

  void destroy() {
    cfg = null;
  }
}
