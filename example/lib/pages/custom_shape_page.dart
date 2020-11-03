import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

// Custom shape
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
                child: Text('Custom Tiangle Interval', style: TextStyle(fontSize: 20)),
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
            ],
          ),
        ),
      ),
    );
  }
}
