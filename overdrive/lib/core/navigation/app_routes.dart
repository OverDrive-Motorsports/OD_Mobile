import 'package:flutter/material.dart';

import '../../pages/calendar/calendar_page.dart';
import '../../pages/championship/championship_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/search/search_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/telemetry/telemetry_page.dart';
import '../../pages/tv/tv_page.dart';

/// Central route names used by the whole app.
abstract final class AppRoutes {
  static const home = '/';
  static const calendar = '/calendar';
  static const championship = '/championship';
  static const profile = '/profile';
  static const search = '/search';
  static const settings = '/settings';
  static const telemetry = '/telemetry';
  static const tv = '/tv';
}

/// Menu pages exposed in the overlay navigation.
class MenuPageLink {
  const MenuPageLink({
    required this.routeName,
    required this.label,
    required this.icon,
  });

  final String routeName;
  final String label;
  final IconData icon;
}

final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
  AppRoutes.home: (_) => const HomePage(),
  AppRoutes.calendar: (_) => const CalendarPage(),
  AppRoutes.championship: (_) => const ChampionshipPage(),
  AppRoutes.profile: (_) => const ProfilePage(data: profilePagePreviewData),
  AppRoutes.search: (_) => const SearchPage(),
  AppRoutes.settings: (_) => const SettingsPage(),
  AppRoutes.telemetry: (_) => const TelemetryPage(),
  AppRoutes.tv: (_) => const TvPage(),
};

Route<dynamic>? buildAppRoute(RouteSettings settings) {
  final builder = appRoutes[settings.name];
  if (builder == null) {
    return null;
  }

  return PageRouteBuilder<void>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

const List<MenuPageLink> menuPageLinks = <MenuPageLink>[
  MenuPageLink(
    routeName: AppRoutes.home,
    label: 'Home',
    icon: Icons.home_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.calendar,
    label: 'Calendar',
    icon: Icons.calendar_month_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.championship,
    label: 'Championship',
    icon: Icons.emoji_events_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.profile,
    label: 'Profil',
    icon: Icons.person_outline_rounded,
  ),
  MenuPageLink(
    routeName: AppRoutes.search,
    label: 'Search',
    icon: Icons.search_rounded,
  ),
  MenuPageLink(
    routeName: AppRoutes.settings,
    label: 'Settings',
    icon: Icons.settings_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.telemetry,
    label: 'Telemetry',
    icon: Icons.speed_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.tv,
    label: 'TV',
    icon: Icons.live_tv_outlined,
  ),
];
