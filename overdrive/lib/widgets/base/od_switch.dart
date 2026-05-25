/*
##
## OverDrive 2026
## All Technical rights reserved
##
## od_switch.dart - Shared Cupertino switch row for OverDrive settings surfaces.
##
*/

import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';

/// A shared Cupertino switch row for settings and preferences.
class OdSwitch extends StatelessWidget {
  const OdSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final switchWidget = CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.red,
    );

    if (label == null) {
      return SizedBox(height: 44, child: Align(child: switchWidget));
    }

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label!,
              style: AppTextStyles.body().copyWith(fontSize: 15),
            ),
          ),
          switchWidget,
        ],
      ),
    );
  }
}
