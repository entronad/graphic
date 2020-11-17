import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'big_data.dart';

class BigDataPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Big Data Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: Text('10,000 Items Line and Area', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: lineBigData,
                  scales: {
                    'domain': graphic.LinearScale(
                      accessor: (list) => list.first,
                    ),
                    'measure': graphic.LinearScale(
                      accessor: (list) => list.last,
                    )
                  },
                  geoms: [
                    graphic.AreaGeom(
                      position: graphic.PositionAttr(field: 'domain*measure'),
                      shape: graphic.ShapeAttr(values: [graphic.BasicAreaShape()]),
                      color: graphic.ColorAttr(values: [
                        graphic.Defaults.theme.colors.first.withAlpha(80),
                      ]),
                    ),
                    graphic.LineGeom(
                      position: graphic.PositionAttr(field: 'domain*measure'),
                      shape: graphic.ShapeAttr(values: [graphic.BasicLineShape(smooth: true)]),
                      size: graphic.SizeAttr(values: [0.5]),
                    ),
                  ],
                  axes: {
                    'domain': graphic.Defaults.horizontalAxis,
                    'measure': graphic.Defaults.verticalAxis,
                  },
                ),
              ),

              Padding(
                child: Text('1,000 Points', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: pointBigData,
                  scales: {
                    'x': graphic.LinearScale(
                      accessor: (list) => list[0],
                    ),
                    'y': graphic.LinearScale(
                      accessor: (list) => list[1],
                    ),
                    'size': graphic.LinearScale(
                      accessor: (list) => list[2],
                    ),
                    'color': graphic.LinearScale(
                      accessor: (list) => list[3],
                    ),
                  },
                  geoms: [graphic.PointGeom(
                    position: graphic.PositionAttr(field: 'x*y'),
                    size: graphic.SizeAttr(field: 'size', values: [1, 4]),
                    color: graphic.ColorAttr(
                      field: 'color',
                      values: [Color(0xffbae7ff), Color(0xff0050b3)],
                      isTween: true,
                    ),
                  )],
                  axes: {
                    'x': graphic.Defaults.horizontalAxis,
                    'y': graphic.Defaults.verticalAxis,
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
