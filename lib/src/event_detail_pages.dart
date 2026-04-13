part of '../main.dart';

class _EventDetailPage extends StatefulWidget {
  const _EventDetailPage({
    required this.repository,
    required this.project,
    required this.event,
    required this.topNav,
    required this.leftRail,
    required this.rsvpEvents,
    required this.onToggleRsvp,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockProject project;
  final MockEvent event;
  final Widget topNav;
  final Widget leftRail;
  final Map<String, bool> rsvpEvents;
  final void Function(String eventId) onToggleRsvp;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<_EventDetailPage> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: event.title,
      subtitle:
          'Project activity now stays social-first: overview, discussion, updates, and managers live on one shared surface.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _EventDetailContent(
        repository: widget.repository,
        event: event,
        project: widget.project,
        rsvpEvents: widget.rsvpEvents,
        onToggleRsvp: widget.onToggleRsvp,
        onOpenProject: widget.onOpenProject,
      ),
    );
  }
}

class _StandaloneEventDetailPage extends StatefulWidget {
  const _StandaloneEventDetailPage({
    required this.repository,
    required this.event,
    required this.topNav,
    required this.leftRail,
    required this.rsvpEvents,
    required this.onToggleRsvp,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockEvent event;
  final Widget topNav;
  final Widget leftRail;
  final Map<String, bool> rsvpEvents;
  final void Function(String eventId) onToggleRsvp;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_StandaloneEventDetailPage> createState() =>
      _StandaloneEventDetailPageState();
}

class _StandaloneEventDetailPageState
    extends State<_StandaloneEventDetailPage> {
  @override
  Widget build(BuildContext context) {
    final event =
        widget.repository.standaloneEventById(widget.event.id) ?? widget.event;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: event.title,
      subtitle:
          'Standalone events now stay social-first: overview, discussion, updates, and managers live together without pretending every gathering is a project.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _EventDetailContent(
        repository: widget.repository,
        event: event,
        rsvpEvents: widget.rsvpEvents,
        onToggleRsvp: widget.onToggleRsvp,
        onOpenProject: widget.onOpenProject,
      ),
    );
  }
}

enum _EventDetailTab { overview, discussion, updates, managers }

class _EventDetailContent extends StatefulWidget {
  const _EventDetailContent({
    required this.repository,
    required this.event,
    required this.rsvpEvents,
    required this.onToggleRsvp,
    required this.onOpenProject,
    this.project,
  });

  final MockRepository repository;
  final MockEvent event;
  final MockProject? project;
  final Map<String, bool> rsvpEvents;
  final void Function(String eventId) onToggleRsvp;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;

  @override
  State<_EventDetailContent> createState() => _EventDetailContentState();
}

