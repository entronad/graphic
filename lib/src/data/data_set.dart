import 'package:collection/collection.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/event/event.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/variable/variable.dart';

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
    // Data source is not diffed in equality operator.
    from == other.from &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(transforms, other.transforms);
}

// data source -> event stream (with pulseData) -> variable operator

class DataEvent<D> extends Event {
  DataEvent(this.data);

  @override
  EventType get type => EventType.changeData;

  final List<D> data;
}

class DataSouce<D> extends EventSource<DataEvent<D>> {
  final _listeners = <EventListener<DataEvent<D>>>{};

  @override
  void on(EventType type, EventListener<DataEvent<D>> listener) {
    assert(type == EventType.changeData);
    _listeners.add(listener);
  }

  @override
  void off([EventType? type, EventListener<DataEvent<D>>? listener]) {
    assert(type == null || type == EventType.changeData);
    if (listener != null) {
      _listeners.remove(listener);
    } else {
      _listeners.clear();
    }
  }

  @override
  void emit(DataEvent<D> event) {
    for (var listener in _listeners) {
      listener(event);
    }
  }
}

class DataSourceOp<D> extends Value<List<D>> {
  DataSourceOp(List<D> value) : super(value);
}
