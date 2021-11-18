import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

class PolarIntervalPage extends StatelessWidget {
  PolarIntervalPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Polar Interval Element'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: const Text(
                  'Pie Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  transforms: [
                    Proportion(
                      variable: 'sold',
                      as: 'percent',
                    )
                  ],
                  elements: [
                    IntervalElement(
                      position: Varset('percent') / Varset('genre'),
                      label: LabelAttr(
                          encoder: (tuple) => Label(
                                tuple['sold'].toString(),
                                LabelStyle(Defaults.runeStyle),
                              )),
                      color: ColorAttr(
                          variable: 'genre', values: Defaults.colors10),
                      modifiers: [StackModifier()],
                    )
                  ],
                  coord: PolarCoord(transposed: true, dimCount: 1),
                ),
              ),
              Container(
                child: const Text(
                  'Rose Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- With corner radius and shadow elevation.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: roseData,
                  variables: {
                    'name': Variable(
                      accessor: (Map map) => map['name'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                      scale: LinearScale(min: 0, marginMax: 0.1),
                    ),
                  },
                  elements: [
                    IntervalElement(
                      label: LabelAttr(
                          encoder: (tuple) => Label(tuple['name'].toString())),
                      shape: ShapeAttr(
                          value: RectShape(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      )),
                      color: ColorAttr(
                          variable: 'name', values: Defaults.colors10),
                      elevation: ElevationAttr(value: 5),
                    )
                  ],
                  coord: PolarCoord(startRadius: 0.15),
                ),
              ),
              Container(
                child: const Text(
                  'Stacked Rose Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- A multiple variabes tooltip anchord top-left.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: adjustData,
                  variables: {
                    'index': Variable(
                      accessor: (Map map) => map['index'].toString(),
                    ),
                    'type': Variable(
                      accessor: (Map map) => map['type'] as String,
                    ),
                    'value': Variable(
                      accessor: (Map map) => map['value'] as num,
                      scale: LinearScale(min: 0, max: 1800),
                    ),
                  },
                  elements: [
                    IntervalElement(
                      position: Varset('index') * Varset('value') / Varset('type'),
                      color: ColorAttr(
                          variable: 'type', values: Defaults.colors10),
                      modifiers: [StackModifier()],
                    )
                  ],
                  coord: PolarCoord(),
                  axes: [
                    Defaults.circularAxis,
                    Defaults.radialAxis..label = null,
                  ],
                  selections: {
                    'tap': PointSelection(
                      variable: 'index',
                    )
                  },
                  tooltip: TooltipGuide(
                    multiTuples: true,
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                child: const Text(
                  'Race Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  elements: [
                    IntervalElement(
                      label: LabelAttr(
                          encoder: (tuple) => Label(tuple['sold'].toString())),
                      color: ColorAttr(
                        variable: 'genre',
                        values: Defaults.colors10,
                      ),
                    )
                  ],
                  coord: PolarCoord(transposed: true),
                  axes: [
                    Defaults.radialAxis..label = null,
                    Defaults.circularAxis,
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