class _EventDetailContentState extends State<_EventDetailContent> {
  _EventDetailTab selectedTab = _EventDetailTab.overview;

  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final creator = widget.repository.userById(
      event.creatorId ?? mockCurrentUserId,
    );
    final isGoing = widget.rsvpEvents[event.id] ?? false;
    final goingCount = event.going + (isGoing ? 1 : 0);
    final tagItems = _tagItemsForStandaloneEvent(widget.repository, event);
    final invitedUsers = event.invitedUserIds
        .map(widget.repository.userById)
        .whereType<MockUser>()
        .toList();
    final managerIds =
        widget.project?.managerIds ??
        (event.managerIds.isEmpty
            ? [if (event.creatorId != null) event.creatorId!]
            : event.managerIds);
    final managers = managerIds
        .map(widget.repository.userById)
        .whereType<MockUser>()
        .toList();
    final visibilityLabel = widget.project != null
        ? 'Project-linked activity'
        : event.isPrivate
        ? (tagItems.isEmpty
              ? 'Private · personal or invite-only'
              : 'Private · tagged members and invitees can see this')
        : (tagItems.isEmpty
              ? 'Public · visible across the network'
              : 'Public · visible and tagged for discovery');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final tab in _EventDetailTab.values)
                _PageTabChip(
                  label: switch (tab) {
                    _EventDetailTab.overview => 'Overview',
                    _EventDetailTab.discussion => 'Discussion',
                    _EventDetailTab.updates => 'Updates',
                    _EventDetailTab.managers => 'Managers',
                  },
                  selected: selectedTab == tab,
                  onSelected: () => setState(() => selectedTab = tab),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: widget.project == null ? 'Event' : 'Activity',
                          background: _eventSurface(context),
                          foreground: _eventAccent(context),
                          border: _eventBorder(context),
                        ),
                        _InfoChip(
                          label: widget.project == null
                              ? (event.isPrivate ? 'Private' : 'Public')
                              : 'Project activity',
                          background: _statusChipBackground(context),
                          foreground: _statusChipForeground(context),
                          border: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _TagWrap(items: tagItems, alignEnd: true)),
                ],
              ),
              const SizedBox(height: 14),
              Text(event.description),
              const SizedBox(height: 16),
              _MetaTable(
                rows: [
                  if (widget.project != null)
                    ('Project', widget.project!.title),
                  ('Host', _userHandle(creator)),
                  ('Time', event.timeLabel),
                  ('Location', event.location),
                  ('Going', '$goingCount'),
                  ('Visibility', visibilityLabel),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        _refresh(() => widget.onToggleRsvp(event.id)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _eventAccent(context),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isGoing ? 'Going' : 'RSVP'),
                  ),
                  if (widget.project != null)
                    OutlinedButton(
                      onPressed: () => widget.onOpenProject(
                        widget.project!,
                        initialTab: MockProjectTab.events,
                      ),
                      child: const Text('Open Project Activity'),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        switch (selectedTab) {
          _EventDetailTab.overview => _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.project == null
                      ? 'Standalone events stay lightweight: clear purpose, visible tags when needed, and social coordination without pretending the gathering is a long-running project.'
                      : 'Project activity now emphasizes the social rhythm around the work without pretending every gathering is a standalone public event.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget.project == null && invitedUsers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Direct invites',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final user in invitedUsers)
                        _InfoChip(
                          label: _userHandle(user),
                          background: _appSurfaceStrong(context),
                          foreground:
                              Theme.of(context).textTheme.labelLarge?.color ??
                              Colors.white,
                          border: _appBorder(context),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _EventDetailTab.discussion => _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discussion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _MentionComposerField(
                  repository: widget.repository,
                  hintText: widget.project == null
                      ? 'Start an event discussion...'
                      : 'Start a project activity discussion...',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add Comment'),
                  ),
                ),
                const SizedBox(height: 16),
                if (event.discussion.isEmpty)
                  Text(
                    widget.project == null
                        ? 'No event discussion yet.'
                        : 'No activity discussion yet.',
                  )
                else
                  for (final comment in event.discussion) ...[
                    _CommentNode(
                      repository: widget.repository,
                      comment: comment,
                      currentUserId: mockCurrentUserId,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
          _EventDetailTab.updates => _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Updates', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Use updates for schedule shifts, entry notes, and anything followers or attendees should see without digging through discussion.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (event.updates.isEmpty)
                  Text(
                    widget.project == null
                        ? 'No event updates yet.'
                        : 'No activity updates yet.',
                  )
                else
                  for (final update in event.updates) ...[
                    _SearchRow(
                      title: update.title,
                      body: update.body,
                      meta:
                          '${_userHandle(widget.repository.userById(update.authorId))} · ${_relativeTime(update.time)}',
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
          _EventDetailTab.managers => _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Managers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Managers coordinate the event surface itself: updates, invites, and high-level direction.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (managers.isEmpty)
                  const Text('No managers are listed yet.')
                else
                  for (final manager in managers) ...[
                    _SearchRow(
                      title: _userHandle(manager),
                      body: manager.bio,
                      meta: manager.location,
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        },
      ],
    );
  }
}
