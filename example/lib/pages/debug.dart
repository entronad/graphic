import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

const adjustData = [
  {"type": "Email", "index": 0, "value": 120},
  {"type": "Email", "index": 1, "value": 132},
  {"type": "Email", "index": 2, "value": 101},
  {"type": "Email", "index": 3, "value": 134},
  {"type": "Email", "index": 4, "value": 90},
  {"type": "Email", "index": 5, "value": 230},
  {"type": "Email", "index": 6, "value": 210},
  {"type": "Affiliate", "index": 0, "value": 220},
  {"type": "Affiliate", "index": 1, "value": 182},
  {"type": "Affiliate", "index": 2, "value": 191},
  {"type": "Affiliate", "index": 3, "value": 234},
  {"type": "Affiliate", "index": 4, "value": 290},
  {"type": "Affiliate", "index": 5, "value": 330},
  {"type": "Affiliate", "index": 6, "value": 310},
  {"type": "Video", "index": 0, "value": 150},
  {"type": "Video", "index": 1, "value": 232},
  {"type": "Video", "index": 2, "value": 201},
  {"type": "Video", "index": 3, "value": 154},
  {"type": "Video", "index": 4, "value": 190},
  {"type": "Video", "index": 5, "value": 330},
  {"type": "Video", "index": 6, "value": 410},
  {"type": "Direct", "index": 0, "value": 320},
  {"type": "Direct", "index": 1, "value": 332},
  {"type": "Direct", "index": 2, "value": 301},
  {"type": "Direct", "index": 3, "value": 334},
  {"type": "Direct", "index": 4, "value": 390},
  {"type": "Direct", "index": 5, "value": 330},
  {"type": "Direct", "index": 6, "value": 320},
  {"type": "Search", "index": 0, "value1": 320},
  {"type": "Search", "index": 1, "value1": 432},
  {"type": "Search", "index": 2, "value1": 401},
  {"type": "Search", "index": 3, "value1": 434},
  {"type": "Search", "index": 4, "value1": 390},
  {"type": "Search", "index": 5, "value1": 430},
  {"type": "Search", "index": 6, "value1": 420},
];

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
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
                elevation: ElevationAttr(value: 0, updaters: {
                  'tap': {true: (_) => 5}
                }),
                color: ColorAttr(value: Defaults.primaryColor, updaters: {
                  'tap': {false: (color) => color.withAlpha(100)}
                }),
                selected: {
                  'tap': {0}
                },
              )
            ],
            axes: [
              Defaults.horizontalAxis,
              Defaults.verticalAxis,
            ],
            selections: {'tap': PointSelection(dim: Dim.x)},
            tooltip: TooltipGuide(),
            crosshair: CrosshairGuide(),
          ),
        ),
      ),
    );
  }
}

// class DebugPage extends StatefulWidget {
//   const DebugPage({Key? key}) : super(key: key);

//   @override
//   _DebugPageState createState() => _DebugPageState();
// }

// class _DebugPageState extends State<DebugPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   int _enterCounter = 0;
//   int _exitCounter = 0;
//   double x = 0.0;
//   double y = 0.0;

//   void _incrementEnter(PointerEvent details) {
//     setState(() {
//       _enterCounter++;
//     });
//   }

//   void _incrementExit(PointerEvent details) {
//     setState(() {
//       _exitCounter++;
//     });
//   }

//   void _updateLocation(PointerEvent details) {
//     setState(() {
//       x = details.position.dx;
//       y = details.position.dy;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints.tight(const Size(300.0, 200.0)),
//           child: MouseRegion(
//             onEnter: _incrementEnter,
//             onHover: _updateLocation,
//             onExit: _incrementExit,
//             child: Container(
//               color: Colors.lightBlueAccent,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   const Text(
//                       'You have entered or exited this box this many times:'),
//                   Text(
//                     '$_enterCounter Entries\n$_exitCounter Exits',
//                     style: Theme.of(context).textTheme.headline4,
//                   ),
//                   Text(
//                     'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       )
//     );
//   }
// }
