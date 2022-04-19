import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:graphic_example/data.dart';

class Sector extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Paths.rSector(
        center: Offset(175, 150),
        r: 20,
        r0: 90,
        startAngle: 0,
        endAngle: -1.6,
        clockwise: true,
        topLeft: Radius.circular(5),
        topRight: Radius.circular(5),
        bottomRight: Radius.circular(5),
        bottomLeft: Radius.circular(5),
      ),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DebugPage extends StatelessWidget {
  DebugPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                shape: ShapeAttr(
                    value: RectShape(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
                size: SizeAttr(value: 10),
              )
            ],
            coord: PolarCoord(transposed: true),
            axes: [
              Defaults.radialAxis..label = null,
              Defaults.circularAxis,
            ],
          ),
          // child: CustomPaint(painter: Sector()),
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
