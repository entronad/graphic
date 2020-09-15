import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

// Custom shape function
List<graphic.RenderShape> triangleInterval(
  List<graphic.AttrValueRecord> attrValueRecords,
  graphic.CoordComponent coord,
  Offset origin,
) {
  // You can only implement shape function for your used coord
  assert(coord is graphic.CartesianCoordComponent && coord.state.transposed == false);

  final rst = <graphic.RenderShape>[];

  final sizeStepRatio = 0.5;
  var size = attrValueRecords.first.size;
  if (size == null) {
    size = attrValueRecords.first.position.first.dx * 2 * sizeStepRatio * coord.state.region.width;
  }

  final originY = origin.dy;

  for (var i = 0; i < attrValueRecords.length; i++) {
    final record = attrValueRecords[i];
    final point = record.position.first;
    
    final top = coord.convertPoint(point);
    final bottom = coord.convertPoint(Offset(point.dx, originY));
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
                    'sold': graphic.NumScale(
                      accessor: (map) => map['sold'] as num,
                      nice: true,
                    )
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'genre*sold'),
                    shape: graphic.ShapeAttr(values: [triangleInterval]),
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
