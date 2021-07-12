import 'discrete.dart';

class OrdinalScale extends DiscreteScale<String> {
  OrdinalScale({
    List<String>? values,
    double? align,

    String Function(String)? formatter,
  }) : super(
    values: values,
    align: align,
    formatter: formatter,
  );
}

class OrdinalScaleConv extends DiscreteScaleConv<String> {
  OrdinalScaleConv(List<String>? values) : super(values);

  @override
  int convert(String input) {
    assert(values!.contains(input));
    return values!.indexOf(input);
  }

  @override
  String invert(int output) {
    assert(output >= 0 && output < values!.length);
    return values![output];
  }
}
