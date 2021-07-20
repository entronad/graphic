import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';

class Sieve extends Transformer<List<Tuple>> {
  Sieve() : super({}, []);

  @override
  Pulse? transform(Pulse pulse) {
    value = pulse.source;
    return pulse.changed()
      ? pulse.fork(PulseFlags.none)
      : null;
  }
}
