import 'base.dart';

class SizeAttr extends Attr<double> {
  SizeAttr(AttrCfg<double> cfg) : super(cfg);

  @override
  AttrCfg<double> get defaultCfg => super.defaultCfg
    ..names = ['size']
    ..type = AttrType.size;

  @override
  double lerp(double a, double b, double t) =>
    (b - a) * t + a;
}
