import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';

final _monthDayFormat = DateFormat('MM-dd');

class TestPage extends StatelessWidget {
  TestPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Line and Area Element'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart<Map<String, num>>(
                  data: const [
                    {'a': 1, 'b': 1},
                    {'a': 2},
                    {'a': 3, 'b': 3}
                  ],
                  variables: {
                    'a': Variable<Map<String, num>, num>(
                      accessor: (Map<String, num> datum) =>
                          datum['a'] ?? double.nan,
                    ),
                    'b': Variable<Map<String, num>, num>(
                        accessor: (Map<String, num> datum) =>
                            datum['b'] ?? double.nan,
                        scale: LinearScale(ticks: [0, 1, 2, 3, 4])),
                  },
                  elements: [
                    LineElement(position: Varset('a') * Varset('b')),
                    PointElement(position: Varset('a') * Varset('b')),
                  ],
                  coord: RectCoord(color: const Color(0xffdddddd)),
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
