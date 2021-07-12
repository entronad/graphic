var _tupleId = 1;

typedef TuplePredicate = bool Function(Tuple);

typedef TupleVisitor = void Function(Tuple);

// Mainly used in Pulse.
// Null means falsy.
typedef TupleFilter = Tuple? Function(Tuple);

// TODO: Tuple equality.
class Tuple {
  Tuple([Map<String, dynamic>? init])
    : _id = _tupleId++,
      _payload = init ?? {};

  final int _id;

  final Map<String, dynamic> _payload;

  int get id => _id;

  void clear() => _payload.clear();

  dynamic operator [](String key) =>
    _payload[key];

  void operator []=(String key, dynamic value) =>
    _payload[key] = value;
}
