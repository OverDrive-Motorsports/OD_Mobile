/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## settings_page.dart - Settings screen composed with shared OverDrive widgets.
 ##
 */

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/base/od_button.dart';
import '../../widgets/base/od_modal.dart';
import '../../widgets/base/od_switch.dart';
import '../../widgets/base/od_toast.dart';

const SettingsModalContent _storageInfoModalContent = SettingsModalContent(
  title: 'Stockage des reglages',
  body:
      'Pour le moment, cette page simule la personnalisation cote application.',
  supportingText:
      'Quand le backend profil sera branche, on pourra reutiliser la meme interface avec une vraie persistance.',
  dismissLabel: 'Fermer',
);

const String _notificationsSectionTitle = 'Notifications';
const String _experienceSectionTitle = 'Experience';
const String _actionsSectionTitle = 'Actions';

const List<SettingsToggleDefinition> _notificationSettings =
    <SettingsToggleDefinition>[
      SettingsToggleDefinition(
        key: SettingsToggleKey.liveAlerts,
        label: 'Alertes en direct',
        description:
            'Notifications pour les debuts de session et les moments cles.',
        initialValue: true,
      ),
      SettingsToggleDefinition(
        key: SettingsToggleKey.emailNotifications,
        label: 'Notifications mail',
        description:
            'Recu des alertes et recaps importants par courrier electronique.',
      ),
      SettingsToggleDefinition(
        key: SettingsToggleKey.weekendSummary,
        label: 'Resume de week-end',
        description: 'Recap des resultats et du classement en fin de course.',
        initialValue: true,
      ),
      SettingsToggleDefinition(
        key: SettingsToggleKey.calendarReminders,
        label: 'Rappels calendrier',
        description: 'Rappel avant les seances a venir depuis le calendrier.',
      ),
    ];

const List<SettingsToggleDefinition>
_experienceSettings = <SettingsToggleDefinition>[
  SettingsToggleDefinition(
    key: SettingsToggleKey.compactMode,
    label: 'Mode compact',
    description: 'Condense certaines cartes pour afficher plus de contenu.',
  ),
  SettingsToggleDefinition(
    key: SettingsToggleKey.colorBlindMode,
    label: 'Mode daltoniens',
    description:
        'Ajuste certains contrastes et codes couleur pour une meilleure lisibilite.',
  ),
];

const List<SettingsActionDefinition> _settingsActions =
    <SettingsActionDefinition>[
      SettingsActionDefinition(
        type: SettingsActionType.save,
        label: 'Enregistrer',
        icon: Icons.check_rounded,
      ),
      SettingsActionDefinition(
        type: SettingsActionType.reset,
        label: 'Restaurer les valeurs par defaut',
        icon: Icons.refresh_rounded,
      ),
      SettingsActionDefinition(
        type: SettingsActionType.storageInfo,
        label: 'Infos de stockage',
        icon: Icons.info_outline_rounded,
      ),
    ];

/// Supported toggle identifiers for the settings page state.
enum SettingsToggleKey {
  liveAlerts,
  emailNotifications,
  weekendSummary,
  calendarReminders,
  compactMode,
  colorBlindMode,
}

/// Supported actions triggered from the settings page footer.
enum SettingsActionType { save, reset, storageInfo }

/// Toggle metadata rendered by the settings page.
class SettingsToggleDefinition {
  const SettingsToggleDefinition({
    required this.key,
    required this.label,
    required this.description,
    this.initialValue = false,
  });

  final SettingsToggleKey key;
  final String label;
  final String description;
  final bool initialValue;
}

/// Action metadata rendered by the settings page action section.
class SettingsActionDefinition {
  const SettingsActionDefinition({
    required this.type,
    required this.label,
    required this.icon,
  });

  final SettingsActionType type;
  final String label;
  final IconData icon;
}

