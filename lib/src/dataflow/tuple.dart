var _tupleId = 1;

typedef Predicate<D> = bool Function(Tuple<D>);

class Tuple<D> {
  Tuple(this.datum)
    : _id = _tupleId ++;

  int _id;
  D datum;

  int get id => _id;

  Tuple<D> derive() => Tuple(datum);
}

Tuple<D> replaceTuple<D>(Tuple<D> oldTuple, Tuple<D> newTuple) {
  newTuple._id = oldTuple._id;
  return newTuple;
}

Comparator<Tuple<D>> getTupleComparator<D>(Comparator<D> datumComparator) =>
  (a, b) {
    final datumRst = datumComparator(a.datum, b.datum);
    return datumRst == 0 ? a._id - b.id : datumRst;
  };
