import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

class InteractionChannelDynamicPage extends StatefulWidget {
  const InteractionChannelDynamicPage({Key? key}) : super(key: key);

  @override
  _InteractionChannelDynamicPageState createState() =>
      _InteractionChannelDynamicPageState();
}

class _InteractionChannelDynamicPageState
    extends State<InteractionChannelDynamicPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final rdm = Random();

  List<Map> data = [];

  late Timer timer;

  final priceVolumeChannel = StreamController<GestureSignal>.broadcast();

  final heatmapChannel = StreamController<Selected?>.broadcast();

  @override
  void initState() {
    data = [
      {'genre': 'Sports', 'sold': rdm.nextInt(300)},
      {'genre': 'Strategy', 'sold': rdm.nextInt(300)},
      {'genre': 'Action', 'sold': rdm.nextInt(300)},
      {'genre': 'Shooter', 'sold': rdm.nextInt(300)},
      {'genre': 'Other', 'sold': rdm.nextInt(300)},
    ];

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        data = [
          {'genre': 'Sports', 'sold': rdm.nextInt(300)},
          {'genre': 'Strategy', 'sold': rdm.nextInt(300)},
          {'genre': 'Action', 'sold': rdm.nextInt(300)},
          {'genre': 'Shooter', 'sold': rdm.nextInt(300)},
          {'genre': 'Other', 'sold': rdm.nextInt(300)},
        ];
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
        title: const Text('Dynamic'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: const Text(
                  'Signal Channel coupling',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- The price chart and volume chart share the same gesture signal channel.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 150,
                child: Chart(
                  padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 0),
                  rebuild: false,
                  data: priceVolumeData,
                  variables: {
                    'time': Variable(
                      accessor: (Map map) => map['time'] as String,
                      scale: OrdinalScale(tickCount: 3),
                    ),
                    'end': Variable(
                      accessor: (Map map) => map['end'] as num,
                      scale: LinearScale(min: 5, tickCount: 5),
                    ),
                  },
                  elements: [
                    LineElement(
                      size: SizeAttr(value: 1),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis
                      ..label = null
                      ..line = null,
                    Defaults.verticalAxis
                      ..gridMapper = (_, index, __) =>
                          index == 0 ? null : Defaults.strokeStyle,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                    )
                  },
                  crosshair: CrosshairGuide(
                    followPointer: [true, false],
                    styles: [
                      StrokeStyle(color: const Color(0xffbfbfbf), dash: [4, 2]),
                      StrokeStyle(color: const Color(0xffbfbfbf), dash: [4, 2]),
                    ],
                  ),
                  gestureChannel: priceVolumeChannel,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 0),
                width: 350,
                height: 80,
                child: Chart(
                  padding: (_) => const EdgeInsets.fromLTRB(40, 0, 10, 20),
                  rebuild: false,
                  data: priceVolumeData,
                  variables: {
                    'time': Variable(
                      accessor: (Map map) => map['time'] as String,
                      scale: OrdinalScale(tickCount: 3),
                    ),
                    'volume': Variable(
                      accessor: (Map map) => map['volume'] as num,
                      scale: LinearScale(min: 0),
                    ),
                  },
                  elements: [
                    IntervalElement(
                      size: SizeAttr(value: 1),
                    )
                  ],
                  axes: [
                    Defaults.horizontalAxis,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                    )
                  },
                  crosshair: CrosshairGuide(
                    followPointer: [true, false],
                    styles: [
                      StrokeStyle(color: const Color(0xffbfbfbf), dash: [4, 2]),
                      StrokeStyle(color: const Color(0xffbfbfbf), dash: [4, 2]),
                    ],
                  ),
                  gestureChannel: priceVolumeChannel,
                ),
              ),
              Container(
                child: const Text(
                  'Selection Channel coupling',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- The above and below heatmaps share the same selection channel. Tap either one to try.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 200,
                child: Chart(
                  padding: (_) => EdgeInsets.zero,
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  elements: [
                    PolygonElement(
                      shape: ShapeAttr(value: HeatmapShape(sector: true)),
                      color: ColorAttr(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                      selectionChannel: heatmapChannel,
                    )
                  ],
                  coord: PolarCoord(),
                  selections: {'tap': PointSelection()},
                  tooltip: TooltipGuide(
                    anchor: (_) => Offset.zero,
                    align: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 100,
                child: Chart(
                  padding: (_) => EdgeInsets.zero,
                  data: heatmapData,
                  variables: {
                    'name': Variable(
                      accessor: (List datum) => datum[0].toString(),
                    ),
                    'day': Variable(
                      accessor: (List datum) => datum[1].toString(),
                    ),
                    'sales': Variable(
                      accessor: (List datum) => datum[2] as num,
                    ),
                  },
                  elements: [
                    PolygonElement(
                      color: ColorAttr(
                        variable: 'sales',
                        values: [
                          const Color(0xffbae7ff),
                          const Color(0xff1890ff),
                          const Color(0xff0050b3)
                        ],
                        updaters: {
                          'tap': {false: (color) => color.withAlpha(70)}
                        },
                      ),
                      selectionChannel: heatmapChannel,
                    )
                  ],
                  selections: {'tap': PointSelection()},
                ),
              ),
              Container(
                child: const Text(
                  'Auto update',
                  style: TextStyle(fontSize: 20),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
              ),
              Container(
                child: const Text(
                  '- Change data in every second.',
                ),
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 650,
                height: 300,
                child: Chart(
                  rebuild: false,
                  data: data,
                  variables: {
                    'genre': Variable(
                      accessor: (Map map) => map['genre'] as String,
                    ),
                    'sold': Variable(
                      accessor: (Map map) => map['sold'] as num,
                    ),
                  },
                  elements: [IntervalElement()],
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'tap': PointSelection(
                      on: {
                        GestureType.hover,
                        GestureType.tap,
                      },
                      dim: Dim.x,
                    )
                  },
                  tooltip: TooltipGuide(
                    backgroundColor: Colors.black,
                    elevation: 5,
                    textStyle: Defaults.textStyle,
                    variables: ['genre', 'sold'],
                  ),
                  crosshair: CrosshairGuide(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
