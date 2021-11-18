import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

class RectangleIntervalPage extends StatelessWidget {
  RectangleIntervalPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Rectangle Interval Element'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: const Text(
                  'Interactive Bar Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- A tooltip and crosshair on selection.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Bar colors and shadow elevations change with selection state.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Double tap to clear the selection.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                  elements: [
                    IntervalElement(
                      label: LabelAttr(
                          encoder: (tuple) => Label(tuple['sold'].toString())),
                      elevation: ElevationAttr(value: 0, onSelection: {
                        'tap': {true: (_) => 5}
                      }),
                      color:
                          ColorAttr(value: Defaults.primaryColor, onSelection: {
                        'tap': {false: (color) => color.withAlpha(100)}
                      }),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {'tap': PointSelection(dim: 1)},
                  tooltip: TooltipGuide(),
                  crosshair: CrosshairGuide(),
                ),
              ),
              Container(
                child: const Text(
                  'Transposed Bar Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Uses gradient attribute instead of color.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
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
                      gradient: GradientAttr(
                          value: const LinearGradient(colors: [
                            Color(0x8883bff6),
                            Color(0x88188df0),
                            Color(0xcc188df0),
                          ], stops: [
                            0,
                            0.5,
                            1
                          ]),
                          onSelection: {
                            'tap': {
                              true: (_) => const LinearGradient(colors: [
                                    Color(0xee83bff6),
                                    Color(0xee3f78f7),
                                    Color(0xff3f78f7),
                                  ], stops: [
                                    0,
                                    0.7,
                                    1
                                  ])
                            }
                          }),
                    )
                  ],
                  coord: RectCoord(transposed: true),
                  axes: [
                    Defaults.verticalAxis
                      ..line = Defaults.strokeStyle
                      ..grid = null,
                    Defaults.horizontalAxis
                      ..line = null
                      ..grid = Defaults.strokeStyle,
                  ],
                  selections: {'tap': PointSelection(dim: 1)},
                ),
              ),
              Container(
                child: const Text(
                  'Interval Bar Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Make sure to specify a same scale for all variables in a same dimension.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- With corner radius.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: intervalData,
                  variables: {
                    'id': Variable(
                      accessor: (Map map) => map['id'] as String,
                    ),
                    'min': Variable(
                      accessor: (Map map) => map['min'] as num,
                      scale: LinearScale(min: 0, max: 160),
                    ),
                    'max': Variable(
                      accessor: (Map map) => map['max'] as num,
                      scale: LinearScale(min: 0, max: 160),
                    ),
                  },
                  elements: [
                    IntervalElement(
                      position: Varset('id') * (Varset('min') + Varset('max')),
                      shape: ShapeAttr(
                          value: RectShape(
                              borderRadius: BorderRadius.circular(2))),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                ),
              ),
              Container(
                child: const Text(
                  'Stacked Bar Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Nested by type.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- With a label in middle of each bar.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- Selects tuples with same index but different types.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                child: const Text(
                  '- A multiple variabes tooltip.',
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
                      shape: ShapeAttr(value: RectShape(labelPosition: 0.5)),
                      color: ColorAttr(
                          variable: 'type', values: Defaults.colors10),
                      label: LabelAttr(
                          encoder: (tuple) => Label(
                                tuple['value'].toString(),
                                LabelStyle(const TextStyle(fontSize: 6)),
                              )),
                      modifiers: [StackModifier()],
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'tap': PointSelection(
                      variable: 'index',
                    )
                  },
                  tooltip: TooltipGuide(multiTuples: true),
                  crosshair: CrosshairGuide(),
                ),
              ),
              Container(
                child: const Text(
                  'Funnel Chart',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  padding: const EdgeInsets.all(10),
                  data: basicData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: -200, max: 200),
                    ),
                  },
                  transforms: [
                    Sort(
                      compare: (a, b) =>
                          ((b['sold'] as num) - (a['sold'] as num)).toInt(),
                    )
                  ],
                  elements: [
                    IntervalElement(
                      label: LabelAttr(
                          encoder: (tuple) => Label(
                                tuple['sold'].toString(),
                                LabelStyle(Defaults.runeStyle),
                              )),
                      shape: ShapeAttr(value: FunnelShape()),
                      color: ColorAttr(
                          variable: 'genre', values: Defaults.colors10),
                      modifiers: [SymmetricModifier()],
                    )
                  ],
                  coord: RectCoord(transposed: true, verticalRange: [1, 0]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
