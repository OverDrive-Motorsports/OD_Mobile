/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## profile_page.dart - Generic profile screen driven by external data.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/base/od_button.dart';
import '../../widgets/base/od_modal.dart';
import '../../widgets/base/od_toast.dart';
import '../../widgets/menu_overlay.dart';

/// Preview data used while the profile page is not connected to live data.
const ProfilePageData profilePagePreviewData = ProfilePageData(
  user: ProfileUserData(
    pseudo: 'Pilote OverDrive',
    email: 'profil.local@overdrive.app',
  ),
);

const ProfilePageContent _profilePageContent = ProfilePageContent(
  providersSectionTitle: 'Providers',
  quickActionsSectionTitle: 'Actions rapides',
  shareProfileToastMessage:
      'Le partage du profil arrivera avec la synchronisation compte.',
  signOutToastMessage:
      'La deconnexion sera disponible avec la gestion de session.',
  addProviderAction: ProfileActionDefinition(
    type: ProfileActionType.addProvider,
    label: 'Ajouter nouveau',
    icon: Icons.add_rounded,
  ),
  quickActions: <ProfileActionDefinition>[
    ProfileActionDefinition(
      type: ProfileActionType.editProfile,
      label: 'Modifier le profil',
      icon: Icons.edit_outlined,
    ),
    ProfileActionDefinition(
      type: ProfileActionType.shareProfile,
      label: 'Partager mon profil',
      icon: Icons.ios_share_outlined,
    ),
    ProfileActionDefinition(
      type: ProfileActionType.signOut,
      label: 'Se deconnecter',
      icon: Icons.logout_rounded,
    ),
    ProfileActionDefinition(
      type: ProfileActionType.deleteAccount,
      label: 'Supprimer le compte',
      icon: Icons.delete_outline_rounded,
      isDestructive: true,
    ),
  ],
  editProfileModal: ProfileModalContent(
    title: 'Modifier le profil',
    body:
        'La partie edition n est pas encore connectee a une source de donnees.',
    supportingText:
        'On peut deja preparer l experience et brancher la sauvegarde plus tard.',
    dismissLabel: 'Compris',
  ),
  deleteAccountModal: ProfileModalContent(
    title: 'Supprimer le compte',
    body: 'Cette action est definitive quand le compte distant sera branche.',
    supportingText:
        'Pour le moment, l interface prepare seulement ce parcours sans executer la suppression.',
    dismissLabel: 'Compris',
  ),
);

/// Immutable profile payload consumed by the page.
class ProfilePageData {
  const ProfilePageData({
    required this.user,
    this.providers = const <ProfileProviderData>[],
  });

  final ProfileUserData user;
  final List<ProfileProviderData> providers;
}

/// Basic user information displayed in the profile header.
class ProfileUserData {
  const ProfileUserData({required this.pseudo, this.email});

  final String pseudo;
  final String? email;
}

/// A connected provider entry reserved for future integrations.
class ProfileProviderData {
  const ProfileProviderData({required this.id, required this.name});

  final String id;
  final String name;
}

/// Structured copy and action definitions used by the profile page.
class ProfilePageContent {
  const ProfilePageContent({
    required this.providersSectionTitle,
    required this.quickActionsSectionTitle,
    required this.shareProfileToastMessage,
    required this.signOutToastMessage,
    required this.addProviderAction,
    required this.quickActions,
    required this.editProfileModal,
    required this.deleteAccountModal,
  });

  final String providersSectionTitle;
  final String quickActionsSectionTitle;
  final String shareProfileToastMessage;
  final String signOutToastMessage;
  final ProfileActionDefinition addProviderAction;
  final List<ProfileActionDefinition> quickActions;
  final ProfileModalContent editProfileModal;
  final ProfileModalContent deleteAccountModal;
}

/// Supported profile page interactions.
enum ProfileActionType {
  addProvider,
  editProfile,
  shareProfile,
  signOut,
  deleteAccount,
}