/// Copy displayed in the storage information modal.
class SettingsModalContent {
  const SettingsModalContent({
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

/// Settings screen composed from shared widgets and immutable definitions.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// State holder for local settings values and feedback actions.
class _SettingsPageState extends State<SettingsPage> {
  late final Map<SettingsToggleKey, bool> _toggleValues;

  @override
  void initState() {
    super.initState();
    _toggleValues = _createInitialToggleValues();
  }

  /// Creates the initial local state from declarative toggle definitions.
  Map<SettingsToggleKey, bool> _createInitialToggleValues() {
    final definitions = <SettingsToggleDefinition>[
      ..._notificationSettings,
      ..._experienceSettings,
    ];

    return <SettingsToggleKey, bool>{
      for (final definition in definitions)
        definition.key: definition.initialValue,
    };
  }

  /// Shows feedback for the simulated settings save action.
  void _saveSettings() {
    FocusScope.of(context).unfocus();
    OdToast.show(
      context,
      message: 'Reglages enregistres localement.',
      type: ToastType.success,
    );
  }

  /// Restores all toggles to their declarative default values.
  void _resetSettings() {
    setState(() {
      _toggleValues
        ..clear()
        ..addAll(_createInitialToggleValues());
    });

    FocusScope.of(context).unfocus();
    OdToast.show(
      context,
      message: 'Les preferences par defaut ont ete restaurees.',
      type: ToastType.info,
    );
  }

  /// Opens a modal explaining how settings persistence will be connected.
  void _openStorageInfo() {
    OdModal.show<void>(
      context,
      title: _storageInfoModalContent.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_storageInfoModalContent.body, style: AppTextStyles.body()),
          const SizedBox(height: 8),
          Text(
            _storageInfoModalContent.supportingText,
            style: AppTextStyles.caption(),
          ),
          const SizedBox(height: 20),
          OdButton(
            label: _storageInfoModalContent.dismissLabel,
            fullWidth: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  /// Updates a single toggle in local state.
  void _handleToggleChanged(SettingsToggleKey key, bool value) {
    setState(() => _toggleValues[key] = value);
  }

  /// Dispatches footer actions to their local handlers.
  void _handleAction(SettingsActionType actionType) {
    switch (actionType) {
      case SettingsActionType.save:
        _saveSettings();
        return;
      case SettingsActionType.reset:
        _resetSettings();
        return;
      case SettingsActionType.storageInfo:
        _openStorageInfo();
        return;
    }
  }

  /// Builds switch rows for one settings section.
  List<Widget> _buildToggleSectionChildren(
    List<SettingsToggleDefinition> definitions,
  ) {
    return <Widget>[
      for (var index = 0; index < definitions.length; index++) ...[
        _SwitchTile(
          label: definitions[index].label,
          description: definitions[index].description,
          value: _toggleValues[definitions[index].key] ?? false,
          onChanged: (value) =>
              _handleToggleChanged(definitions[index].key, value),
        ),
        if (index < definitions.length - 1) const Divider(height: 24),
      ],
    ];
  }

  /// Builds the footer action buttons from their declarative definitions.
  List<Widget> _buildActionSectionChildren() {
    return <Widget>[
      for (var index = 0; index < _settingsActions.length; index++) ...[
        OdButton(
          label: _settingsActions[index].label,
          leadingIcon: _settingsActions[index].icon,
          fullWidth: true,
          onPressed: () => _handleAction(_settingsActions[index].type),
        ),
        if (index < _settingsActions.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: ColoredBox(
        color: AppColors.black,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsSection(
                  title: _notificationsSectionTitle,
                  child: _SettingsCard(
                    children: _buildToggleSectionChildren(
                      _notificationSettings,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: _experienceSectionTitle,
                  child: _SettingsCard(
                    children: _buildToggleSectionChildren(
                      _experienceSettings,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: _actionsSectionTitle,
                  child: Column(children: _buildActionSectionChildren()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lightweight titled section used on the settings page.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

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
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Shared card shell used to group settings controls.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Column(children: children),
    );
  }
}

/// Toggle row with a label/description column and a trailing switch.
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      label,
                      style: AppTextStyles.body().copyWith(fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.caption().copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OdSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ],
    );
  }
}
