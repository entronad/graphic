import 'dart:async';

import '../dataflow.dart';

FutureOr<void> asyncCallback<D>(
  Dataflow<D> df,
  DataflowCallback<D> callback,
) async {
  try {
    await callback(df);
  } catch (e) {
    df.error(e.toString());
  }
}
