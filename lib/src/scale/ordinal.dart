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
