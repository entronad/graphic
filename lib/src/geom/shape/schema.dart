import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/custom.dart';

import '../base.dart';

// position: [star, end, max, min]
Path _candlestickElementPath(
  List<Offset> renderPosition,
  double size,
  CoordComponent coord,
) {
  assert(
    !coord.state.transposed,
    'Do not transpose candlestick chart',
  );

  final path = Path();

  final bias = size / 2;
  final x = renderPosition.first.dx;
  final ys = renderPosition.map((point) => point.dy).toList()..sort();
  final top = ys[0];
  final topEdge = ys[1];
  final bottomEdge = ys[2];
  final bottom = ys[3];
  
  path.moveTo(x, top);
  path.lineTo(x, topEdge);
  path.moveTo(x, bottomEdge);
  path.lineTo(x, bottom);

  path.addRect(Rect.fromPoints(
    Offset(x - bias, topEdge),
    Offset(x + bias, bottomEdge),
  ));

  return path;
}

// position: [min, q1, q2, q3, max]
Path _boxElementPath(
  List<Offset> renderPosition,
  double size,
  CoordComponent coord,
) {
  final path = Path();

  final bias = size / 2;
  if (coord.state.transposed) {
    // lines
    path.moveTo(
      renderPosition[0].dx,
      renderPosition[0].dy - bias,
    );
    path.lineTo(
      renderPosition[0].dx,
      renderPosition[0].dy + bias,
    );
    path.moveTo(
      renderPosition[1].dx,
      renderPosition[1].dy - bias,
    );
    path.lineTo(
      renderPosition[1].dx,
      renderPosition[1].dy + bias,
    );
    path.moveTo(
      renderPosition[2].dx,
      renderPosition[2].dy - bias,
    );
    path.lineTo(
      renderPosition[2].dx,
      renderPosition[2].dy + bias,
    );
    path.moveTo(
      renderPosition[3].dx,
      renderPosition[3].dy - bias,
    );
    path.lineTo(
      renderPosition[3].dx,
      renderPosition[3].dy + bias,
    );
    path.moveTo(
      renderPosition[4].dx,
      renderPosition[4].dy - bias,
    );
    path.lineTo(
      renderPosition[4].dx,
      renderPosition[4].dy + bias,
    );

    // axes
    path.moveTo(
      renderPosition[0].dx,
      renderPosition[0].dy,
    );
    path.lineTo(
      renderPosition[1].dx,
      renderPosition[1].dy,
    );
    path.moveTo(
      renderPosition[3].dx,
      renderPosition[3].dy,
    );
    path.lineTo(
      renderPosition[4].dx,
      renderPosition[4].dy,
    );

    // edges
    path.moveTo(
      renderPosition[1].dx,
      renderPosition[1].dy - bias,
    );
    path.lineTo(
      renderPosition[3].dx,
      renderPosition[3].dy - bias,
    );
    path.moveTo(
      renderPosition[1].dx,
      renderPosition[1].dy + bias,
    );
    path.lineTo(
      renderPosition[3].dx,
      renderPosition[3].dy + bias,
    );
  } else {
    // lines
    path.moveTo(
      renderPosition[0].dx - bias,
      renderPosition[0].dy,
    );
    path.lineTo(
      renderPosition[0].dx + bias,
      renderPosition[0].dy,
    );
    path.moveTo(
      renderPosition[1].dx - bias,
      renderPosition[1].dy,
    );
    path.lineTo(
      renderPosition[1].dx + bias,
      renderPosition[1].dy,
    );
    path.moveTo(
      renderPosition[2].dx - bias,
      renderPosition[2].dy,
    );
    path.lineTo(
      renderPosition[2].dx + bias,
      renderPosition[2].dy,
    );
    path.moveTo(
      renderPosition[3].dx - bias,
      renderPosition[3].dy,
    );
    path.lineTo(
      renderPosition[3].dx + bias,
      renderPosition[3].dy,
    );
    path.moveTo(
      renderPosition[4].dx - bias,
      renderPosition[4].dy,
    );
    path.lineTo(
      renderPosition[4].dx + bias,
      renderPosition[4].dy,
    );

    // axes
    path.moveTo(
      renderPosition[0].dx,
      renderPosition[0].dy,
    );
    path.lineTo(
      renderPosition[1].dx,
      renderPosition[1].dy,
    );
    path.moveTo(
      renderPosition[3].dx,
      renderPosition[3].dy,
    );
    path.lineTo(
      renderPosition[4].dx,
      renderPosition[4].dy,
    );

    // edges
    path.moveTo(
      renderPosition[1].dx - bias,
      renderPosition[1].dy,
    );
    path.lineTo(
      renderPosition[3].dx - bias,
      renderPosition[3].dy,
    );
    path.moveTo(
      renderPosition[1].dx + bias,
      renderPosition[1].dy,
    );
    path.lineTo(
      renderPosition[3].dx + bias,
      renderPosition[3].dy,
    );
  }

  return path;
}

List<RenderShape> _cartesianSchema(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  Path Function(
    List<Offset> renderPosition,
    double size,
    CoordComponent coord,
  ) elementPath,
) {
  assert(
    coord is CartesianCoordComponent,
    'candle/box schema shapes only support cartesian coord',
  );

  final rst = <RenderShape>[];

  final sigleDefaultSize = 10.0;
  final sizeStepRatio = 0.5;
  var size = attrValueRecords[0].size;
  if (size == null) {
    if (attrValueRecords.length == 1) {
      size = sigleDefaultSize;
    } else {
      final stepRatio =
        attrValueRecords[1].position.first.dx
        - attrValueRecords[0].position.first.dx;
      size = stepRatio * coord.state.region.width * sizeStepRatio;
    }
  }

  for (var record in attrValueRecords) {
    final position = record.position;
    final color = record.color;

    final renderPosition = position.map(
      (p) => coord.convertPoint(p)
    ).toList();
    final path = elementPath(renderPosition, size, coord);

    rst.add(CustomRenderShape(
      path: path,
      style: PaintingStyle.stroke,
      strokeWidth: 1,
      color: color,
    ));
  }

  return rst;
}

List<RenderShape> candlestickSchema(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _cartesianSchema(attrValueRecords, coord, _candlestickElementPath);

List<RenderShape> boxSchema(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _cartesianSchema(attrValueRecords, coord, _boxElementPath);
