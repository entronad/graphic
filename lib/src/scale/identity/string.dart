import '../base.dart';
import 'base.dart';

class IdentityScale<D> extends Scale {
  IdentityScale({
    String value,

    String Function(D) accessor,
  }) {
    this['value'] = value;
    this['accessor'] = accessor;
  }

  @override
  ScaleType get type => ScaleType.identity;
}

class StringIdentityScaleState<D> extends IdentityScaleState<String, D> {}

class StringIdentityScaleComponent<D>
  extends IdentityScaleComponent<StringIdentityScaleState<D>, String, D>
{
  StringIdentityScaleComponent([IdentityScale props]) : super(props);

  @override
  StringIdentityScaleState<D> get originalState => StringIdentityScaleState<D>();
}
