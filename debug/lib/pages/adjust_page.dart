import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

const data = [{"type":"邮件营销","index":0,"value":120},{"type":"邮件营销","index":1,"value":132},{"type":"邮件营销","index":2,"value":101},{"type":"邮件营销","index":3,"value":134},{"type":"邮件营销","index":4,"value":90},{"type":"邮件营销","index":5,"value":230},{"type":"邮件营销","index":6,"value":210},{"type":"联盟广告","index":0,"value":220},{"type":"联盟广告","index":1,"value":182},{"type":"联盟广告","index":2,"value":191},{"type":"联盟广告","index":3,"value":234},{"type":"联盟广告","index":4,"value":290},{"type":"联盟广告","index":5,"value":330},{"type":"联盟广告","index":6,"value":310},{"type":"视频广告","index":0,"value":150},{"type":"视频广告","index":1,"value":232},{"type":"视频广告","index":2,"value":201},{"type":"视频广告","index":3,"value":154},{"type":"视频广告","index":4,"value":190},{"type":"视频广告","index":5,"value":330},{"type":"视频广告","index":6,"value":410},{"type":"直接访问","index":0,"value":320},{"type":"直接访问","index":1,"value":332},{"type":"直接访问","index":2,"value":301},{"type":"直接访问","index":3,"value":334},{"type":"直接访问","index":4,"value":390},{"type":"直接访问","index":5,"value":330},{"type":"直接访问","index":6,"value":320},{"type":"搜索引擎","index":0,"value":820},{"type":"搜索引擎","index":1,"value":932},{"type":"搜索引擎","index":2,"value":901},{"type":"搜索引擎","index":3,"value":934},{"type":"搜索引擎","index":4,"value":1290},{"type":"搜索引擎","index":5,"value":1330},{"type":"搜索引擎","index":6,"value":1320}];

class AdjustPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Chart'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: data,
                  scales: {
                    'index': graphic.LinearScale(
                      accessor: (map) => map['index'] as num,
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.LinearScale(
                      accessor: (map) => map['value'] as num,
                      max: 3000,
                    ),
                  },
                  geoms: [graphic.AreaGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                    shape: graphic.ShapeAttr(values: [graphic.BasicAreaShape(smooth: true)]),
                  )],
                  axes: {
                    'index': graphic.Axis(),
                    'value': graphic.Axis(),
                  },
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: data,
                  scales: {
                    'index': graphic.CatScale(
                      accessor: (map) => map['index'].toString(),
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.LinearScale(
                      accessor: (map) => map['value'] as num,
                    ),
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.DodgeAdjust(),
                    size: graphic.SizeAttr(values: [2]),
                    // shape: graphic.ShapeAttr(values: [graphic.smoothLine]),
                  )],
                  axes: {
                    'index': graphic.Axis(),
                    'value': graphic.Axis(),
                  },
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: data,
                  scales: {
                    'index': graphic.LinearScale(
                      accessor: (map) => map['index'] as num,
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                    ),
                    'value': graphic.LinearScale(
                      accessor: (map) => map['value'] as num,
                      max: 3000,
                    ),
                  },
                  geoms: [graphic.LineGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                    shape: graphic.ShapeAttr(values: [graphic.BasicLineShape(smooth: true)]),
                  )],
                  axes: {
                    'index': graphic.Axis(),
                    'value': graphic.Axis(),
                  },
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: data,
                  scales: {
                    'index': graphic.CatScale(
                      accessor: (map) => map['index'].toString(),
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                      range: [0, 1],
                    ),
                    'value': graphic.LinearScale(
                      accessor: (map) => map['value'] as num,
                      max: 3000,
                    ),
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                  )],
                  axes: {
                    'index': graphic.Axis(),
                    'value': graphic.Axis(),
                  },
                ),
                margin: EdgeInsets.all(20),
              ),
              Container(
                width: 300,
                height: 300,
                child: graphic.Chart(
                  data: data,
                  scales: {
                    'index': graphic.CatScale(
                      accessor: (map) => map['index'].toString(),
                    ),
                    'type': graphic.CatScale(
                      accessor: (map) => map['type'] as String,
                      range: [0, 1],
                    ),
                    'value': graphic.LinearScale(
                      accessor: (map) => map['value'] as num,
                      max: 3000,
                    ),
                  },
                  geoms: [graphic.IntervalGeom(
                    position: graphic.PositionAttr(field: 'index*value'),
                    color: graphic.ColorAttr(field: 'type'),
                    adjust: graphic.StackAdjust(),
                  )],
                  axes: {
                    'index': graphic.Defaults.circularAxis
                      ..top = true,
                    'value': graphic.Defaults.radialAxis
                      ..grid = null
                      ..top = true,
                  },
                  coord: graphic.PolarCoord(),
                ),
                margin: EdgeInsets.all(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
