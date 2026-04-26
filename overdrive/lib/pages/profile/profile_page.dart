/**
##
## OverDrive 2026
## All Technical rights reserved
##
## profile_page.dart - Profile screen placeholder.
##
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/menu_overlay.dart';

class ProfilePage extends StatelessWidget {
const ProfilePage({super.key});

@override
Widget build(BuildContext context) {
	return Scaffold(
	backgroundColor: AppColors.black,
	body: ColoredBox(
		color: AppColors.black,
		child: Stack(
		children: [
			SafeArea(
			child: Consumer<AuthService>(
				builder: (context, authService, _) {
				return SingleChildScrollView(
					child: Padding(
					padding: const EdgeInsets.all(24),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
						Text(
							'Profile',
							style: AppTextStyles.display(),
						),
						const SizedBox(height: 32),
						Container(
							padding: const EdgeInsets.all(24),
							decoration: BoxDecoration(
							color: AppColors.surface,
							border: Border.all(
								color: AppColors.surfaceBorder,
							),
							borderRadius: BorderRadius.circular(8),
							),
							child: Column(
							children: [
								Container(
								width: 80,
								height: 80,
								decoration: BoxDecoration(
									shape: BoxShape.circle,
									color: AppColors.background,
									border: Border.all(
									color: AppColors.accent,
									width: 2,
									),
								),
								child: const Icon(
									Icons.person_rounded,
									size: 40,
									color: AppColors.accent,
								),
								),
								const SizedBox(height: 16),
								Text(
								authService.userEmail ?? 'User',
								style: AppTextStyles.bodyBold(),
								),
								const SizedBox(height: 8),
								Text(
								'ID: ${authService.userId ?? 'N/A'}',
								style: AppTextStyles.body(
									color: AppColors.textSecondary,
								),
								),
							],
							),
						),
						const SizedBox(height: 32),
						SizedBox(
							width: double.infinity,
							height: 48,
							child: ElevatedButton(
							onPressed: () async {
								await context.read<AuthService>().logout();
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: AppColors.error,
								shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(8),
								),
							),
							child: Text(
								'Logout',
								style: AppTextStyles.bodyBold(
								color: AppColors.textPrimary,
								),
							),
							),
						),
						],
					),
					),
				);
				},
			),
			),
			const MenuOverlay(),
		],
		),
	),
	);
}
}
