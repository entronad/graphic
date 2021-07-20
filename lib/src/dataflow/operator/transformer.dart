import 'package:meta/meta.dart';

import 'operator.dart';
import '../pulse/pulse.dart';

/// Transformers changes pulse.
/// It does not care about value.
abstract class Transformer<V> extends Operator<V> {
  Transformer(
    [Map<String, dynamic>? params,
    V? value,]
  ) : super(params, value);

  @override
  Pulse? evaluete(Pulse pulse) {
    marshall(pulse.clock);
    final rst = transform(pulse);
    params.clear();
    return rst;
  }

  @protected
  Pulse? transform(Pulse pulse);
}