/// Metadata used to render a profile page action button.
class ProfileActionDefinition {
  const ProfileActionDefinition({
    required this.type,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  final ProfileActionType type;
  final String label;
  final IconData icon;
  final bool isDestructive;
}

/// Copy for a modal displayed from the profile page.
class ProfileModalContent {
  const ProfileModalContent({
    required this.title,
    required this.body,
    required this.supportingText,
    required this.dismissLabel,
  });

  final String title;
  final String body;
  final String supportingText;
  final String dismissLabel;
}

/// Profile screen driven by external data and local action definitions.
class ProfilePage extends StatefulWidget {
  const ProfilePage({this.data, super.key});

  final ProfilePageData? data;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// State holder for profile page feedback and local interactions.
class _ProfilePageState extends State<ProfilePage> {
  ProfilePageData get _resolvedData => widget.data ?? profilePagePreviewData;
  ProfilePageContent get _content => _profilePageContent;

  /// Builds a two-character fallback avatar label from the current pseudo.
  String get _profileInitials {
    final compactPseudo = _resolvedData.user.pseudo.replaceAll(
      RegExp(r'\s+'),
      '',
    );
    if (compactPseudo.isEmpty) {
      return 'OD';
    }

    final initialsLength = compactPseudo.length >= 2 ? 2 : compactPseudo.length;
    return compactPseudo.substring(0, initialsLength).toUpperCase();
  }

  /// Opens one of the informational modals used by profile actions.
  void _showModal(BuildContext context, ProfileModalContent content) {
    OdModal.show<void>(
      context,
      title: content.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content.body, style: AppTextStyles.body()),
          const SizedBox(height: 8),
          Text(content.supportingText, style: AppTextStyles.caption()),
          const SizedBox(height: 20),
          OdButton(
            label: content.dismissLabel,
            fullWidth: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  /// Routes profile actions to modal or toast feedback while data is mocked.
  void _handleAction(BuildContext context, ProfileActionType actionType) {
    switch (actionType) {
      case ProfileActionType.addProvider:
      case ProfileActionType.editProfile:
        _showModal(context, _content.editProfileModal);
        return;
      case ProfileActionType.shareProfile:
        OdToast.show(context, message: _content.shareProfileToastMessage);
        return;
      case ProfileActionType.signOut:
        OdToast.show(
          context,
          message: _content.signOutToastMessage,
          type: ToastType.info,
        );
        return;
      case ProfileActionType.deleteAccount:
        _showModal(context, _content.deleteAccountModal);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _resolvedData.user;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 96, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeroCard(
                      initials: _profileInitials,
                      pseudo: user.pseudo,
                      email: user.email,
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: _content.providersSectionTitle,
                      child: _ProfileActionButton(
                        action: _content.addProviderAction,
                        onPressed: () => _handleAction(
                          context,
                          _content.addProviderAction.type,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: _content.quickActionsSectionTitle,
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < _content.quickActions.length;
                            index++
                          ) ...[
                            _ProfileActionButton(
                              action: _content.quickActions[index],
                              onPressed: () => _handleAction(
                                context,
                                _content.quickActions[index].type,
                              ),
                            ),
                            if (index < _content.quickActions.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const MenuOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Header card showing the avatar fallback and account identity.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.initials,
    required this.pseudo,
    this.email,
  });

  final String initials;
  final String pseudo;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.bodyBold(
                  color: AppColors.black,
                ).copyWith(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pseudo,
                  style: AppTextStyles.bodyBold().copyWith(fontSize: 20),
                ),
                if (email != null && email!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email!,
                    style: AppTextStyles.caption().copyWith(height: 1.35),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight titled section used by the profile page.
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

/// Resolves the correct button variant for a profile action.
class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({required this.action, required this.onPressed});

  final ProfileActionDefinition action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (action.isDestructive) {
      return _DangerActionButton(action: action, onPressed: onPressed);
    }

    return OdButton(
      label: action.label,
      leadingIcon: action.icon,
      fullWidth: true,
      onPressed: onPressed,
    );
  }
}

/// Destructive button variant reserved for account deletion.
class _DangerActionButton extends StatefulWidget {
  const _DangerActionButton({required this.action, required this.onPressed});

  final ProfileActionDefinition action;
  final VoidCallback onPressed;

  @override
  State<_DangerActionButton> createState() => _DangerActionButtonState();
}

/// Press-state animation controller for the destructive profile action.
class _DangerActionButtonState extends State<_DangerActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _isPressed ? 0.985 : 1,
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: (isHighlighted) {
                setState(() => _isPressed = isHighlighted);
              },
              borderRadius: BorderRadius.circular(999),
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _isPressed
                      ? AppColors.white.withValues(alpha: 0.10)
                      : AppColors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _isPressed
                        ? AppColors.white.withValues(alpha: 0.28)
                        : AppColors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.action.icon, size: 18, color: AppColors.red),
                    const SizedBox(width: 8),
                    Text(
                      widget.action.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyBold(
                        color: AppColors.red,
                      ).copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
