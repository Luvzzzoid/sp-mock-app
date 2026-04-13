part of '../main.dart';

class _FeedColumn extends StatelessWidget {
  const _FeedColumn({
    required this.repository,
    required this.feed,
    required this.scope,
    required this.filter,
    required this.sort,
    required this.votes,
    required this.currentUser,
    required this.onScopeChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onVote,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
  });

  final MockRepository repository;
  final List<MockFeedEntry> feed;
  final MockFeedScope scope;
  final MockFeedFilter filter;
  final MockFeedSort sort;
  final Map<String, int> votes;
  final MockUser currentUser;
  final ValueChanged<MockFeedScope> onScopeChanged;
  final ValueChanged<MockFeedFilter> onFilterChanged;
  final ValueChanged<MockFeedSort> onSortChanged;
  final void Function(String id, int value) onVote;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _centerPaneSurface(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FeedHeader(user: currentUser),
            const SizedBox(height: 12),
            _FilterRow(
              scope: scope,
              filter: filter,
              sort: sort,
              onScopeChanged: onScopeChanged,
              onFilterChanged: onFilterChanged,
              onSortChanged: onSortChanged,
            ),
            const SizedBox(height: 12),
            for (final entry in feed)
              _FeedCard(
                repository: repository,
                entry: entry,
                votes: votes,
                onVote: onVote,
                onOpenProject: onOpenProject,
                onOpenThread: onOpenThread,
                onOpenStandaloneEvent: onOpenStandaloneEvent,
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.user});

  final MockUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Public',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: _titleAccent(context)),
        ),
        const SizedBox(height: 6),
        Text(
          'Public keeps the shared network stream: tagged projects, threads, governance activity, and open events.',
        ),
        const SizedBox(height: 8),
        Text(
          'Signed in as ${user.username}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 12),
        Divider(color: _paneDivider(context), height: 1),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.scope,
    required this.filter,
    required this.sort,
    required this.onScopeChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final MockFeedScope scope;
  final MockFeedFilter filter;
  final MockFeedSort sort;
  final ValueChanged<MockFeedScope> onScopeChanged;
  final ValueChanged<MockFeedFilter> onFilterChanged;
  final ValueChanged<MockFeedSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _EnumDropdown<MockFeedScope>(
          value: scope,
          labelBuilder: _scopeLabel,
          values: MockFeedScope.values,
          onChanged: onScopeChanged,
        ),
        _EnumDropdown<MockFeedFilter>(
          value: filter,
          labelBuilder: _filterLabel,
          values: MockFeedFilter.values,
          onChanged: onFilterChanged,
        ),
        _EnumDropdown<MockFeedSort>(
          value: sort,
          labelBuilder: _sortLabel,
          values: MockFeedSort.values,
          onChanged: onSortChanged,
        ),
      ],
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.repository,
    required this.entry,
    required this.votes,
    required this.onVote,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
  });

  final MockRepository repository;
  final MockFeedEntry entry;
  final Map<String, int> votes;
  final void Function(String id, int value) onVote;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;

  @override
  Widget build(BuildContext context) {
    if (entry.kind == MockFeedEntryKind.project) {
      final project = repository.projectById(entry.id)!;
      final latestUpdate = repository.latestUpdateForProject(project.id);
      return _ProjectCard(
        repository: repository,
        project: project,
        votes: votes,
        onVote: onVote,
        onOpenProject: onOpenProject,
        previewBody: latestUpdate?.body,
        previewLabel: latestUpdate == null
            ? null
            : 'Latest update - ${_relativeTime(latestUpdate.time)}',
        targetUpdateId: latestUpdate?.id,
      );
    }

    if (entry.kind == MockFeedEntryKind.event) {
      final event = repository.standaloneEventById(entry.id)!;
      return _StandaloneEventCard(
        repository: repository,
        event: event,
        onOpenEvent: onOpenStandaloneEvent,
      );
    }

    final thread = repository.threadById(entry.id)!;
    return _ThreadCard(
      repository: repository,
      thread: thread,
      votes: votes,
      onVote: onVote,
      onOpenThread: onOpenThread,
    );
  }
}

class _ProjectFeedList extends StatelessWidget {
  const _ProjectFeedList({
    required this.repository,
    required this.projects,
    required this.votes,
    required this.onVote,
    required this.onOpenProject,
    required this.emptyText,
  });

