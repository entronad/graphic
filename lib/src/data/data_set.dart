import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

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
  scope.data = view.add(DataOp(spec.data));

  view.listen<ChangeDataEvent<D>, List<D>>(
    view.dataSouce,
    scope.data,
    (event) => event.data,
  );
}
