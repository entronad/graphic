import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;

class AttributeAnimationPage extends StatefulWidget {
  @override
  _AttributeAnimationPageState createState() => _AttributeAnimationPageState();
}

class _AttributeAnimationPageState extends State<AttributeAnimationPage> {
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
        r: 100,
        color: Color(0xff1890ff),
        strokeWidth: 4,
        style: PaintingStyle.stroke,
      ),
    ));

    circle.animate(
      toAttrs: graphic.Attrs(
        x: 300,
        y: 300,
        r: 50,
        color: Color(0xfff04864),
      ),
      animationCfg: graphic.AnimationCfg(
        duration: Duration(seconds: 2),
        delay: Duration.zero,
        curve: Curves.linear,
        onFinish: () {},
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
