/*
##
## OverDrive 2026
## All Technical rights reserved
##
## app_routes.dart - Central route names, page builders, and menu entries.
##
*/

import 'package:flutter/material.dart';

import '../../pages/login/login_page.dart';
import '../../pages/signup/signup_page.dart';
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

final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
	AppRoutes.login: (_) => const LoginPage(),
	AppRoutes.register: (_) => const SignupPage(),
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

/// Builds an app route without transition animation for menu-style navigation.
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

