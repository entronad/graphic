import 'base.dart';

abstract class CustomShape extends Shape {
  
}

class CandlestickShape extends CustomShape {
  @override
  bool equalTo(Object other) =>
    other is CandlestickShape;
}
