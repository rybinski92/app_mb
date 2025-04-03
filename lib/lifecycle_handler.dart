import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;

  LifecycleEventHandler({this.resumeCallBack});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && resumeCallBack != null) {
      await resumeCallBack!();
    }
  }
}