import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class DebugPage extends StatelessWidget {
  DebugPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Rectangle Interval Mark'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              buildChart('single point', [Data(0, 5, 1)]),
              buildChart('2 points in the same sector at different radiuses',
                  [Data(0, 5, 1), Data(0, 6, 2)]),
              buildChart('2 points with different sector and radius',
                  [Data(0, 5, 1), Data(4, 6, 2)]),
              buildChart('3 points with different everything',
                  [Data(0, 5, 1), Data(1, 6, 2), Data(2, 7, 3)]),
              buildChart('3 points with a duplicate',
                  [Data(0, 5, 1), Data(1, 6, 2), Data(1, 6, 2)]),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildChart(String name, List<Data> data) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 300, child: Text(name)),
        SizedBox(width: 100),
        Container(
          width: 150,
          height: 150,
          child: Chart(
            data: data,
            variables: {
              'sector': Variable(
                accessor: (Data d) => d.sector.toString(),
                scale: OrdinalScale(
                  values: List<int>.generate(10, (i) => i++)
                      .map((s) => s.toString())
                      .toList(),
                ),
              ),
              'radius': Variable(
                accessor: (Data d) => d.radius,
                scale: LinearScale(
                  min: 0,
                  max: 10,
                ),
              ),
              'value': Variable(
                accessor: (Data d) => d.value,
                scale: LinearScale(
                  min: 0,
                  max: 10,
                ),
              ),
            },
            marks: [
              PolygonMark(
                shape: ShapeEncode(
                    value: HeatmapShape(sector: true, tileCounts: [10, 10])),
                color: ColorEncode(
                  variable: 'value',
                  values: [Colors.blue, Colors.red],
                ),
              )
            ],
            coord: PolarCoord(),
            axes: [
              Defaults.circularAxis,
              Defaults.radialAxis,
            ],
          ),
        ),
      ],
    );

class Data {
  final int sector;
  final double radius;
  final double value;

  Data(this.sector, this.radius, this.value);
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
