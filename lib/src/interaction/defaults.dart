import 'package:graphic/src/coord/cartesian.dart';

import 'gesture_arena.dart';
import 'interaction.dart';

final xPaning = ChartInteraction(
  type: GestureType.panUpdate,
  callback: (event, chart) {
    final coord = chart.state.coord;
    assert(
      (coord is CartesianCoordComponent),
      'xPaning only support cartesian coord',
    );

    final coordWidth = coord.state.transposed ? coord.state.region.height : coord.state.region.width;
    final panOffsetX = event.pointerEvent.delta.dx;
    final panBias = panOffsetX / coordWidth;

    final xFields = chart.state.xFields;
    final scales = chart.state.scales;
    
    for (var field in xFields) {
      final scale = scales[field];
      final preRange = scale.state.range;
      final newRange = [preRange.first + panBias, preRange.last + panBias];

      // prevent over paning
      if (newRange.first > 0 || newRange.last < 1) {
        return;
      }

      scale.updateState({'range': newRange});
    }

    chart.reprocess();
  },
);

final xScaling = ChartInteraction(
  type: GestureType.scaleUpdate,
  callback: (event, chart) {
    final coord = chart.state.coord;
    assert(
      (coord is CartesianCoordComponent),
      'xScaling only support cartesian coord',
    );

    final coordWidth = coord.state.transposed ? coord.state.region.height : coord.state.region.width;
    final prePoint = event.pointerEvent.position - event.pointerEvent.delta;
    final preDistanceX = (prePoint.dx - event.scale.focalPoint.dx).abs();
    final newDistanceX = (event.pointerEvent.position.dx - event.scale.focalPoint.dx).abs();
    final distanceDeltaX = (newDistanceX - preDistanceX) / coordWidth;
    final focalX = chart.state.coord.invertPoint(event.scale.focalPoint).dx;

    final xFields = chart.state.xFields;
    final scales = chart.state.scales;
    
    for (var field in xFields) {
      final scale = scales[field];
      final preRange = scale.state.range;

      final partLeft = distanceDeltaX * (focalX - preRange.first) / (preRange.last - preRange.first);
      final partRight = distanceDeltaX * (preRange.last - focalX) / (preRange.last - preRange.first);

      final newRange = [preRange.first - partLeft, preRange.last + partRight];

      // prevent over scaling
      if (newRange.first > 0) {
        newRange.first = 0;
      }
      if (newRange.last < 1) {
        newRange.last = 1;
      }

      scale.updateState({'range': newRange});
    }

    chart.reprocess();
  },
);
