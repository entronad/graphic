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

  List<Map> data = [];

  late Timer timer;

  final priceVolumeStream = StreamController<GestureEvent>.broadcast();

  final heatmapStream = StreamController<Selected?>.broadcast();

  @override
  void initState() {
    data = [
      {'genre': 'Sports', 'sold': rdm.nextInt(300)},
      {'genre': 'Strategy', 'sold': rdm.nextInt(300)},
      {'genre': 'Action', 'sold': rdm.nextInt(300)},
      {'genre': 'Shooter', 'sold': rdm.nextInt(300)},
      {'genre': 'Other', 'sold': rdm.nextInt(300)},
    ];

    timer = Timer.periodic(const Duration(seconds: 3), (_) {
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
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Auto update',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '- Change data in every second.',
                ),
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
                  marks: [
                    IntervalMark(
                        transition: Transition(duration: Duration(seconds: 2)),
                        entrance: MarkEntrance.y)
                  ],
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
