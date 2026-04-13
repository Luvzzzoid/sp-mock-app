part of '../main.dart';

class _OnboardingStepData {
  const _OnboardingStepData({
    required this.id,
    required this.title,
    required this.body,
    required this.ctaCopy,
  });

  final String id;
  final String title;
  final String body;
  final String ctaCopy;
}

const List<_OnboardingStepData> _onboardingSteps = [
  _OnboardingStepData(
    id: 'welcome',
    title: 'Welcome',
    body:
        'Orient the user, explain the platform, and set expectations that this is a local-first collaborative app rather than a simple social feed.',
    ctaCopy:
        'Frame the product as a coordination space first, then let the user continue into identity and node setup basics.',
  ),
  _OnboardingStepData(
    id: 'identity',
    title: 'Identity And Keys',
    body:
        'Create or restore a persistent user identity without confusing it with the device or node identity.',
    ctaCopy:
        'Keep the language plain: restore an existing identity or create a new one tied to the person, not the current machine.',
  ),
  _OnboardingStepData(
    id: 'node',
    title: 'Node Setup Basics',
    body:
        'Choose the initial device participation mode in plain language and explain that sync may continue after entry.',
    ctaCopy:
        'Treat node mode as a plain-English setup choice and avoid implying that the app is blocked until perfect sync completes.',
  ),
  _OnboardingStepData(
    id: 'profile',
    title: 'Profile Setup',
    body:
        'Capture a public-facing profile summary, avatar, and the minimum information needed for discovery and coordination.',
    ctaCopy:
        'Ask only for the information needed to help people find and work with each other, then allow refinement later from settings.',
  ),
  _OnboardingStepData(
    id: 'interests',
    title: 'Interest Selection',
    body:
        'Give the user a lightweight way to shape early discovery without locking them into a rigid preference system.',
    ctaCopy:
        'Seed the first search and feed surfaces with suggested channels and communities, but keep everything editable after entry.',
  ),
  _OnboardingStepData(
    id: 'ready',
    title: 'Sync And Ready',
    body:
        'Show the app-ready checklist, communicate sync status, and let the user enter the product without waiting for perfect completeness.',
    ctaCopy:
        'End with a clear handoff into the feed, plus a reminder that search, notifications, settings, and profile remain available immediately.',
  ),
];

enum _OnboardingIdentityMode { create, restore }

class _OnboardingResult {
  const _OnboardingResult({
    required this.username,
    required this.location,
    required this.bio,
    required this.nodeMode,
    required this.showLocation,
    required this.publicAcknowledgement,
    required this.selectedChannelIds,
    required this.selectedCommunityIds,
  });

  final String username;
  final String location;
  final String bio;
  final String nodeMode;
  final bool showLocation;
  final bool publicAcknowledgement;
  final Set<String> selectedChannelIds;
  final Set<String> selectedCommunityIds;
}

