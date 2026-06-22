import 'package:flutter/widgets.dart';

// InheritedWidget injected by GridItemWidget around every telemetry child.
// Avoids threading onRemove/onReset through every widget's constructor —
// widgets call TelemetryItemActions.maybeOf(context) in their onTap handler.
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
