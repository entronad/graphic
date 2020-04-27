import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class OnFrameAnimationPage extends StatefulWidget {
  @override
  _OnFrameAnimationPageState createState() => _OnFrameAnimationPageState();
}

class _OnFrameAnimationPageState extends State<OnFrameAnimationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final graphic.Renderer renderer = graphic.Renderer();

  @override
  void initState() {
    super.initState();

    final circle = renderer.addShape(graphic.Cfg(
      type: graphic.ShapeType.circle,
      attrs: graphic.Attrs(
        x: 200,
        y: 200,
        r: 20,
        color: Color(0xff1890ff),
        strokeWidth: 4,
        style: PaintingStyle.stroke,
      ),
    ));

    circle.animate(
      onFrame: (ratio) => graphic.Attrs(
        x: 200 + (400 - 200) * ratio,
        y: 200 + (300 - 200) * ratio,
        r: 20 + (50 - 20) * ratio,
      ),
      animationCfg: graphic.AnimationCfg(
        duration: Duration(seconds: 2),
        repeat: true,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('shape'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: 500,
                height: 500,
                child: graphic.Canvas(
                  renderer: renderer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
