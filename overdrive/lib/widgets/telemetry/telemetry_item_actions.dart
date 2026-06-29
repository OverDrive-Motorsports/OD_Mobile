/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## [telemetry_item_actions.dart] - InheritedWidget that propagates remove/reset callbacks down the telemetry widget tree.
 ##
 */

import 'package:flutter/widgets.dart';

// InheritedWidget injected by GridItemWidget around every telemetry child; avoids threading onRemove/onReset through constructors — widgets call TelemetryItemActions.maybeOf(context) in their onTap handler.
class TelemetryItemActions extends InheritedWidget {
  const TelemetryItemActions({
    super.key,
    required this.onRemove,
    required this.onReset,
    required super.child,
  });

  final VoidCallback? onRemove;
  final VoidCallback? onReset;

  static TelemetryItemActions? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TelemetryItemActions>();

  @override
  bool updateShouldNotify(TelemetryItemActions old) =>
      onRemove != old.onRemove || onReset != old.onReset;
}
