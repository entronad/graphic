var _tupleId = 1;

typedef TuplePredicate = bool Function(Tuple);

typedef TupleVisitor = void Function(Tuple);

// Mainly used in Pulse.
// Null means falsy.
typedef TupleFilter = Tuple? Function(Tuple);

// TODO: Tuple equality.
class Tuple {
  Tuple(this._payload)
    : _id = _tupleId++;

  final int _id;
  final Map<String, dynamic> _payload;

  int get id => _id;

  dynamic operator [](String key) =>
    _payload[key];

  void operator []=(String key, dynamic value) =>
    _payload[key] = value;
}
