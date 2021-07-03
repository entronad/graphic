import 'operator.dart';
import 'op_params.dart';
import '../pulse/pulse.dart';

abstract class Transformer<V> extends Operator<V> {
  Transformer(
    V value,
    [Map<String, dynamic>? params,]
  ) : super(value, params);

  Pulse? transform(OpParams params, Pulse pulse);

  @override
  Pulse? evaluete(Pulse pulse) {
    final params = marshall(pulse.clock);
    final rst = transform(params, pulse);
    params.clear();
    return rst;
  }
}
