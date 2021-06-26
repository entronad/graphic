import 'package:collection/collection.dart';
import 'package:graphic/src/transform/base.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/variable/base.dart';

class DataSet<D> {
  DataSet({
    this.source,
    this.from,
    required this.variables,
    this.transforms,
  }) : assert(isSingle([source, from]));

  final List<D>? source;

  final String? from;

  final Map<String, Variable<D, dynamic>> variables;

  final List<Transform>? transforms;

  @override
  bool operator ==(Object other) =>
    other is DataSet<D> &&
    // TODO: Data source change.
    from == other.from &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(transforms, other.transforms);
}

// input:
// --

// value:
// data tuple list : List<Tuple>
