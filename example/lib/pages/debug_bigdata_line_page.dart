import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

List<List<num>> getLineBigData(int n) {
  final rdm = Random();

  final rst = <List<num>>[];
  var current = 0.0; 
  for (var i = 0; i < n; i++) {
    current = current + rdm.nextDouble() - 0.5;
    rst.add([
      i,
      current,
    ]);
  }

  return rst;
}

final lineBigData = getLineBigData(10000);

class DebugBigdataLinePage extends StatelessWidget {
  DebugBigdataLinePage({Key? key}) : super(key: key);

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
                  data: lineBigData,
                  variables: {
                    'domain': Variable(
                      accessor: (List<num> datumn) => datumn.first,
                    ),
                    'measure': Variable(
                      accessor: (List<num> datumn) => datumn.last,
                    ),
                  },
                  elements: [
                    AreaElement(
                      shape: ShapeAttr(value: BasicAreaShape(smooth: true)),
                      color: ColorAttr(value: Defaults.colors10.first.withAlpha(80)),
                    ),
                    LineElement(
                      shape: ShapeAttr(value: BasicLineShape(smooth: true)),
                      size: SizeAttr(value: 0.5),
                    ),
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
