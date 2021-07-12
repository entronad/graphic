import 'package:graphic/src/dataflow/operator/op_params.dart';
import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';

class Collect extends Transformer<List<Tuple>> {
  Collect() : super([], {});

  @override
  Pulse? transform(OpParams params, Pulse pulse) {
    final rst = pulse.fork(PulseFlags.all);

    // Collect is to create new source, so only handles rem and add.
    rst.visit(PulseFlags.rem, value.remove);
    value.addAll(rst.materialize(PulseFlags.add).add);
    pulse.source = value;

    return rst;
  }
}
