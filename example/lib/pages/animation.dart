import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

class AnimationPage extends StatefulWidget {
  const AnimationPage({Key? key}) : super(key: key);

  @override
  AnimationPageState createState() => AnimationPageState();
}

class AnimationPageState extends State<AnimationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final rdm = Random();

  List<Map> barAnimData = [];

  List<List> scatterAnimData = [
    [28604, 77, 17096869, 'Australia', 1],
    [1516, 68, 1154605773, 'China', 1],
    [13670, 74.7, 10582082, 'Cuba', 1],
    [28599, 75, 4986705, 'Finland', 1],
    [31476, 75.4, 78958237, 'Germany', 1],
    [1777, 57.7, 870601776, 'India', 1],
    [2076, 67.9, 20194354, 'North Korea', 1],
    [12087, 72, 42972254, 'South Korea', 1],
    [10088, 70.8, 38195258, 'Poland', 1],
    [19349, 69.6, 147568552, 'Russia', 1],
    [10670, 67.3, 53994605, 'Turkey', 1],
    [37062, 75.4, 252847810, 'United States', 1],
    [44056, 81.8, 23968973, 'Australia', -1],
    [13334, 76.9, 1376048943, 'China', -1],
    [21291, 78.5, 11389562, 'Cuba', -1],
    [38923, 80.8, 5503457, 'Finland', -1],
    [44053, 81.1, 80688545, 'Germany', -1],
    [5903, 66.8, 1311050527, 'India', -1],
    [1390, 71.4, 25155317, 'North Korea', -1],
    [34644, 80.7, 50293439, 'South Korea', -1],
    [24787, 77.3, 38611794, 'Poland', -1],
    [23038, 73.13, 143456918, 'Russia', -1],
    [19360, 76.5, 78665830, 'Turkey', -1],
    [53354, 79.1, 321773631, 'United States', -1]
  ];

  late Timer timer;

  final priceVolumeStream = StreamController<GestureEvent>.broadcast();

  final heatmapStream = StreamController<Selected?>.broadcast();

  bool rebuild = false;

  @override
  void initState() {
    barAnimData = [
      {'genre': 'Sports', 'sold': rdm.nextInt(300)},
      {'genre': 'Strategy', 'sold': rdm.nextInt(300)},
      {'genre': 'Action', 'sold': rdm.nextInt(300)},
      {'genre': 'Shooter', 'sold': rdm.nextInt(300)},
      {'genre': 'Other', 'sold': rdm.nextInt(300)},
    ];

    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        rebuild = false;
        barAnimData = [
          {'genre': 'Sports', 'sold': rdm.nextInt(300)},
          {'genre': 'Strategy', 'sold': rdm.nextInt(300)},
          {'genre': 'Action', 'sold': rdm.nextInt(300)},
          {'genre': 'Shooter', 'sold': rdm.nextInt(300)},
          {'genre': 'Other', 'sold': rdm.nextInt(300)},
        ];

        scatterAnimData = scatterAnimData
            .map((d) => [d[0], d[1], d[2], d[3], -1 * d[4]])
            .toList();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Animation'),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          rebuild = true;
        }),
        child: const Icon(Icons.refresh),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Auto Animated Ranking',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With data entrance in y direction.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  rebuild: false,
                  data: barAnimData,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  transforms: [
                    Sort(
                        compare: (tuple1, tuple2) =>
                            tuple1['sold'] - tuple2['sold'])
                  ],
                  marks: [
                    IntervalMark(
                      transition: Transition(duration: const Duration(seconds: 1)),
                      entrance: {MarkEntrance.y},
                      label: LabelEncode(
                          encoder: (tuple) => Label(tuple['sold'].toString())),
                      tag: (tuple) => tuple['genre'].toString(),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Animated Rose Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With elastic animation curve.',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Press refreash to rebuild.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  rebuild: rebuild,
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
                  marks: [
                    IntervalMark(
                      label: LabelEncode(
                          encoder: (tuple) => Label(tuple['name'].toString())),
                      shape: ShapeEncode(
                          value: RectShape(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      )),
                      color: ColorEncode(
                          variable: 'name', values: Defaults.colors10),
                      elevation: ElevationEncode(value: 5),
                      transition: Transition(
                          duration: const Duration(seconds: 2),
                          curve: Curves.elasticOut),
                      entrance: {MarkEntrance.y},
                    )
                  ],
                  coord: PolarCoord(startRadius: 0.15),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Morphing',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: scatterAnimData,
                  variables: {
                    '0': Variable(
                      accessor: (List datum) => datum[0] as num,
                      scale: LinearScale(min: 0, max: 80000, tickCount: 8),
                    ),
                    '1': Variable(
                      accessor: (List datum) => datum[1] as num,
                    ),
                    '2': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                    '4': Variable(
                        accessor: (List datum) => datum[4].toString(),
                        scale: OrdinalScale(values: ['-1', '1'])),
                  },
                  marks: [
                    PointMark(
                      size: SizeEncode(variable: '2', values: [10, 30]),
                      color: ColorEncode(
                        variable: '4',
                        values: Defaults.colors10,
                        updaters: {
                          'choose': {true: (_) => Colors.red}
                        },
                      ),
                      shape: ShapeEncode(variable: '4', values: [
                        CircleShape(),
                        SquareShape(),
                      ]),
                      transition: Transition(duration: const Duration(seconds: 1)),
                    )
                  ],
                  axes: [
                    Defaults.circularAxis
                      ..labelMapper = (_, index, total) {
                        if (index == total - 1) {
                          return null;
                        }
                        return LabelStyle(textStyle: Defaults.textStyle);
                      }
                      ..label = null,
                    Defaults.radialAxis
                      ..labelMapper = (_, index, total) {
                        if (index == total - 1) {
                          return null;
                        }
                        return LabelStyle(textStyle: Defaults.textStyle);
                      }
                      ..label = null,
                  ],
                  coord: PolarCoord(),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Animated Pie Chart',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Press refreash to rebuild.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  rebuild: rebuild,
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
                  marks: [
                    IntervalMark(
                      position: Varset('percent') / Varset('genre'),
                      label: LabelEncode(
                          encoder: (tuple) => Label(
                                tuple['sold'].toString(),
                                LabelStyle(textStyle: Defaults.runeStyle),
                              )),
                      color: ColorEncode(
                          variable: 'genre', values: Defaults.colors10),
                      modifiers: [StackModifier()],
                      transition: Transition(duration: const Duration(seconds: 2)),
                      entrance: {MarkEntrance.y},
                    )
                  ],
                  coord: PolarCoord(transposed: true, dimCount: 1),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Line and Area chart animated Entrance',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- With tree entrance values: x, y, alpha',
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Press refreash to rebuild.',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  rebuild: rebuild,
                  data: invalidData,
                  variables: {
                    'Date': Variable(
                      accessor: (Map map) => map['Date'] as String,
                      scale: OrdinalScale(tickCount: 5),
                    ),
                    'Close': Variable(
                      accessor: (Map map) =>
                          (map['Close'] ?? double.nan) as num,
                    ),
                  },
                  marks: [
                    AreaMark(
                      shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
                      gradient: GradientEncode(
                          value: LinearGradient(colors: [
                        Defaults.colors10.first.withAlpha(80),
                        Defaults.colors10.first.withAlpha(10),
                      ])),
                      transition: Transition(duration: const Duration(seconds: 2)),
                      entrance: {
                        MarkEntrance.x,
                        MarkEntrance.y,
                        MarkEntrance.opacity
                      },
                    ),
                    LineMark(
                      shape: ShapeEncode(value: BasicLineShape(smooth: true)),
                      size: SizeEncode(value: 0.5),
                      transition: Transition(duration: const Duration(seconds: 2)),
                      entrance: {
                        MarkEntrance.x,
                        MarkEntrance.y,
                        MarkEntrance.opacity
                      },
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
