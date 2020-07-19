import 'package:graphic/src/common/base_classes.dart';

import '../base.dart';
import 'base.dart';

class IdentityScale extends Props<ScaleType> {
  IdentityScale({
    String value
  }) {
    this['value'] = value;
  }

  @override
  ScaleType get type => ScaleType.identity;
}

class StringIdentityScaleState extends IdentityScaleState<String> {}

class StringIdentityScaleComponent
  extends IdentityScaleComponent<StringIdentityScaleState, String>
{
  StringIdentityScaleComponent([IdentityScale props]) : super(props);

  @override
  StringIdentityScaleState get originalState => StringIdentityScaleState();
}