class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({
    required this.repository,
    required this.initialUsername,
    required this.initialLocation,
    required this.initialBio,
    required this.initialNodeMode,
    required this.initialShowLocation,
    required this.initialPublicAcknowledgement,
    required this.initialSubscribedChannelIds,
    required this.initialJoinedCommunityIds,
    required this.topNav,
  });

  final MockRepository repository;
  final String initialUsername;
  final String initialLocation;
  final String initialBio;
  final String initialNodeMode;
  final bool initialShowLocation;
  final bool initialPublicAcknowledgement;
  final Set<String> initialSubscribedChannelIds;
  final Set<String> initialJoinedCommunityIds;
  final Widget topNav;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage> {
  int stepIndex = 0;
  late _OnboardingIdentityMode identityMode;
  late String username;
  late String location;
  late String bio;
  late String nodeMode;
  late bool showLocation;
  late bool publicAcknowledgement;
  late bool continueWhileSync;
  late String recoveryWords;
  late Set<String> selectedChannelIds;
  late Set<String> selectedCommunityIds;

  @override
  void initState() {
    super.initState();
    identityMode = _OnboardingIdentityMode.create;
    username = widget.initialUsername;
    location = widget.initialLocation;
    bio = widget.initialBio;
    nodeMode = widget.initialNodeMode;
    showLocation = widget.initialShowLocation;
    publicAcknowledgement = widget.initialPublicAcknowledgement;
    continueWhileSync = true;
    recoveryWords = '';
    selectedChannelIds = {...widget.initialSubscribedChannelIds};
    selectedCommunityIds = {...widget.initialJoinedCommunityIds};
  }

  _OnboardingStepData get _currentStep => _onboardingSteps[stepIndex];

  bool get _isLastStep => stepIndex == _onboardingSteps.length - 1;

  String get _normalizedUsername {
    final normalized = username.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_-]'),
      '',
    );
    return normalized;
  }

  String get _identityFingerprint {
    final seed = (_normalizedUsername.isEmpty ? 'builder' : _normalizedUsername)
        .padRight(8, 'x');
    return 'sp-${seed.substring(0, 8)}-local';
  }

  bool get _allRequiredStepsValid =>
      _identityStepValid && _profileStepValid && _interestStepValid;

  bool get _identityStepValid =>
      _normalizedUsername.length >= 3 &&
      (identityMode == _OnboardingIdentityMode.create ||
          recoveryWords.trim().length >= 12);

  bool get _profileStepValid =>
      location.trim().isNotEmpty && bio.trim().length >= 12;

  bool get _interestStepValid =>
      selectedChannelIds.isNotEmpty || selectedCommunityIds.isNotEmpty;

  String? get _validationMessage {
    switch (_currentStep.id) {
      case 'identity':
        if (_normalizedUsername.length < 3) {
          return 'Choose a username with at least 3 letters or numbers.';
        }
        if (identityMode == _OnboardingIdentityMode.restore &&
            recoveryWords.trim().length < 12) {
          return 'Add recovery words or a backup code to continue.';
        }
        return null;
      case 'profile':
        if (location.trim().isEmpty) {
          return 'Add a location label so nearby work is easier to read.';
        }
        if (bio.trim().length < 12) {
          return 'Write a short profile note so people know how to work with you.';
        }
        return null;
      case 'interests':
        if (!_interestStepValid) {
          return 'Pick at least one channel or community to seed discovery.';
        }
        return null;
      case 'ready':
        if (!_allRequiredStepsValid) {
          return 'Finish the earlier setup steps before entering the feed.';
        }
        return null;
      default:
        return null;
    }
  }

  bool get _canContinue => _validationMessage == null;

  void _toggleChannel(String channelId) {
    setState(() {
      if (!selectedChannelIds.add(channelId)) {
        selectedChannelIds.remove(channelId);
      }
    });
  }

  void _toggleCommunity(String communityId) {
    setState(() {
      if (!selectedCommunityIds.add(communityId)) {
        selectedCommunityIds.remove(communityId);
      }
    });
  }

  void _finishOnboarding() {
    Navigator.of(context).pop(
      _OnboardingResult(
        username: _normalizedUsername,
        location: location.trim(),
        bio: bio.trim(),
        nodeMode: nodeMode,
        showLocation: showLocation,
        publicAcknowledgement: publicAcknowledgement,
        selectedChannelIds: selectedChannelIds,
        selectedCommunityIds: selectedCommunityIds,
      ),
    );
  }

  Widget _buildStepPrimary(BuildContext context, _OnboardingStepData step) {
    switch (step.id) {
      case 'welcome':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how this account starts on this device.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SetupChoiceCard(
                  title: 'Create A New Identity',
                  description:
                      'Use this when you are starting fresh and want a new local account identity.',
                  active: identityMode == _OnboardingIdentityMode.create,
                  badge: 'New account',
                  onTap: () => setState(
                    () => identityMode = _OnboardingIdentityMode.create,
                  ),
                ),
                _SetupChoiceCard(
                  title: 'Restore Existing Identity',
                  description:
                      'Use recovery words or a backup code to bring an existing person-level identity onto this device.',
                  active: identityMode == _OnboardingIdentityMode.restore,
                  badge: 'Recovery',
                  onTap: () => setState(
                    () => identityMode = _OnboardingIdentityMode.restore,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MetaTable(
              rows: const [
                ('What gets set up', 'Identity, node mode, profile, discovery'),
                ('Editable later', 'Everything from settings and profile'),
                ('Entry rule', 'You can enter while sync keeps running'),
              ],
            ),
          ],
        );
      case 'identity':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: username,
              decoration: const InputDecoration(
                labelText: 'Username',
                helperText:
                    'This is how people search for you in the mock app.',
              ),
              onChanged: (value) => setState(() => username = value),
            ),
            const SizedBox(height: 12),
            if (identityMode == _OnboardingIdentityMode.restore)
              TextFormField(
                initialValue: recoveryWords,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Recovery words or backup code',
                  helperText:
                      'Mock input only. Restoring keeps the account tied to the person, not the device.',
                ),
                onChanged: (value) => setState(() => recoveryWords = value),
              )
            else
              _MetaTable(
                rows: [
                  ('Identity mode', 'Create new local identity'),
                  ('Key fingerprint', _identityFingerprint),
                  ('Recovery', 'Add a backup later from settings'),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              'Public username preview: ${_normalizedUsername.isEmpty ? 'choose-a-username' : _normalizedUsername}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        );
      case 'node':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SetupChoiceCard(
                  title: 'Light',
                  description:
                      'Fastest way to get started. Good for browsing, messaging, and planning while sync stays thin.',
                  active: nodeMode == 'light',
                  badge: 'Recommended',
                  onTap: () => setState(() => nodeMode = 'light'),
                ),
                _SetupChoiceCard(
                  title: 'Hybrid',
                  description:
                      'Keeps more local coordination data ready while still feeling like a normal desktop app.',
                  active: nodeMode == 'hybrid',
                  badge: 'Balanced',
                  onTap: () => setState(() => nodeMode = 'hybrid'),
                ),
                _SetupChoiceCard(
                  title: 'Full',
                  description:
                      'Best for operators who want the heaviest local participation footprint from the start.',
                  active: nodeMode == 'full',
                  badge: 'Heavy local mode',
                  onTap: () => setState(() => nodeMode = 'full'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enter the app while sync keeps running'),
              subtitle: const Text(
                'The mock keeps setup moving instead of blocking on a perfect first sync.',
              ),
              value: continueWhileSync,
              onChanged: (value) => setState(() => continueWhileSync = value),
            ),
          ],
        );
      case 'profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: location,
              decoration: const InputDecoration(
                labelText: 'Approximate location',
                helperText: 'Keep it human-readable rather than exact.',
              ),
              onChanged: (value) => setState(() => location = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: bio,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Short bio',
                helperText:
                    'What kind of work do you want people to contact you about?',
              ),
              onChanged: (value) => setState(() => bio = value),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show approximate location on profile'),
              value: showLocation,
              onChanged: (value) => setState(() => showLocation = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Public contributor acknowledgement'),
              subtitle: const Text(
                'Keeps your participation visible on public-facing project history where appropriate.',
              ),
              value: publicAcknowledgement,
              onChanged: (value) =>
                  setState(() => publicAcknowledgement = value),
            ),
          ],
        );
      case 'interests':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick the spaces you want to see first.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Channels seed the day-to-day work stream.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final channel in widget.repository.channels)
                  _SetupChoiceCard(
                    title: channel.name,
                    description: channel.description,
                    active: selectedChannelIds.contains(channel.id),
                    badge: 'Channel',
                    onTap: () => _toggleChannel(channel.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Communities shape people-centered discovery.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final community in widget.repository.communities)
                  _SetupChoiceCard(
                    title: community.name,
                    description: community.description,
                    active: selectedCommunityIds.contains(community.id),
                    badge: community.openness,
                    onTap: () => _toggleCommunity(community.id),
                  ),
              ],
            ),
          ],
        );
      case 'ready':
        final selectedLabels = [
          ...selectedChannelIds
              .map(widget.repository.channelById)
              .whereType<MockChannel>()
              .map((item) => item.name),
          ...selectedCommunityIds
              .map(widget.repository.communityById)
              .whereType<MockCommunity>()
              .map((item) => item.name),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetaTable(
              rows: [
                ('Username', _normalizedUsername),
                ('Node mode', _capitalize(nodeMode)),
                ('Profile location', showLocation ? location.trim() : 'Hidden'),
                (
                  'Sync handoff',
                  continueWhileSync ? 'Enter immediately' : 'Wait for sync cue',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Selected starting spaces',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            if (selectedLabels.isEmpty)
              const Text('No spaces selected yet.')
            else
              _TagWrap(labels: selectedLabels),
            const SizedBox(height: 14),
            Text(
              'You can keep adjusting profile, discovery picks, and visibility settings after entry.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepSecondary(BuildContext context, _OnboardingStepData step) {
    switch (step.id) {
      case 'welcome':
        return _MetaTable(
          rows: const [
            ('Feed', 'Available as soon as setup is done'),
            ('Search', 'Projects, threads, spaces, and people'),
            ('Messages', 'Direct conversations stay private'),
          ],
        );
      case 'identity':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _normalizedUsername.isEmpty
                  ? 'choose-a-username'
                  : _normalizedUsername,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              identityMode == _OnboardingIdentityMode.create
                  ? 'New local identity prepared for first entry.'
                  : 'Existing identity will be restored onto this device.',
            ),
            const SizedBox(height: 12),
            _MetaTable(
              rows: [
                (
                  'Mode',
                  identityMode == _OnboardingIdentityMode.create
                      ? 'Create'
                      : 'Restore',
                ),
                ('Fingerprint', _identityFingerprint),
                (
                  'People will see',
                  _normalizedUsername.isEmpty
                      ? 'Username pending'
                      : _normalizedUsername,
                ),
              ],
            ),
          ],
        );
      case 'node':
        return _MetaTable(
          rows: [
            ('Current mode', _capitalize(nodeMode)),
            ('Peers visible', '6 mock peers'),
            (
              'Entry behavior',
              continueWhileSync
                  ? 'Enter while sync continues'
                  : 'Wait for sync cue',
            ),
          ],
        );
      case 'profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: MockPalette.greenSoft,
                  foregroundColor: MockPalette.greenDark,
                  child: Text(
                    (_normalizedUsername.isEmpty
                            ? 'U'
                            : _normalizedUsername.characters.first)
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _normalizedUsername.isEmpty
                            ? 'choose-a-username'
                            : _normalizedUsername,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(showLocation ? location.trim() : 'Location hidden'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bio.trim().isEmpty ? 'Bio preview will appear here.' : bio.trim(),
            ),
            const SizedBox(height: 12),
            _TagWrap(
              labels: [
                if (showLocation) 'Location visible' else 'Location hidden',
                if (publicAcknowledgement) 'Public acknowledgement on',
              ],
            ),
          ],
        );
      case 'interests':
        final selectedLabels = [
          ...selectedChannelIds
              .map(widget.repository.channelById)
              .whereType<MockChannel>()
              .map((item) => item.name),
          ...selectedCommunityIds
              .map(widget.repository.communityById)
              .whereType<MockCommunity>()
              .map((item) => item.name),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discovery preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (selectedLabels.isEmpty)
              const Text(
                'Pick a few spaces to seed the first search and feed views.',
              )
            else
              _TagWrap(labels: selectedLabels),
          ],
        );
      case 'ready':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetaTable(
              rows: [
                ('Feed entry', 'Immediate'),
                ('Notifications', 'Ready after setup'),
                ('Settings edits', 'Available immediately'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This handoff keeps the app usable even if sync and discovery refinement continue after first entry.',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _currentStep;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            widget.topNav,
            Expanded(
              child: Container(
                color: _centerPaneSurface(context),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 940),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final intro = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/brand/logo.png',
                                    height: 72,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Account Start',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: _appMuted(context),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.title,
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(fontSize: 32),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    step.body,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: _appMuted(context),
                                    ),
                                  ),
                                ],
                              );

                              final summary = Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _appSurfaceSoft(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Step',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: _appMuted(context)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${stepIndex + 1} of ${_onboardingSteps.length}',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      step.id.toUpperCase(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: _appMuted(context),
                                            letterSpacing: 1.0,
                                          ),
                                    ),
                                  ],
                                ),
                              );

                              if (constraints.maxWidth >= 760) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: intro),
                                    const SizedBox(width: 20),
                                    SizedBox(width: 180, child: summary),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  intro,
                                  const SizedBox(height: 16),
                                  summary,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          Divider(color: _paneDivider(context), height: 1),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Close'),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (
                                var index = 0;
                                index < _onboardingSteps.length;
                                index++
                              )
                                ChoiceChip(
                                  label: Text(
                                    '${index + 1}. ${_onboardingSteps[index].title}',
                                  ),
                                  selected: index == stepIndex,
                                  onSelected: (_) =>
                                      setState(() => stepIndex = index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _FlowSplit(
                            primary: _FlowPanel(
                              title: 'Do This Now',
                              description:
                                  'This step updates real mock setup state instead of just explaining it.',
                              child: _buildStepPrimary(context, step),
                            ),
                            secondary: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FlowPanel(
                                  title: 'Step Guidance',
                                  description:
                                      'Plain-language guidance for the current account-start moment.',
                                  child: Text(step.ctaCopy),
                                ),
                                const SizedBox(height: 12),
                                _FlowPanel(
                                  title: 'Current Preview',
                                  description:
                                      'How the current setup choices will look when the user enters the app.',
                                  child: _buildStepSecondary(context, step),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_validationMessage != null) ...[
                            Text(
                              _validationMessage!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _negativeVoteColor(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            children: [
                              TextButton(
                                onPressed: stepIndex == 0
                                    ? null
                                    : () => setState(() => stepIndex -= 1),
                                child: const Text('Back'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: !_canContinue
                                    ? null
                                    : _isLastStep
                                    ? _finishOnboarding
                                    : () => setState(() => stepIndex += 1),
                                child: Text(
                                  _isLastStep ? 'Enter The Feed' : 'Continue',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupChoiceCard extends StatelessWidget {
  const _SetupChoiceCard({
    required this.title,
    required this.description,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String description;
  final bool active;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      hoverColor: _rowHoverOverlay(context),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? _appSurfaceStrong(context) : _appSurfaceSoft(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? _interactionAccent(context) : _appBorder(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null) ...[
              _TagWrap(labels: [badge!]),
              const SizedBox(height: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
