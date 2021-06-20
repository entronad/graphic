import 'function.dart';

abstract class IntervalShape extends FunctionShape {
  
}

class BarShape extends IntervalShape {
  @override
  bool equalTo(Object other) =>
    other is BarShape;
}

class HistogramShape extends IntervalShape {
  @override
  bool equalTo(Object other) =>
    other is HistogramShape;
}

class PyramidShape extends IntervalShape {
  @override
  bool equalTo(Object other) =>
    other is PyramidShape;
}
