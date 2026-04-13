part of '../main.dart';

enum _SettingsPageTab { appearance, profile, node, feed }

String _settingsPageTabLabel(_SettingsPageTab value) {
  switch (value) {
    case _SettingsPageTab.appearance:
      return 'Appearance';
    case _SettingsPageTab.profile:
      return 'Profile';
    case _SettingsPageTab.node:
      return 'Node';
    case _SettingsPageTab.feed:
      return 'Feed';
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({
    required this.repository,
    required this.currentUser,
    required this.currentAvatarLabel,
    required this.sharePublicCommentsInPersonal,
    required this.leftRail,
    required this.themeModeListenable,
    required this.accentListenable,
    required this.fontListenable,
    required this.nodeMode,
    required this.showLocation,
    required this.publicAcknowledgement,
    required this.onUsernameChanged,
    required this.onLocationChanged,
    required this.onBioChanged,
    required this.onNodeModeChanged,
    required this.onShowLocationChanged,
    required this.onPublicAcknowledgementChanged,
    required this.onAvatarLabelChanged,
    required this.onSharePublicCommentsInPersonalChanged,
    required this.onOpenProfile,
    required this.topNav,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockUser currentUser;
  final String? currentAvatarLabel;
  final bool sharePublicCommentsInPersonal;
  final Widget leftRail;
  final ValueNotifier<bool> themeModeListenable;
  final ValueNotifier<MockAccentKind> accentListenable;
  final ValueNotifier<MockFontKind> fontListenable;
  final String nodeMode;
  final bool showLocation;
  final bool publicAcknowledgement;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onBioChanged;
  final ValueChanged<String> onNodeModeChanged;
  final ValueChanged<bool> onShowLocationChanged;
  final ValueChanged<bool> onPublicAcknowledgementChanged;
  final ValueChanged<String?> onAvatarLabelChanged;
  final ValueChanged<bool> onSharePublicCommentsInPersonalChanged;
  final VoidCallback onOpenProfile;
  final Widget topNav;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  _SettingsPageTab selectedTab = _SettingsPageTab.appearance;
  late String? _localAvatarLabel;
  late bool _localShowLocation;
  late bool _localPublicAcknowledgement;
  late bool _localSharePublicCommentsInPersonal;
  late String _localNodeMode;

  @override
  void initState() {
    super.initState();
    _localAvatarLabel = widget.currentAvatarLabel;
    _localShowLocation = widget.showLocation;
    _localPublicAcknowledgement = widget.publicAcknowledgement;
    _localSharePublicCommentsInPersonal = widget.sharePublicCommentsInPersonal;
    _localNodeMode = widget.nodeMode;
  }

  @override
  Widget build(BuildContext context) {
    final previewUser = MockUser(
      id: widget.currentUser.id,
      username: widget.currentUser.username,
      name: widget.currentUser.name,
      location: widget.currentUser.location,
      bio: widget.currentUser.bio,
      avatarLabel: _localAvatarLabel,
    );

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Settings',
      subtitle:
          'Appearance, profile, node, and feed controls stay grouped here without pretending any real backend control exists yet.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final value in _SettingsPageTab.values)
                  _PageTabChip(
                    label: _settingsPageTabLabel(value),
                    selected: selectedTab == value,
                    onSelected: () => setState(() => selectedTab = value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (selectedTab == _SettingsPageTab.appearance)
            ValueListenableBuilder<bool>(
              valueListenable: widget.themeModeListenable,
              builder: (context, isDarkMode, _) {
                return ValueListenableBuilder<MockAccentKind>(
                  valueListenable: widget.accentListenable,
                  builder: (context, accentKind, _) {
                    return ValueListenableBuilder<MockFontKind>(
                      valueListenable: widget.fontListenable,
                      builder: (context, fontKind, _) {
                        return _SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appearance',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Dark shell mode'),
                                subtitle: Text(
                                  isDarkMode
                                      ? 'Dark mode keeps the shell charcoal-grey, subtitles muted, and body copy bright while the accent drives shell highlights.'
                                      : 'Light mode keeps the shell neutral grey, body copy black, and the accent limited to shell highlights.',
                                ),
                                value: isDarkMode,
                                onChanged: (value) =>
                                    widget.themeModeListenable.value = value,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Accent',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Choose the colour used for major shell titles, active navigation, and toolbar highlights.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final item in MockAccentKind.values)
                                    _AccentChoiceCard(
                                      label: mockAccentLabel(item),
                                      tone: accentThemeForMode(
                                        item,
                                        isDarkMode: isDarkMode,
                                      ),
                                      active: item == accentKind,
                                      onTap: () =>
                                          widget.accentListenable.value = item,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Font',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pick from ten UI fonts. Inter is the default, and each option previews itself directly in the menu.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 280,
                                child: DropdownButtonFormField<MockFontKind>(
                                  initialValue: fontKind,
                                  decoration: const InputDecoration(
                                    labelText: 'Interface font',
                                  ),
                                  items: [
                                    for (final item in MockFontKind.values)
                                      DropdownMenuItem<MockFontKind>(
                                        value: item,
                                        child: Text(
                                          mockFontLabel(item),
                                          style: GoogleFonts.getFont(
                                            mockFontLabel(item),
                                            textStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                          ),
                                        ),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      widget.fontListenable.value = value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            )
          else if (selectedTab == _SettingsPageTab.profile) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserAvatar(previewUser, radius: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile picture',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose a mock avatar preset for your profile surface.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final value in const <String?>[
                                  null,
                                  '🌿',
                                  '🛠',
                                  '📦',
                                  '🚲',
                                  '🧵',
                                ])
                                  _PageTabChip(
                                    label: value ?? 'Initials',
                                    selected: _localAvatarLabel == value,
                                    onSelected: () {
                                      setState(() => _localAvatarLabel = value);
                                      widget.onAvatarLabelChanged(value);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: widget.currentUser.username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: widget.onUsernameChanged,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: widget.currentUser.location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: widget.onLocationChanged,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: widget.currentUser.bio,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    onChanged: widget.onBioChanged,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show approximate location on profile'),
                    value: _localShowLocation,
                    onChanged: (value) {
                      setState(() => _localShowLocation = value);
                      widget.onShowLocationChanged(value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Public contributor acknowledgement'),
                    value: _localPublicAcknowledgement,
                    onChanged: (value) {
                      setState(() => _localPublicAcknowledgement = value);
                      widget.onPublicAcknowledgementChanged(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: widget.onOpenProfile,
                        child: const Text('Open My Profile'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (selectedTab == _SettingsPageTab.node) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Node', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _localNodeMode,
                    decoration: const InputDecoration(
                      labelText: 'Current mock mode',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'full', child: Text('Full')),
                      DropdownMenuItem(value: 'gossip', child: Text('Gossip')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _localNodeMode = value);
                        widget.onNodeModeChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current mock mode is ${_capitalize(_localNodeMode)}. This changes UI state only and does not affect any real local node.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: _MetaTable(
                title: 'Diagnostics Snapshot',
                rows: const [
                  ('Sync freshness', 'Healthy'),
                  ('Peers visible', '6'),
                  ('Last local contact', '2m ago'),
                ],
              ),
            ),
          ] else ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feed', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Let public comments appear in followers\' Personal feeds',
                    ),
                    subtitle: const Text(
                      'Turning this off hides the Show In Personal action and clears your existing shared public-comment cards from Personal.',
                    ),
                    value: _localSharePublicCommentsInPersonal,
                    onChanged: (value) {
                      setState(
                        () => _localSharePublicCommentsInPersonal = value,
                      );
                      widget.onSharePublicCommentsInPersonalChanged(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
