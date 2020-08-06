import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/custom.dart';

import '../base.dart';

// position: [min, q1, q2, q3, max]

List<RenderShape> boxSchema(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) {
  assert(
    coord is CartesianCoordComponent,
    'box shapes only support cartesian coord',
  );

  final rst = <RenderShape>[];

  for (var record in attrValueRecords) {
    final position = record.position;
    final color = record.color;
    final size = record.size;

    final renderPosition = position.map(
      (p) => coord.convertPoint(p)
    ).toList();
    final bias = size / 2;

    final path = Path();
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

    rst.add(CustomRenderShape(
      path: path,
      style: PaintingStyle.stroke,
      strokeWidth: 1,
      color: color,
    ));
  }

  return rst;
}
