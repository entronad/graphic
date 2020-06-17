import 'base.dart';

class ShapeAttr extends Attr<String> {
  ShapeAttr(AttrCfg<String> cfg) : super(cfg);

  @override
  AttrCfg<String> get defaultCfg => super.defaultCfg
    ..names = ['shape']
    ..type = AttrType.shape;

  @override
  String getLinearValue(double percent) {
    final values = cfg.values;
    final index = ((values.length - 1) * percent).round();
    return values[index];
  }

  @override
  String lerp(String a, String b, double t) => null;
}
