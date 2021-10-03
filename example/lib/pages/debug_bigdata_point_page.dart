
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

List<List<num>> getPointBigData(int n) {
  final rdm = Random();

  final rst = <List<num>>[];
  for (var i = 0; i < n; i++) {
    rst.add([
      rdm.nextDouble(),
      rdm.nextDouble(),
      rdm.nextDouble(),
      rdm.nextDouble(),
    ]);
  }

  return rst;
}

final pointBigData = getPointBigData(10000);

class DebugBigdataPointPage extends StatelessWidget {
  DebugBigdataPointPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Debug Charts'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 500),
                width: 350,
                height: 300,
                child: Chart(
                  data: pointBigData,
                  variables: {
                    'x': Variable(
                      accessor: (List<num> datumn) => datumn[0],
                    ),
                    'y': Variable(
                      accessor: (List<num> datumn) => datumn[1],
                    ),
                    'size': Variable(
                      accessor: (List<num> datumn) => datumn[2],
                    ),
                    'color': Variable(
                      accessor: (List<num> datumn) => datumn[3],
                    ),
                  },
                  elements: [PointElement(
                    size: SizeAttr(variable: 'size', values: [1, 4]),
                    color: ColorAttr(variable: 'color', values: [Color(0xffbae7ff), Color(0xff0050b3)])
                  )],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
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
