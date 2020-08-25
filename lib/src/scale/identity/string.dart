import '../base.dart';
import 'base.dart';

class IdentScale<D> extends IdentityScale<String, D> {
  IdentScale({
    String value,

    String Function(D) accessor,
  }) {
    this['value'] = value;
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.ident;
}

class StringIdentityScaleState<D> extends IdentityScaleState<String, D> {}

class StringIdentityScaleComponent<D>
  extends IdentityScaleComponent<StringIdentityScaleState<D>, String, D>
{
  StringIdentityScaleComponent([IdentScale<D> props]) : super(props);

  @override
  StringIdentityScaleState<D> get originalState => StringIdentityScaleState<D>();
}
