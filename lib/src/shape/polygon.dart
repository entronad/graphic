import 'partition.dart';

abstract class PolygonShape extends PartitionShape {
  
}

class HeatmapShape extends PolygonShape {
  @override
  bool equalTo(Object other) =>
    other is HeatmapShape;
}

class VoronoiShape extends PolygonShape {
  @override
  bool equalTo(Object other) =>
    other is VoronoiShape;
}
