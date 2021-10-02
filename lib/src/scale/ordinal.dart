import 'package:graphic/src/dataflow/tuple.dart';

import 'discrete.dart';

class OrdinalScale extends DiscreteScale<String> {
  OrdinalScale({
    List<String>? values,
    double? align,

    String? title,
    String Function(String)? formatter,
    List<String>? ticks,
    int? tickCount,
    int? maxTickCount,
  }) : super(
    values: values,
    align: align,
    title: title,
    formatter: formatter,
    ticks: ticks,
    tickCount: tickCount,
    maxTickCount: maxTickCount,
  );
}

class OrdinalScaleConv extends DiscreteScaleConv<String, OrdinalScale> {
  OrdinalScaleConv(
    OrdinalScale spec,
    List<Original> tuples,
    String variable,
  ) : super(spec, tuples, variable);

  @override
  String defaultFormatter(String value) => value;

  @override
  bool operator ==(Object other) =>
    other is OrdinalScaleConv &&
    super == other;
}