  final MockRepository repository;
  final List<MockProject> projects;
  final Map<String, int> votes;
  final void Function(String id, int value) onVote;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return _SectionCard(child: Text(emptyText));
    }

    return Column(
      children: [
        for (final project in projects) ...[
          _ProjectCard(
            repository: repository,
            project: project,
            votes: votes,
            onVote: onVote,
            onOpenProject: onOpenProject,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _InteractiveFeedRow extends StatelessWidget {
  const _InteractiveFeedRow({
    required this.background,
    required this.onTap,
    required this.child,
  });

  final Color background;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        hoverColor: _rowHoverOverlay(context),
        splashColor: _rowHoverOverlay(context),
        highlightColor: _rowHoverOverlay(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _feedDivider(context))),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.repository,
    required this.project,
    required this.votes,
    required this.onVote,
    required this.onOpenProject,
    this.previewBody,
    this.previewLabel,
    this.targetUpdateId,
  });

  final MockRepository repository;
  final MockProject project;
  final Map<String, int> votes;
  final void Function(String id, int value) onVote;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final String? previewBody;
  final String? previewLabel;
  final String? targetUpdateId;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _isDarkTheme(context);
    final stageStyle = stageStyleForMode(project.stage, isDarkMode: isDarkMode);
    final voteTotal = project.awarenessCount + (votes[project.id] ?? 0);
    final feedChipStyle = _feedPrimaryChipStyleForProject(project, context);
    final bodyText = previewBody ?? project.summary;

    return _InteractiveFeedRow(
      background: _threadSurface(context),
      onTap: () {
        if (targetUpdateId != null) {
          repository.setPendingProjectUpdateTarget(project.id, targetUpdateId!);
          onOpenProject(project, initialTab: MockProjectTab.updates);
          return;
        }
        onOpenProject(project);
      },
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
                      label: feedChipStyle.label,
                      background: feedChipStyle.background,
                      foreground: feedChipStyle.foreground,
                      border: Colors.transparent,
                    ),
                    _InfoChip(
                      label: stageStyle.label,
                      background: stageStyle.soft,
                      foreground: stageStyle.accent,
                      border: Colors.transparent,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TagWrap(
                  items: _tagItemsForProject(repository, project),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(project.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          if (previewLabel != null) ...[
            Text(previewLabel!, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
          ],
          _TaggedBodyText(repository: repository, text: bodyText),
          if (project.fund != null) ...[
            const SizedBox(height: 10),
            Text(
              project.fund!.title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: project.fund!.raised / project.fund!.goal,
              minHeight: 8,
              backgroundColor: _progressTrack(context),
              color: _fundProgressColor(
                context,
                project.fund!.raised / project.fund!.goal,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 4),
            Text(
              '${_money(project.fund!.raised)} of ${_money(project.fund!.goal)} - ${project.fund!.deadlineLabel}',
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _VoteStrip(
                id: project.id,
                count: voteTotal,
                activeVote: votes[project.id] ?? 0,
                onVote: (previewId, direction) => onVote(previewId, direction),
              ),
              const SizedBox(width: 8),
              _CountPill(
                icon: Icons.mode_comment_outlined,
                label: '${project.comments}',
                onTap: () => onOpenProject(
                  project,
                  initialTab: MockProjectTab.discussion,
                ),
              ),
              const Spacer(),
              Text(
                '${project.memberIds.length} members - ${_relativeTime(project.lastActivity)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({
    required this.repository,
    required this.thread,
    required this.votes,
    required this.onVote,
    required this.onOpenThread,
  });

  final MockRepository repository;
  final MockThread thread;
  final Map<String, int> votes;
  final void Function(String id, int value) onVote;
  final void Function(MockThread thread) onOpenThread;

  @override
  Widget build(BuildContext context) {
    final voteTotal = thread.awarenessCount + (votes[thread.id] ?? 0);
    final author = repository.userById(thread.authorId);
    final chipStyle = _feedThreadChipStyle(context);

    return _InteractiveFeedRow(
      background: _threadSurface(context),
      onTap: () => onOpenThread(thread),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoChip(
                label: 'Thread',
                background: chipStyle.background,
                foreground: chipStyle.foreground,
                border: Colors.transparent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TagWrap(
                  items: _tagItemsForThread(repository, thread),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(thread.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          _TaggedBodyText(repository: repository, text: thread.body),
          const SizedBox(height: 12),
          Row(
            children: [
              _VoteStrip(
                id: thread.id,
                count: voteTotal,
                activeVote: votes[thread.id] ?? 0,
                onVote: (previewId, direction) => onVote(previewId, direction),
              ),
              const SizedBox(width: 8),
              _CountPill(
                icon: Icons.mode_comment_outlined,
                label: '${thread.replyCount}',
                onTap: () => onOpenThread(thread),
              ),
              const Spacer(),
              Text(
                '${author?.username ?? 'unknown'} - ${_relativeTime(thread.lastActivity)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StandaloneEventCard extends StatelessWidget {
  const _StandaloneEventCard({
    required this.repository,
    required this.event,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockEvent event;
  final void Function(MockEvent event) onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final creator = repository.userById(event.creatorId ?? mockCurrentUserId);
    final tagItems = _tagItemsForStandaloneEvent(repository, event);

    return _InteractiveFeedRow(
      background: _threadSurface(context),
      onTap: () => onOpenEvent(event),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    label: 'Event',
                    background: _eventSurface(context),
                    foreground: _eventAccent(context),
                    border: _eventBorder(context),
                  ),
                  _InfoChip(
                    label: event.isPrivate ? 'Private' : 'Public',
                    background: _statusChipBackground(context),
                    foreground: _statusChipForeground(context),
                    border: Colors.transparent,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(child: _TagWrap(items: tagItems, alignEnd: true)),
            ],
          ),
          const SizedBox(height: 10),
          Text(event.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          _TaggedBodyText(repository: repository, text: event.description),
          const SizedBox(height: 10),
          Text(
            '${event.timeLabel} - ${event.location}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CountPill(
                icon: Icons.event_available_outlined,
                label: '${event.going} going',
                onTap: () => onOpenEvent(event),
              ),
              if (event.invitedUserIds.isNotEmpty) ...[
                const SizedBox(width: 8),
                _CountPill(
                  icon: Icons.mail_outline_rounded,
                  label: '${event.invitedUserIds.length} invites',
                  onTap: () => onOpenEvent(event),
                ),
              ],
              const Spacer(),
              Text(
                '${_userHandle(creator)} - ${_relativeTime(event.lastActivity ?? event.createdAt ?? prototypeNow)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<_TagChipData> _tagItemsForProject(
  MockRepository repository,
  MockProject project,
) {
  return [
    ...project.channelIds
        .map((id) => repository.channelById(id)?.name)
        .whereType<String>()
        .map((label) => _TagChipData(label: label, kind: _TagChipKind.channel)),
    ...project.communityIds
        .map((id) => repository.communityById(id)?.name)
        .whereType<String>()
        .map(
          (label) => _TagChipData(label: label, kind: _TagChipKind.community),
        ),
  ];
}

List<_TagChipData> _tagItemsForThread(
  MockRepository repository,
  MockThread thread,
) {
  return [
    ...thread.channelIds
        .map((id) => repository.channelById(id)?.name)
        .whereType<String>()
        .map((label) => _TagChipData(label: label, kind: _TagChipKind.channel)),
    ...thread.communityIds
        .map((id) => repository.communityById(id)?.name)
        .whereType<String>()
        .map(
          (label) => _TagChipData(label: label, kind: _TagChipKind.community),
        ),
  ];
}

String _scopeLabel(MockFeedScope value) {
  switch (value) {
    case MockFeedScope.home:
      return 'Home';
    case MockFeedScope.mine:
      return 'All';
    case MockFeedScope.local:
      return 'Local';
  }
}

String _filterLabel(MockFeedFilter value) {
  switch (value) {
    case MockFeedFilter.all:
      return 'All';
    case MockFeedFilter.projects:
      return 'Projects';
    case MockFeedFilter.threads:
      return 'Threads';
    case MockFeedFilter.events:
      return 'Events';
  }
}

String _sortLabel(MockFeedSort value) {
  switch (value) {
    case MockFeedSort.latest:
      return 'Latest';
    case MockFeedSort.votes:
      return 'Top Votes';
    case MockFeedSort.comments:
      return 'Most Comments';
  }
}

class _FeedPrimaryChipStyle {
  const _FeedPrimaryChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

_FeedPrimaryChipStyle _feedPrimaryChipStyleForProject(
  MockProject project,
  BuildContext context,
) {
  final isService = project.type == MockProjectType.service;
  final label = isService ? 'Service' : 'Production';

  if (_isDarkTheme(context)) {
    return _FeedPrimaryChipStyle(
      label: label,
      background: isService ? MockPalette.orangeDark : MockPalette.greenDark,
      foreground: isService ? MockPalette.orangeSoft : MockPalette.greenSoft,
    );
  }

  return _FeedPrimaryChipStyle(
    label: label,
    background: isService ? MockPalette.orangeDark : MockPalette.greenDark,
    foreground: isService ? const Color(0xFFFFE2BE) : MockPalette.greenSoft,
  );
}

_FeedPrimaryChipStyle _feedThreadChipStyle(BuildContext context) {
  if (_isDarkTheme(context)) {
    return const _FeedPrimaryChipStyle(
      label: 'Thread',
      background: Color(0xFF203B63),
      foreground: Color(0xFFA9CBFF),
    );
  }

  return const _FeedPrimaryChipStyle(
    label: 'Thread',
    background: Color(0xFF1F3A63),
    foreground: Color(0xFFA9CBFF),
  );
}

List<_TagChipData> _tagItemsForStandaloneEvent(
  MockRepository repository,
  MockEvent event,
) {
  return [
    for (final channelId in event.channelIds)
      if (repository.channelById(channelId) != null)
        _TagChipData(
          label: repository.channelById(channelId)!.name,
          kind: _TagChipKind.channel,
        ),
    for (final communityId in event.communityIds)
      if (repository.communityById(communityId) != null)
        _TagChipData(
          label: repository.communityById(communityId)!.name,
          kind: _TagChipKind.community,
        ),
  ];
}
