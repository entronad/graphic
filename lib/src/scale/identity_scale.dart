import 'base.dart' show Scale;
import 'scale_cfg.dart' show ScaleCfg, ScaleType;

class IdentityScale<F> extends Scale<F> {
  IdentityScale(ScaleCfg<F> cfg) : super(cfg);

  @override
  ScaleCfg<F> get defaultCfg => super.defaultCfg
    ..isIdentity = true
    ..type = ScaleType.identity;
  
  @override
  String getText(Object value) => cfg.value.toString();

  @override
  double scale(F value) {
    if (cfg.value != value && value is double) {
      return value;
    }
    return cfg.range[0];
  }

  @override
  F invert(Object value) => cfg.value;

  // unused
  @override
  double translate(F value) => null;

  @override
  IdentityScale<F> clone() =>
    IdentityScale<F>(ScaleCfg<F>().mix(cfg));
}
