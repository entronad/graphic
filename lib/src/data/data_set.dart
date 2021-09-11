import 'package:collection/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/variable/variable.dart';

class DataSet<D> {
  DataSet({
    required this.source,
    required this.variables,
    this.transforms,
    this.changeData,
  });

  final List<D> source;

  final Map<String, Variable<D, dynamic>> variables;

  final List<Transform>? transforms;

  final bool? changeData;

  @override
  bool operator ==(Object other) =>
    other is DataSet<D> &&
    // Data source is not diffed in equality operator.
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(transforms, other.transforms) &&
    changeData == other.changeData;
}

bool dataChanged(DataSet a, DataSet b) {
  assert(a == b);

  return (a.changeData != false) && (a.source != b.source);
}

class ChangeDataEvent<D> extends Event {
  ChangeDataEvent(this.data);

  @override
  EventType get type => EventType.changeData;

  final List<D> data;
}

class DataOp<D> extends Value<List<D>> {
  DataOp(List<D> value) : super(value);
}

void parseData<D>(
  Spec<D> spec,
  View<D> view,
  Scope<D> scope,
) {
  final data = spec.data.source;

  scope.data = view.add(DataOp(data));

  view.listen<ChangeDataEvent<D>, List<D>>(
    view.dataSouce,
    scope.data,
    (event) => event.data,
  );
}
