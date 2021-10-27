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

class BigdataPage extends StatelessWidget {
  BigdataPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Bigdata'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: const Text(
                  'Bigdata scatter Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- 10000 points with various sizes and colors.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Scroll to see the rendering performance.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 400),
                width: 350,
                height: 300,
                child: Chart(
                  data: pointBigData,
                  variables: {
                    'x': Variable(
                      accessor: (List<num> datumn) => datumn[0],
                      scale: LinearScale(min: 0, max: 1),
                    ),
                    'y': Variable(
                      accessor: (List<num> datumn) => datumn[1],
                      scale: LinearScale(min: 0, max: 1),
                    ),
                    'size': Variable(
                      accessor: (List<num> datumn) => datumn[2],
                    ),
                    'color': Variable(
                      accessor: (List<num> datumn) => datumn[3],
                    ),
                  },
                  elements: [
                    PointElement(
                        size: SizeAttr(variable: 'size', values: [1, 4]),
                        color: ColorAttr(variable: 'color', values: [
                          const Color(0xffbae7ff),
                          const Color(0xff0050b3),
                        ]))
                  ],
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
