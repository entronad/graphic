import 'package:collection/collection.dart';

class MapKeyEquality<E extends Map> implements Equality<E> {
  const MapKeyEquality();

  @override
  bool equals(Map? e1, Map? e2) =>
      DeepCollectionEquality().equals(e1?.keys, e2?.keys);

  @override
  int hash(Object? e) => e.hashCode;

  @override
  bool isValidKey(Object? o) => true;
}
