import 'package:flutter/material.dart';

import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/calendar/calendar_page.dart';
import '../../pages/championship/championship_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/search/search_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/telemetry/telemetry_page.dart';
import '../../pages/tv/tv_page.dart';
import '../../services/championship/championship_mock_data.dart';

/// Central route names used by the whole app.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const calendar = '/calendar';
  static const championship = '/championship';
  static const championshipFormula1 = '/championship/formula-1';
  static const championshipWec = '/championship/wec';
  static const championshipMotoGp = '/championship/motogp';
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
  AppRoutes.login: (_) => const LoginPage(),
  AppRoutes.register: (_) => const RegisterPage(),
  AppRoutes.home: (_) => const HomePage(),
  AppRoutes.calendar: (_) => const CalendarPage(),
  AppRoutes.championship: (_) =>
      ChampionshipPage(data: championshipFormula1Mock),
  AppRoutes.championshipFormula1: (_) =>
      ChampionshipPage(data: championshipFormula1Mock),
  AppRoutes.championshipWec: (_) => ChampionshipPage(data: championshipWecMock),
  AppRoutes.championshipMotoGp: (_) =>
      ChampionshipPage(data: championshipMotoGpMock),
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
    routeName: AppRoutes.championshipFormula1,
    label: 'F1',
    icon: Icons.flag_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.championshipWec,
    label: 'WEC',
    icon: Icons.emoji_events_outlined,
  ),
  MenuPageLink(
    routeName: AppRoutes.championshipMotoGp,
    label: 'MotoGP',
    icon: Icons.two_wheeler_outlined,
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
