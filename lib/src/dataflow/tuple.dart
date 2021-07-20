typedef Tuple = Map<String, dynamic>;

typedef TuplePredicate = bool Function(Tuple);

typedef TupleVisitor = void Function(Tuple);

// Mainly used in Pulse.
// Null means falsy.
typedef TupleFilter = Tuple? Function(Tuple);
