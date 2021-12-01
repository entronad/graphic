import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class DebugPage extends StatelessWidget {
  DebugPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 650,
                height: 300,
                child: Chart(
                  data: data,
                  variables: {
                    'date': Variable(
                      accessor: (Map map) => map['date'] as String,
                      scale: OrdinalScale(tickCount: 5),
                    ),
                    'points': Variable(
                      accessor: (Map map) => map['points'] as num,
                    ),
                    'name': Variable(
                      accessor: (Map map) => map['name'] as String,
                    ),
                  },
                  elements: [
                    LineElement(
                      position:
                          Varset('date') * Varset('points') / Varset('name'),
                      shape: ShapeAttr(value: BasicLineShape(smooth: true)),
                      size: SizeAttr(value: 0.5),
                      color: ColorAttr(
                        variable: 'name',
                        values: Defaults.colors10,
                        onSelection: {
                          'groupMouse': {
                            false: (color) => color.withAlpha(100)
                          },
                          'groupTouch': {
                            false: (color) => color.withAlpha(100)
                          },
                        },
                      ),
                    ),
                    PointElement(
                      color: ColorAttr(
                        variable: 'name',
                        values: Defaults.colors10,
                        onSelection: {
                          'groupMouse': {
                            false: (color) => color.withAlpha(100)
                          },
                          'groupTouch': {
                            false: (color) => color.withAlpha(100)
                          },
                        },
                      ),
                    ),
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'tooltipMouse': PointSelection(on: {
                      GestureType.hover,
                    }, devices: {
                      PointerDeviceKind.mouse
                    }),
                    'groupMouse': PointSelection(
                        on: {
                          GestureType.hover,
                        },
                        variable: 'name',
                        devices: {PointerDeviceKind.mouse}),
                    'tooltipTouch': PointSelection(on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    }, devices: {
                      PointerDeviceKind.touch
                    }),
                    'groupTouch': PointSelection(
                        on: {
                          GestureType.scaleUpdate,
                          GestureType.tapDown,
                          GestureType.longPressMoveUpdate
                        },
                        variable: 'name',
                        devices: {PointerDeviceKind.touch}),
                  },
                  tooltip: TooltipGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    followPointer: [true, true],
                    align: Alignment.topLeft,
                    element: 0,
                    variables: [
                      'date',
                      'name',
                      'points',
                    ],
                  ),
                  crosshair: CrosshairGuide(
                    selections: {'tooltipTouch', 'tooltipMouse'},
                    styles: [
                      StrokeStyle(color: const Color(0xffbfbfbf)),
                      StrokeStyle(color: const Color(0x00bfbfbf)),
                    ],
                    followPointer: [true, false],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

var data = [
  {'date': '2021-10-01', 'name': 'Liam', 'points': 1468},
  {'date': '2021-10-01', 'name': 'Oliver', 'points': 1487},
  {'date': '2021-10-01', 'name': 'Elijah', 'points': 1494},
  {'date': '2021-10-02', 'name': 'Liam', 'points': 1526},
  {'date': '2021-10-02', 'name': 'Noah', 'points': 1492},
  {'date': '2021-10-02', 'name': 'Oliver', 'points': 1470},
  {'date': '2021-10-02', 'name': 'Elijah', 'points': 1477},
  {'date': '2021-10-03', 'name': 'Liam', 'points': 1466},
  {'date': '2021-10-03', 'name': 'Noah', 'points': 1465},
  {'date': '2021-10-03', 'name': 'Oliver', 'points': 1524},
  {'date': '2021-10-03', 'name': 'Elijah', 'points': 1534},
  {'date': '2021-10-04', 'name': 'Noah', 'points': 1504},
  {'date': '2021-10-04', 'name': 'Elijah', 'points': 1524},
  {'date': '2021-10-05', 'name': 'Oliver', 'points': 1534},
  {'date': '2021-10-06', 'name': 'Noah', 'points': 1463},
  {'date': '2021-10-07', 'name': 'Liam', 'points': 1502},
  {'date': '2021-10-07', 'name': 'Noah', 'points': 1539},
  {'date': '2021-10-08', 'name': 'Liam', 'points': 1476},
  {'date': '2021-10-08', 'name': 'Noah', 'points': 1483},
  {'date': '2021-10-08', 'name': 'Oliver', 'points': 1534},
  {'date': '2021-10-08', 'name': 'Elijah', 'points': 1530},
  {'date': '2021-10-09', 'name': 'Noah', 'points': 1519},
  {'date': '2021-10-09', 'name': 'Oliver', 'points': 1497},
  {'date': '2021-10-09', 'name': 'Elijah', 'points': 1460},
  {'date': '2021-10-10', 'name': 'Liam', 'points': 1514},
  {'date': '2021-10-10', 'name': 'Noah', 'points': 1518},
  {'date': '2021-10-10', 'name': 'Oliver', 'points': 1470},
  {'date': '2021-10-10', 'name': 'Elijah', 'points': 1526},
  {'date': '2021-10-11', 'name': 'Liam', 'points': 1517},
  {'date': '2021-10-11', 'name': 'Noah', 'points': 1478},
  {'date': '2021-10-11', 'name': 'Oliver', 'points': 1468},
  {'date': '2021-10-11', 'name': 'Elijah', 'points': 1487},
  {'date': '2021-10-12', 'name': 'Liam', 'points': 1535},
  {'date': '2021-10-12', 'name': 'Noah', 'points': 1537},
  {'date': '2021-10-12', 'name': 'Oliver', 'points': 1463},
  {'date': '2021-10-12', 'name': 'Elijah', 'points': 1478},
  {'date': '2021-10-13', 'name': 'Oliver', 'points': 1524},
  {'date': '2021-10-13', 'name': 'Elijah', 'points': 1496},
  {'date': '2021-10-14', 'name': 'Liam', 'points': 1527},
  {'date': '2021-10-14', 'name': 'Oliver', 'points': 1527},
  {'date': '2021-10-14', 'name': 'Elijah', 'points': 1462},
  {'date': '2021-10-15', 'name': 'Liam', 'points': 1532},
  {'date': '2021-10-15', 'name': 'Noah', 'points': 1509},
  {'date': '2021-10-15', 'name': 'Oliver', 'points': 1540},
  {'date': '2021-10-15', 'name': 'Elijah', 'points': 1536},
  {'date': '2021-10-16', 'name': 'Liam', 'points': 1480},
  {'date': '2021-10-16', 'name': 'Elijah', 'points': 1533},
  {'date': '2021-10-17', 'name': 'Noah', 'points': 1515},
  {'date': '2021-10-17', 'name': 'Oliver', 'points': 1518},
  {'date': '2021-10-17', 'name': 'Elijah', 'points': 1515},
  {'date': '2021-10-18', 'name': 'Oliver', 'points': 1489},
  {'date': '2021-10-18', 'name': 'Elijah', 'points': 1518},
  {'date': '2021-10-19', 'name': 'Oliver', 'points': 1472},
  {'date': '2021-10-19', 'name': 'Elijah', 'points': 1473},
  {'date': '2021-10-20', 'name': 'Liam', 'points': 1513},
  {'date': '2021-10-20', 'name': 'Noah', 'points': 1533},
  {'date': '2021-10-20', 'name': 'Oliver', 'points': 1487},
  {'date': '2021-10-20', 'name': 'Elijah', 'points': 1532},
  {'date': '2021-10-21', 'name': 'Liam', 'points': 1497},
  {'date': '2021-10-21', 'name': 'Noah', 'points': 1477},
  {'date': '2021-10-21', 'name': 'Oliver', 'points': 1516},
  {'date': '2021-10-22', 'name': 'Liam', 'points': 1466},
  {'date': '2021-10-22', 'name': 'Noah', 'points': 1476},
  {'date': '2021-10-22', 'name': 'Oliver', 'points': 1536},
  {'date': '2021-10-22', 'name': 'Elijah', 'points': 1483},
  {'date': '2021-10-23', 'name': 'Liam', 'points': 1503},
  {'date': '2021-10-23', 'name': 'Oliver', 'points': 1521},
  {'date': '2021-10-23', 'name': 'Elijah', 'points': 1529},
  {'date': '2021-10-24', 'name': 'Liam', 'points': 1460},
  {'date': '2021-10-24', 'name': 'Noah', 'points': 1532},
  {'date': '2021-10-24', 'name': 'Oliver', 'points': 1477},
  {'date': '2021-10-24', 'name': 'Elijah', 'points': 1470},
  {'date': '2021-10-25', 'name': 'Noah', 'points': 1504},
  {'date': '2021-10-25', 'name': 'Oliver', 'points': 1494},
  {'date': '2021-10-25', 'name': 'Elijah', 'points': 1528},
  {'date': '2021-10-26', 'name': 'Liam', 'points': 1517},
  {'date': '2021-10-26', 'name': 'Noah', 'points': 1503},
  {'date': '2021-10-26', 'name': 'Elijah', 'points': 1507},
  {'date': '2021-10-27', 'name': 'Liam', 'points': 1538},
  {'date': '2021-10-27', 'name': 'Noah', 'points': 1530},
  {'date': '2021-10-27', 'name': 'Oliver', 'points': 1496},
  {'date': '2021-10-27', 'name': 'Elijah', 'points': 1519},
  {'date': '2021-10-28', 'name': 'Liam', 'points': 1511},
  {'date': '2021-10-28', 'name': 'Oliver', 'points': 1500},
  {'date': '2021-10-28', 'name': 'Elijah', 'points': 1519},
  {'date': '2021-10-29', 'name': 'Noah', 'points': 1499},
  {'date': '2021-10-29', 'name': 'Oliver', 'points': 1489},
  {'date': '2021-10-30', 'name': 'Noah', 'points': 1460}
];
