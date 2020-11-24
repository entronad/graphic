import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

import 'data.dart';

class InteractionPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Interactions'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                child: Text('xPaning and xScaling', style: TextStyle(fontSize: 20)),
                padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              ),
              Container(
                width: 350,
                height: 300,
                child: graphic.Chart(
                  data: lineData,
                  scales: {
                    'Date': graphic.CatScale(
                      accessor: (map) => map['Date'] as String,
                      range: [0, 2],
                      tickCount: 5,
                    ),
                    'Close': graphic.LinearScale(
                      accessor: (map) => map['Close'] as num,
                      nice: true,
                      min: 100,
                    )
                  },
                  geoms: [
                    graphic.AreaGeom(
                      position: graphic.PositionAttr(field: 'Date*Close'),
                      shape: graphic.ShapeAttr(values: [graphic.BasicAreaShape(smooth: true)]),
                      color: graphic.ColorAttr(values: [
                        graphic.Defaults.theme.colors.first.withAlpha(80),
                      ]),
                    ),
                    graphic.LineGeom(
                      position: graphic.PositionAttr(field: 'Date*Close'),
                      shape: graphic.ShapeAttr(values: [graphic.BasicLineShape(smooth: true)]),
                      size: graphic.SizeAttr(values: [0.5]),
                    ),
                  ],
                  axes: {
                    'Date': graphic.Defaults.horizontalAxis,
                    'Close': graphic.Defaults.verticalAxis,
                  },
                  interactions: [
                    graphic.Defaults.xPaning,
                    graphic.Defaults.xScaling,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
