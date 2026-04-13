part of '../main.dart';

class _CreateProjectPage extends StatefulWidget {
  const _CreateProjectPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<_CreateProjectPage> {
  MockProjectType selectedType = MockProjectType.production;
  String title = 'Neighborhood Heat Pump Retrofit Pilot';
  String summary =
      'Research a small retrofit round before moving into full planning and procurement.';
  String locationLabel = 'Block 2 Retrofit Cluster, East Market, Riverbend';
  String district = 'East Market';
  String primaryChannel = 'Housing & Build';
  String additionalChannels = '';
  String taggedCommunities = '';
  String notes =
      'Looking for visible demand, likely participant count, and similar project overlap before the planning stage.';
  String serviceCadence = 'Scheduled';
  String serviceFlow =
      'Weekly evening service slots with direct request intake and lightweight triage.';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _isDarkTheme(context);
    final typeStyle = typeStyleForMode(selectedType, isDarkMode: isDarkMode);
    final productionStyle = typeStyleForMode(
      MockProjectType.production,
      isDarkMode: isDarkMode,
    );
    final serviceStyle = typeStyleForMode(
      MockProjectType.service,
      isDarkMode: isDarkMode,
    );
    final stageStyle = stageStyleForMode(
      MockProjectStage.proposal,
      isDarkMode: isDarkMode,
    );
    final locationSuggestions = widget.repository.projects
        .map((item) => item.locationLabel)
        .toSet()
        .toList();
    final previewTagItems = [
      if (primaryChannel.trim().isNotEmpty)
        _TagChipData(label: primaryChannel, kind: _TagChipKind.channel),
      for (final label in _splitTags(additionalChannels))
        _TagChipData(label: label, kind: _TagChipKind.channel),
      for (final label in _splitTags(taggedCommunities))
        _TagChipData(label: label, kind: _TagChipKind.community),
    ];

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Project',
      subtitle:
          'New projects start in demand signalling so need, labor interest, and early coordination stay visible before planning begins.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Project setup',
          description:
              'Choose the project type, give it a location, and anchor discovery with at least one channel tag.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Type',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TypeOptionCard(
                    title: 'Production',
                    body:
                        'Starts in demand signalling and can gather visible demand before planning locks.',
                    active: selectedType == MockProjectType.production,
                    accent: productionStyle.accent,
                    soft: productionStyle.soft,
                    border: productionStyle.border,
                    onTap: () => setState(
                      () => selectedType = MockProjectType.production,
                    ),
                  ),
                  _TypeOptionCard(
                    title: 'Service',
                    body:
                        'Starts in demand signalling and can move into recurring or one-time service once the operating shape is clear.',
                    active: selectedType == MockProjectType.service,
                    accent: serviceStyle.accent,
                    soft: serviceStyle.soft,
                    border: serviceStyle.border,
                    onTap: () =>
                        setState(() => selectedType = MockProjectType.service),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: locationSuggestions.contains(locationLabel)
                    ? locationLabel
                    : locationSuggestions.first,
                decoration: const InputDecoration(
                  labelText: 'Suggested location',
                ),
                items: [
                  for (final option in locationSuggestions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => locationLabel = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: district,
                decoration: const InputDecoration(
                  labelText: 'District or neighborhood',
                ),
                onChanged: (value) => setState(() => district = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: summary,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Summary'),
                onChanged: (value) => setState(() => summary = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: primaryChannel,
                decoration: const InputDecoration(
                  labelText: 'Primary channel tag',
                ),
                onChanged: (value) => setState(() => primaryChannel = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: additionalChannels,
                decoration: const InputDecoration(
                  labelText: 'Additional channel tags',
                ),
                onChanged: (value) =>
                    setState(() => additionalChannels = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: taggedCommunities,
                decoration: const InputDecoration(labelText: 'Community tags'),
                onChanged: (value) => setState(() => taggedCommunities = value),
              ),
              const SizedBox(height: 12),
              if (selectedType == MockProjectType.production)
                TextFormField(
                  initialValue: notes,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Demand-signalling note',
                  ),
                  onChanged: (value) => setState(() => notes = value),
                )
              else
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: serviceCadence,
                      decoration: const InputDecoration(
                        labelText: 'Service cadence',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'One-time',
                          child: Text('One-time'),
                        ),
                        DropdownMenuItem(
                          value: 'Scheduled',
                          child: Text('Scheduled'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => serviceCadence = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: serviceFlow,
                      decoration: const InputDecoration(
                        labelText: 'Request pattern',
                      ),
                      onChanged: (value) => setState(() => serviceFlow = value),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: primaryChannel.trim().isEmpty ? null : () {},
                    child: const Text('Create Project'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description: 'Matches the current feed treatment for projects.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: typeStyle.soft,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _InfoChip(
                                label: typeStyle.label,
                                background: typeStyle.soft,
                                foreground: typeStyle.accent,
                                border: typeStyle.border,
                              ),
                              _InfoChip(
                                label: stageStyle.label,
                                background: stageStyle.soft,
                                foreground: stageStyle.accent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TagWrap(
                            items: previewTagItems,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(summary),
                    const SizedBox(height: 10),
                    Text(
                      'Location · $locationLabel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedType == MockProjectType.service
                          ? '${serviceCadence.toLowerCase()} service flow · $serviceFlow'
                          : 'Research note · $notes',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _VoteStrip(
                          id: 'project-preview',
                          count: 0,
                          activeVote: 0,
                          onVote: (previewId, direction) {},
                        ),
                        const SizedBox(width: 8),
                        const _CountPill(
                          icon: Icons.mode_comment_outlined,
                          label: '0',
                        ),
                        const Spacer(),
                        Text(
                          '0 members · Posted now',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Posting rules',
              description:
                  'What happens immediately after creation in this mock.',
              child: Text(
                selectedType == MockProjectType.production
                    ? 'New production projects start in Demand Signalling. Votes stay separate from demand, and planning stays public because at least one channel tag is required.'
                    : 'New service projects also start in Demand Signalling. They can gather visible demand before moving into ongoing service and live request handling.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateThreadPage extends StatefulWidget {
  const _CreateThreadPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<_CreateThreadPage> {
  String title = 'How should we coordinate first-round retrofit walkthroughs?';
  String body =
      'Looking for a discussion space that stays separate from the project logistics view so people can compare options without cluttering the project page.';
  String primaryTagType = 'Channel';
  String primaryTagValue = 'Housing & Build';
  String additionalChannels = '';
  String taggedCommunities = '';

  @override
  Widget build(BuildContext context) {
    final previewTagItems = [
      if (primaryTagValue.trim().isNotEmpty)
        _TagChipData(
          label: primaryTagValue,
          kind: primaryTagType == 'Community'
              ? _TagChipKind.community
              : _TagChipKind.channel,
        ),
      for (final label in _splitTags(additionalChannels))
        _TagChipData(label: label, kind: _TagChipKind.channel),
      for (final label in _splitTags(taggedCommunities))
        _TagChipData(label: label, kind: _TagChipKind.community),
    ];

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Thread',
      subtitle:
          'Threads are discussion-first surfaces. The primary tag can be either a channel or a community.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Thread setup',
          description:
              'Start the discussion, choose a primary discovery tag, and add optional tags for wider reach.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Thread title'),
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: primaryTagType,
                decoration: const InputDecoration(
                  labelText: 'Primary tag type',
                ),
                items: const [
                  DropdownMenuItem(value: 'Channel', child: Text('Channel')),
                  DropdownMenuItem(
                    value: 'Community',
                    child: Text('Community'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => primaryTagType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: primaryTagValue,
                decoration: InputDecoration(
                  labelText: primaryTagType == 'Community'
                      ? 'Primary community tag'
                      : 'Primary channel tag',
                ),
                onChanged: (value) => setState(() => primaryTagValue = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: additionalChannels,
                decoration: const InputDecoration(
                  labelText: 'Additional channel tags',
                ),
                onChanged: (value) =>
                    setState(() => additionalChannels = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: taggedCommunities,
                decoration: const InputDecoration(labelText: 'Community tags'),
                onChanged: (value) => setState(() => taggedCommunities = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: body,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Opening post'),
                onChanged: (value) => setState(() => body = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: primaryTagValue.trim().isEmpty ? null : () {},
                    child: const Text('Create Thread'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description:
                  'Threads now sit on the same surface as the feed background.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _threadSurface(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoChip(
                          label: 'Thread',
                          background: _appSurfaceStrong(context),
                          foreground:
                              Theme.of(context).textTheme.labelLarge?.color ??
                              Colors.white,
                          border: _appBorder(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TagWrap(
                            items: previewTagItems,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(body),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _VoteStrip(
                          id: 'thread-preview',
                          count: 0,
                          activeVote: 0,
                          onVote: (previewId, direction) {},
                        ),
                        const SizedBox(width: 8),
                        const _CountPill(
                          icon: Icons.mode_comment_outlined,
                          label: '0',
                        ),
                        const Spacer(),
                        Text(
                          'you · Posted now',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Discussion note',
              description:
                  'How the tag choice affects discovery in the mock app.',
              child: const Text(
                'Threads keep lightweight public discussion, comment nesting, and idea comparison outside the project logistics view.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateEventPage extends StatefulWidget {
  const _CreateEventPage({
    required this.repository,
    required this.currentUserId,
    this.initialChannelId,
    this.initialCommunityId,
    required this.topNav,
    required this.leftRail,
    required this.onEventCreated,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final String currentUserId;
  final String? initialChannelId;
  final String? initialCommunityId;
  final Widget topNav;
  final Widget leftRail;
  final ValueChanged<MockEvent> onEventCreated;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<_CreateEventPage> {
  String title = 'Transit Fare Protest Rally';
  String description =
      'A one-off public rally with speakers, sign-making, and a short station march.';
  String timeLabel = 'Apr 12, 1:00 PM';
  String location = 'East Market Station Plaza';
  bool isPrivate = false;
  late final Set<String> selectedChannelIds;
  late final Set<String> selectedCommunityIds;
  late final Set<String> invitedUserIds;

  @override
  void initState() {
    super.initState();
    final scopedCreate =
        widget.initialChannelId != null || widget.initialCommunityId != null;
    selectedChannelIds = {
      if (widget.initialChannelId != null)
        widget.initialChannelId!
      else if (!scopedCreate)
        'mutual-aid',
    };
    selectedCommunityIds = {
      if (widget.initialCommunityId != null)
        widget.initialCommunityId!
      else if (!scopedCreate)
        'east-market-retrofit-circle',
    };
    invitedUserIds = {if (!scopedCreate) 'mara-holt'};
  }

  @override
  Widget build(BuildContext context) {
    final channels = widget.repository.channels;
    final communities = widget.repository.communities;
    final following = widget.repository.followingForUser(widget.currentUserId);
    final previewEvent = MockEvent(
      id: 'event-preview',
      title: title.trim().isEmpty ? 'Untitled event' : title.trim(),
      timeLabel: timeLabel.trim().isEmpty ? 'Time not set' : timeLabel.trim(),
      location: location.trim().isEmpty ? 'Location not set' : location.trim(),
      going: 1,
      description: description.trim().isEmpty
          ? 'Describe the one-off event, who it is for, and what should happen.'
          : description.trim(),
      rolesNeeded: const [],
      materials: const [],
      outcome: '',
      managerIds: [widget.currentUserId],
      creatorId: widget.currentUserId,
      channelIds: selectedChannelIds.toList(),
      communityIds: selectedCommunityIds.toList(),
      invitedUserIds: invitedUserIds.toList(),
      isPrivate: isPrivate,
      createdAt: prototypeNow,
      lastActivity: prototypeNow,
    );
    final canSubmit =
        title.trim().isNotEmpty &&
        timeLabel.trim().isNotEmpty &&
        location.trim().isNotEmpty &&
        description.trim().isNotEmpty;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Event',
      subtitle:
          'Events are one-off social surfaces: public meetups, private hangs, celebrations, protests, teach-ins, or any other gathering that should not be stretched into a project.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Event setup',
          description:
              'Choose whether the event lives on Public or Personal, add optional channel or community tags, and invite specific people directly when you need a tighter audience.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Visibility', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Public'),
                    selected: !isPrivate,
                    onSelected: (_) => setState(() => isPrivate = false),
                  ),
                  ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Private'),
                    selected: isPrivate,
                    onSelected: (_) => setState(() => isPrivate = true),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Event title'),
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: timeLabel,
                decoration: const InputDecoration(labelText: 'Time label'),
                onChanged: (value) => setState(() => timeLabel = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: location,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) => setState(() => location = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 14),
              Text(
                'Channel tags',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final channel in channels)
                    FilterChip(
                      label: Text(channel.name),
                      selected: selectedChannelIds.contains(channel.id),
                      onSelected:
                          widget.repository.canCreateEventInChannel(
                            channel,
                            widget.currentUserId,
                          )
                          ? (selected) => setState(() {
                              if (selected) {
                                selectedChannelIds.add(channel.id);
                              } else {
                                selectedChannelIds.remove(channel.id);
                              }
                            })
                          : null,
                    ),
                ],
              ),
              if (channels.any(
                (channel) =>
                    widget.repository.isStewardshipChannel(channel) &&
                    !widget.repository.canCreateEventInChannel(
                      channel,
                      widget.currentUserId,
                    ),
              )) ...[
                const SizedBox(height: 6),
                Text(
                  'Stewardship-tagged events can only be created by current board members.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'Community tags',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final community in communities)
                    FilterChip(
                      label: Text(community.name),
                      selected: selectedCommunityIds.contains(community.id),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          selectedCommunityIds.add(community.id);
                        } else {
                          selectedCommunityIds.remove(community.id);
                        }
                      }),
                    ),
                ],
              ),
              if (isPrivate) ...[
                const SizedBox(height: 14),
                Text(
                  'Invite people you follow',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                if (following.isEmpty)
                  const Text(
                    'You are not following anyone yet, so Personal will rely on your own followers plus direct tags.',
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final person in following)
                        FilterChip(
                          label: Text(_userHandle(person)),
                          selected: invitedUserIds.contains(person.id),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              invitedUserIds.add(person.id);
                            } else {
                              invitedUserIds.remove(person.id);
                            }
                          }),
                        ),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  'Private events can stay entirely personal, be shared with specific followers here, or still be scoped through channel and community tags.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: !canSubmit
                        ? null
                        : () {
                            final event = widget.repository
                                .createStandaloneEvent(
                                  title: title.trim(),
                                  timeLabel: timeLabel.trim(),
                                  location: location.trim(),
                                  description: description.trim(),
                                  creatorId: widget.currentUserId,
                                  channelIds: selectedChannelIds.toList(),
                                  communityIds: selectedCommunityIds.toList(),
                                  isPrivate: isPrivate,
                                  invitedUserIds: invitedUserIds.toList(),
                                  managerIds: [widget.currentUserId],
                                );
                            Navigator.of(context).pop();
                            widget.onEventCreated(event);
                          },
                    child: const Text('Create Event'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description:
                  'Shows how the event will appear once it starts surfacing in feeds and search.',
              surface: Colors.transparent,
              child: _StandaloneEventCard(
                repository: widget.repository,
                event: previewEvent,
                onOpenEvent: (_) {},
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Visibility rule',
              description: 'How discovery works in this mock.',
              child: Text(
                isPrivate
                    ? 'Private events can stay in Personal, can be shared with specific followers, or can be scoped through channel and community tags. If you leave tags empty, the event stays out of Public and lives in Personal instead.'
                    : 'Public events can be untagged or tagged. Tags help them appear inside channels, communities, and the broader Public feed instead of floating on their own.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCommunityPage extends StatefulWidget {
  const _CreateCommunityPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<_CreateCommunityPage> {
  String name = 'East Market Retrofit Circle';
  String openness = 'Open';
  String description =
      'Residents, installers, and planners connecting retrofit work across the east side.';

  @override
  Widget build(BuildContext context) {
    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Community',
      subtitle:
          'Communities are discoverable social spaces that connect people to projects and thread discussion without being tied to one channel.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Community setup',
          description:
              'Shape the public social space first, then refine norms and membership controls later.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Community name'),
                onChanged: (value) => setState(() => name = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: openness,
                decoration: const InputDecoration(labelText: 'Openness'),
                items: const [
                  DropdownMenuItem(value: 'Open', child: Text('Open')),
                  DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => openness = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Community'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description: 'How the new community row will read in discovery.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _appSurfaceSoft(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(
                      '$openness community',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Discovery note',
              description:
                  'What this surface is meant to do in the product model.',
              child: const Text(
                'Communities connect people to projects and thread discussion without forcing every topic into one shared channel feed.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateChannelPage extends StatefulWidget {
  const _CreateChannelPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<_CreateChannelPage> {
  String name = 'Energy Retrofit';
  String description =
      'Discussion and discovery for retrofit planning, installation, and maintenance work.';

  @override
  Widget build(BuildContext context) {
    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Channel',
      subtitle:
          'Channels are topic-based discovery surfaces. They host threads and project activity without defining community membership.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Channel setup',
          description:
              'Define the topic surface first. Communities can overlap with it later without replacing it.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Channel name'),
                onChanged: (value) => setState(() => name = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Channel'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description: 'How the new topic surface will appear in lists.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _appSurfaceSoft(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(
                      'Topic channel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Discovery note',
              description: 'What makes a channel different from a community.',
              child: const Text(
                'Channels stay topic-based. They gather related threads and project activity without defining who belongs together socially.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOptionCard extends StatelessWidget {
  const _TypeOptionCard({
    required this.title,
    required this.body,
    required this.active,
    required this.accent,
    required this.soft,
    required this.border,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool active;
  final Color accent;
  final Color soft;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? soft : _appSurface(context),
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(
              color: active ? border : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: active
                    ? accent
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
