import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import 'package:intl/intl.dart';

final _monthDayFormat = DateFormat('MM-dd');

///DATA FOR CHART

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}

final timeSeriesSales = getData();

List<TimeSeriesSales> getData() {
  final List<TimeSeriesSales> result = [];
  for (int i = 0; i < 4000; i++) {
    result.add(TimeSeriesSales(DateTime.fromMicrosecondsSinceEpoch(i), i));
  }
  return result;
}

///DATA FOR CHART END

class LineAreaPointPage extends StatefulWidget {
  const LineAreaPointPage({Key? key}) : super(key: key);

  @override
  State<LineAreaPointPage> createState() => _LineAreaPointPageState();
}

class _LineAreaPointPageState extends State<LineAreaPointPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final StreamController<GestureSignal> gestureChannel;

  int tickCount = 50;
  int printCount = 0;

  @override
  void initState() {
    gestureChannel = StreamController<GestureSignal>.broadcast();
    debugPrint("Init");
    super.initState();
  }

  void incTickCount() {
    setState(() {
      tickCount += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("REBUILDING");
    if (!gestureChannel.hasListener) {
      gestureChannel.stream.listen((event) {
        // setState(() {
        //   printCount += 1;
        // });
        debugPrint("EVENT: ${printCount}");
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Line and Area Element'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            for (int i = 0; i < 40; i++) {
              incTickCount();
            }
          },
          child: const Text("Rebuild Button")),
      backgroundColor: Colors.white,
      body: Chart(
        key: _scaffoldKey,
        data: timeSeriesSales,
        gestureChannel: gestureChannel,
        variables: {
          'time': Variable(
              accessor: (TimeSeriesSales datum) => datum.time,
              scale: TimeScale(
                formatter: (time) => _monthDayFormat.format(time),
                tickCount: tickCount,
              )),
          'sales': Variable(
            accessor: (TimeSeriesSales datum) => datum.sales,
          ),
        },
        elements: [
          LineElement(
            shape: ShapeAttr(value: BasicLineShape(dash: [5, 2])),
            selected: {
              'touchMove': {1}
            },
          )
        ],
        coord: RectCoord(color: const Color(0xffdddddd)),
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
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
        tooltip: TooltipGuide(
          followPointer: [false, true],
          align: Alignment.topLeft,
          offset: const Offset(-20, -20),
        ),
        crosshair: CrosshairGuide(followPointer: [false, true]),
      ),
    );
  }
}
