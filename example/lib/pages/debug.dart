import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

// class DebugPage extends StatelessWidget {
//   DebugPage({Key? key}) : super(key: key);

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: const Text('Debug'),
//       ),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: <Widget>[
//               Container(
//                 margin: const EdgeInsets.only(top: 10),
//                 width: 650,
//                 height: 300,
//                 child: Chart(
//                   rebuild: true,
//                   data: const [
//                   {'genre': 'Sports', 'sold': 275},
//                   {'genre': 'Strategy', 'sold': 115},
//                   {'genre': 'Action', 'sold': 120},
//                   {'genre': 'Shooter', 'sold': 350},
//                   {'genre': 'Other', 'sold': 150},
//                   ],
//                   variables: {
//                   'genre': Variable(
//                   accessor: (Map map) => map['genre'] as String,
//                   ),
//                   'sold': Variable(
//                   accessor: (Map map) => map['sold'] as num,
//                   ),
//                   },
//                   elements: [LineElement()],
//                   axes: [
//                   Defaults.horizontalAxis,
//                   Defaults.verticalAxis,
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final rdm = Random();

  List<Map> data = [];

  @override
  void initState() {
    const cv = -7;

    data = [
      {'genre': 'Sports', 'sold': cv},
      {'genre': 'Strategy', 'sold': cv},
      {'genre': 'Action', 'sold': cv},
      {'genre': 'Shooter', 'sold': cv},
      {'genre': 'Other', 'sold': cv},
    ];

    // data = [
    //   {'genre': 'Sports', 'sold': rdm.nextInt(300)},
    //   {'genre': 'Strategy', 'sold': rdm.nextInt(300)},
    //   {'genre': 'Action', 'sold': rdm.nextInt(300)},
    //   {'genre': 'Shooter', 'sold': rdm.nextInt(300)},
    //   {'genre': 'Other', 'sold': rdm.nextInt(300)},
    // ];

    final timer = Timer.periodic(Duration(seconds: 3), (_) {
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
                  // rebuild: true,
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
                      dim: 1,
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
