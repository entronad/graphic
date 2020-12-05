import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

// Custom TriangleShape
class TriangleShape extends graphic.IntervalShape {
  @override
  List<graphic.RenderShape> getRenderShape(
    List<graphic.ElementRecord> records,
    graphic.CoordComponent coord,
    Offset origin
  ) {
    // You can only implement shape function for your used coord
  assert(coord is graphic.CartesianCoordComponent && coord.state.transposed == false);

  final rst = <graphic.RenderShape>[];

  final sizeStepRatio = 0.5;
  var size = records.first.size;
  if (size == null) {
    size = records.first.position.first.dx * 2 * sizeStepRatio * coord.state.region.width;
  }

  for (var i = 0; i < records.length; i++) {
    final record = records[i];
    final startPoint = record.position.first;
    final endPoint = record.position.last;
    
    final top = coord.convertPoint(endPoint);
    final bottom = coord.convertPoint(startPoint);
    final bottomLeft = Offset(bottom.dx - size / 2, bottom.dy);
    final bottomRight = Offset(bottom.dx + size / 2, bottom.dy);
    final color = record.color;

    rst.add(graphic.PolygonRenderShape(
      points: [top, bottomLeft, bottomRight],
      color: color,
    ));
  }

  return rst;
  }
}

// Custom CandlestickShape
// position: [star, end, max, min]
// green if end >= start
// red if end < start
class CandlestickShape extends graphic.SchemaShape {
  @override
  List<graphic.RenderShape> getRenderShape(
    List<graphic.ElementRecord> records,
    graphic.CoordComponent coord,
    Offset origin
  ) {
    final rst = <graphic.RenderShape>[];

    final sigleDefaultSize = 10.0;
    final sizeStepRatio = 0.5;
    var size = records[0].size;
    if (size == null) {
      if (records.length == 1) {
        size = sigleDefaultSize;
      } else {
        final stepRatio =
          records[1].position.first.dx
          - records[0].position.first.dx;
        size = stepRatio * coord.state.region.width * sizeStepRatio;
      }
    }

    for (var record in records) {
      final position = record.position;
      final color = position[1] >= position[0] ? Colors.green : Colors.red;

      final renderPosition = position.map(
        (p) => coord.convertPoint(p)
      ).toList();
      
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

      rst.add(graphic.CustomRenderShape(
        path: path,
        style: PaintingStyle.stroke,
        strokeWidth: 1,
        color: color,
      ));
    }

    return rst;
  }
}

class CustomShapePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Custom Shape Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: Text('Custom Triangle Interval', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: basicData,
                  scales: {
                    'genre': graphic.CatScale(
                      accessor: (map) => map['genre'] as String,
                    ),
                    'sold': graphic.LinearScale(
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [TriangleShape()]),
                  )],
                  axes: {
                    'genre': graphic.Defaults.horizontalAxis,
                    'sold': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('Custom Candlestick Schema', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: stockData.reversed.toList(),
                  scales: {
                    'time': graphic.CatScale(
                      tickCount: 5,
                      accessor: (map) => map['time'],
                    ),
                    'start': graphic.LinearScale(
                      min: 6,
                      max: 9,
                      accessor: (map) => map['start'],
                    ),
                    'max': graphic.LinearScale(
                      min: 6,
                      max: 9,
                      accessor: (map) => map['max'],
                    ),
                    'min': graphic.LinearScale(
                      min: 6,
                      max: 9,
                      accessor: (map) => map['min'],
                    ),
                    'end': graphic.LinearScale(
                      min: 6,
                      max: 9,
                      accessor: (map) => map['end'],
                    ),
                  },
                  geoms: [graphic.SchemaGeom(
                    position: graphic.PositionAttr(field: 'time*start*end*max*min'),
                    shape: graphic.ShapeAttr(values: [CandlestickShape()]),
                  )],
                  axes: {
                    'time': graphic.Defaults.horizontalAxis,
                    'start': graphic.Defaults.verticalAxis,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
