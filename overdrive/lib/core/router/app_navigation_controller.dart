import 'package:flutter/foundation.dart';

final ValueNotifier<int> appNavigationIndex = ValueNotifier<int>(0);

void setAppNavigationIndex(int index) {
  if (appNavigationIndex.value == index) return;
  appNavigationIndex.value = index;
}
