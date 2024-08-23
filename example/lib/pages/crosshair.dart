import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

class CrosshairPage extends StatefulWidget {
  const CrosshairPage({Key? key}) : super(key: key);

  @override
  CrosshairPageState createState() => CrosshairPageState();
}

class CrosshairPageState extends State<CrosshairPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final priceVolumeStream = StreamController<GestureEvent>.broadcast();

  /// Price parameters

  final List<PaintStyle?> _showCrosshairOnPrice = [
    PaintStyle(strokeColor: Colors.black),
    PaintStyle(strokeColor: Colors.black),
  ];

  final List<bool> _showLabelOnPrice = [false, false];

  final List<bool> _followPointerOnPrice = [false, false];

  /// Volume parameters

  final List<PaintStyle?> _showCrosshairOnVolume = [
    PaintStyle(strokeColor: Colors.black),
    PaintStyle(strokeColor: Colors.black),
  ];

  final List<bool> _showLabelOnVolume = [false, false];

  final List<bool> _followPointerOnVolume = [false, false];

  @override
  Widget build(BuildContext context) {
    final crosshairPaintStyle = PaintStyle(strokeColor: Colors.black);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Crosshair'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                child: const Text(
                  'Demo crosshair feature',
                  style: TextStyle(fontSize: 20),
                ),
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
                  marks: [
                    LineMark(
                      size: SizeEncode(value: 1),
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
                    showLabel: _showLabelOnPrice,
                    followPointer: _followPointerOnPrice,
                    styles: _showCrosshairOnPrice,
                  ),
                  gestureStream: priceVolumeStream,
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
                  marks: [
                    IntervalMark(
                      size: SizeEncode(value: 1),
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
                    showLabel: _showLabelOnVolume,
                    followPointer: _followPointerOnVolume,
                    styles: _showCrosshairOnVolume,
                  ),
                  gestureStream: priceVolumeStream,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SwitchPair(
                      title: '• show crosshair on price',
                      valueX: _showCrosshairOnPrice[0] != null,
                      onChangedX: (isOn) => setState(() =>
                          _showCrosshairOnPrice[0] =
                              isOn ? crosshairPaintStyle : null),
                      valueY: _showCrosshairOnPrice[1] != null,
                      onChangedY: (isOn) => setState(() =>
                          _showCrosshairOnPrice[1] =
                              isOn ? crosshairPaintStyle : null),
                    ),
                    _SwitchPair(
                      title: '• show crosshair on volume',
                      valueX: _showCrosshairOnVolume[0] != null,
                      onChangedX: (isOn) => setState(() =>
                          _showCrosshairOnVolume[0] =
                              isOn ? crosshairPaintStyle : null),
                      valueY: _showCrosshairOnVolume[1] != null,
                      onChangedY: (isOn) => setState(() =>
                          _showCrosshairOnVolume[1] =
                              isOn ? crosshairPaintStyle : null),
                    ),
                    const Divider(),
                    _SwitchPair(
                      title: '• follow pointer on price',
                      valueX: _followPointerOnPrice[0],
                      onChangedX: (isOn) =>
                          setState(() => _followPointerOnPrice[0] = isOn),
                      valueY: _followPointerOnPrice[1],
                      onChangedY: (isOn) =>
                          setState(() => _followPointerOnPrice[1] = isOn),
                    ),
                    _SwitchPair(
                      title: '• follow pointer on volume',
                      valueX: _followPointerOnVolume[0],
                      onChangedX: (isOn) =>
                          setState(() => _followPointerOnVolume[0] = isOn),
                      valueY: _followPointerOnVolume[1],
                      onChangedY: (isOn) =>
                          setState(() => _followPointerOnVolume[1] = isOn),
                    ),
                    const Divider(),
                    _SwitchPair(
                      title: '• show label on price',
                      valueX: _showLabelOnPrice[0],
                      onChangedX: (isOn) =>
                          setState(() => _showLabelOnPrice[0] = isOn),
                      valueY: _showLabelOnPrice[1],
                      onChangedY: (isOn) =>
                          setState(() => _showLabelOnPrice[1] = isOn),
                    ),
                    _SwitchPair(
                      title: '• show label on volume',
                      valueX: _showLabelOnVolume[0],
                      onChangedX: (isOn) =>
                          setState(() => _showLabelOnVolume[0] = isOn),
                      valueY: _showLabelOnVolume[1],
                      onChangedY: (isOn) =>
                          setState(() => _showLabelOnVolume[1] = isOn),
                    ),
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

class _SwitchPair extends StatelessWidget {
  const _SwitchPair({
    required this.title,
    required this.valueX,
    required this.onChangedX,
    required this.valueY,
    required this.onChangedY,
  });

  final String title;
  final bool valueX;
  final void Function(bool) onChangedX;
  final bool valueY;
  final void Function(bool) onChangedY;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        title,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SwitchRow(
            text: 'on X-axis',
            value: valueX,
            onChanged: onChangedX,
          ),
          _SwitchRow(
            text: 'on Y-axis',
            value: valueY,
            onChanged: onChangedY,
          ),
        ],
      ),
    ]);
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {required this.text, required this.value, required this.onChanged});

  final String text;
  final bool value;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
