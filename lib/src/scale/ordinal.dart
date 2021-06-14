import 'discrete.dart';

class OrdinalScale extends DiscreteScale<String> {
  OrdinalScale({
    List<String>? values,

    String Function(String)? formatter,
  }) : super(
    values: values,
    formatter: formatter,
  );
}
