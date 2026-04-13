part of '../main.dart';

enum _TaggedFeedFilter { all, threads, events, taggedProjects }

enum _ScopedPeoplePanel { feed, members, moderators }

enum _ScopedCreateAction { thread, project, event }

class _ChannelPage extends StatefulWidget {
  const _ChannelPage({
    required this.repository,
    required this.channel,
    required this.currentUserId,
    required this.leftRail,
    required this.votes,
    required this.governanceVotes,
    required this.removedGovernance,
    required this.subscribedChannels,
    required this.channelNotifications,
    required this.onVote,
    required this.onGovernanceVote,
    required this.onToggleGovernanceRemoval,
    required this.onToggleSubscription,
    required this.onToggleNotifications,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
    required this.onOpenChannel,
    required this.onOpenCommunity,
    required this.onOpenProfile,
    required this.onCreateProject,
    required this.onCreateThread,
    required this.onCreateEvent,
    required this.topNav,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockChannel channel;
  final String currentUserId;
  final Widget leftRail;
  final Map<String, int> votes;
  final Map<String, int> governanceVotes;
  final Set<String> removedGovernance;
  final Map<String, bool> subscribedChannels;
  final Map<String, bool> channelNotifications;
  final void Function(String id, int value) onVote;
  final void Function(String scopeId, String userId, int value)
  onGovernanceVote;
  final void Function(String scopeId, String userId) onToggleGovernanceRemoval;
  final void Function(String channelId) onToggleSubscription;
  final void Function(String channelId) onToggleNotifications;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;
  final ValueChanged<MockChannel> onOpenChannel;
  final ValueChanged<MockCommunity> onOpenCommunity;
  final void Function(MockUser user) onOpenProfile;
  final VoidCallback onCreateProject;
  final VoidCallback onCreateThread;
  final void Function({String? initialChannelId, String? initialCommunityId})
  onCreateEvent;
  final Widget topNav;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<_ChannelPage> {
  _TaggedFeedFilter filter = _TaggedFeedFilter.all;
  _ScopedPeoplePanel peoplePanel = _ScopedPeoplePanel.feed;

  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  Future<void> _openCreateMenu(BuildContext buttonContext) async {
    final canCreateProject = widget.repository.canCreateTaggedProjectInChannel(
      widget.channel,
      widget.currentUserId,
    );
    final canCreateEvent = widget.repository.canCreateEventInChannel(
      widget.channel,
      widget.currentUserId,
    );
    final buttonBox = buttonContext.findRenderObject() as RenderBox;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<_ScopedCreateAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox),
          buttonBox.localToGlobal(
            buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox,
          ),
        ),
        Offset.zero & overlayBox.size,
      ),
      items: [
        PopupMenuItem<_ScopedCreateAction>(
          value: _ScopedCreateAction.thread,
          child: Text('Create Thread'),
        ),
        if (canCreateProject)
          PopupMenuItem<_ScopedCreateAction>(
            value: _ScopedCreateAction.project,
            child: Text('Create Project'),
          ),
        if (canCreateEvent)
          PopupMenuItem<_ScopedCreateAction>(
            value: _ScopedCreateAction.event,
            child: Text('Create Event'),
          ),
      ],
    );

    if (!mounted || selected == null) {
      return;
    }

    switch (selected) {
      case _ScopedCreateAction.thread:
        widget.onCreateThread();
        break;
      case _ScopedCreateAction.project:
        widget.onCreateProject();
        break;
      case _ScopedCreateAction.event:
        widget.onCreateEvent(initialChannelId: widget.channel.id);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.channel;
    final projects = widget.repository.projectsForChannel(channel.id);
    final threads = widget.repository.threadsForChannel(channel.id);
    final events = widget.repository.standaloneEventsForChannel(
      channel.id,
      viewerUserId: widget.currentUserId,
    );
    final isStewardship = widget.repository.isStewardshipChannel(channel);
    final canCreateProject = widget.repository.canCreateTaggedProjectInChannel(
      channel,
      widget.currentUserId,
    );
    final canCreateEvent = widget.repository.canCreateEventInChannel(
      channel,
      widget.currentUserId,
    );
    final feed = _combinedFeedEntries(
      projects: projects,
      threads: threads,
      events: events,
      filter: filter,
    );
    final isBaseMember = channel.memberIds.contains(widget.currentUserId);
    final isSubscribed =
        isBaseMember || (widget.subscribedChannels[channel.id] ?? false);
    final notificationsEnabled =
        widget.channelNotifications[channel.id] ?? isSubscribed;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: channel.name,
      subtitle: isStewardship
          ? 'Stewardship is the public governance channel for platform software and collective-fund execution. It uses the same feed pattern as every other channel, but the board seats here also manage every stewardship-tagged project.'
          : 'Channel pages keep tagged project and thread activity together while still letting each content type stay visually distinct.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      showHeaderText: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: LayoutBuilder(
              builder: (context, _) {
                final headerActions = _PageHeaderActions(
                  primaryLabel: isSubscribed ? 'Subscribed' : '+ Subscribe',
                  onPrimaryPressed: isBaseMember
                      ? null
                      : () => _refresh(
                          () => widget.onToggleSubscription(channel.id),
                        ),
                  notificationsEnabled: notificationsEnabled,
                  canToggleNotifications: isSubscribed,
                  onToggleNotifications: () =>
                      _refresh(() => widget.onToggleNotifications(channel.id)),
                  disabledNotificationHint:
                      'Subscribe to turn channel notifications on.',
                );

                return _PeopleHeaderRow(
                  title: channel.name,
                  actions: headerActions,
                  description: channel.description,
                  note: isStewardship
                      ? 'All users can read and post threads here. Subscription is optional. Only current board members can open stewardship-tagged projects or events, and stewardship-tagged projects automatically mirror the board as project managers.'
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final value in _TaggedFeedFilter.values)
                        _PageTabChip(
                          label: _taggedFeedFilterLabel(value),
                          selected:
                              peoplePanel == _ScopedPeoplePanel.feed &&
                              filter == value,
                          onSelected: () => setState(() {
                            peoplePanel = _ScopedPeoplePanel.feed;
                            filter = value;
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Builder(
                  builder: (buttonContext) => _PageActionChip(
                    label: '+',
                    onPressed: () => _openCreateMenu(buttonContext),
                  ),
                ),
                const SizedBox(width: 12),
                _PageTabChip(
                  label: 'Members',
                  selected: peoplePanel == _ScopedPeoplePanel.members,
                  onSelected: () =>
                      setState(() => peoplePanel = _ScopedPeoplePanel.members),
                ),
                const SizedBox(width: 12),
                _PageTabChip(
                  label: isStewardship ? 'Board' : 'Moderators',
                  selected: peoplePanel == _ScopedPeoplePanel.moderators,
                  onSelected: () => setState(
                    () => peoplePanel = _ScopedPeoplePanel.moderators,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isStewardship && (!canCreateProject || !canCreateEvent)) ...[
            const _SectionCard(
              child: Text(
                'You can post threads here, but only current board members can open stewardship-tagged projects or events.',
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (peoplePanel == _ScopedPeoplePanel.members) ...[
            _buildMembers(channel),
          ] else if (peoplePanel == _ScopedPeoplePanel.moderators) ...[
            _buildModerators(channel),
          ] else if (filter == _TaggedFeedFilter.taggedProjects) ...[
            _ProjectFeedList(
              repository: widget.repository,
              projects: projects,
              votes: widget.votes,
              onVote: widget.onVote,
              onOpenProject: widget.onOpenProject,
              emptyText: isStewardship
                  ? 'No stewardship-tagged projects are visible here yet.'
                  : 'No tagged projects are attached to this channel yet.',
            ),
          ] else ...[
            if (feed.isEmpty)
              const _SectionCard(
                child: Text(
                  'No content matches this channel filter right now.',
                ),
              )
            else
              for (final entry in feed) ...[
                _FeedCard(
                  repository: widget.repository,
                  entry: entry,
                  votes: widget.votes,
                  onVote: widget.onVote,
                  onOpenProject: widget.onOpenProject,
                  onOpenThread: widget.onOpenThread,
                  onOpenStandaloneEvent: widget.onOpenStandaloneEvent,
                ),
                const SizedBox(height: 16),
              ],
          ],
        ],
      ),
    );
  }

  Widget _buildMembers(MockChannel channel) {
    final isStewardship = widget.repository.isStewardshipChannel(channel);
    final members = isStewardship
        ? widget.repository.users
        : channel.memberIds
              .map(widget.repository.userById)
              .whereType<MockUser>()
              .toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            isStewardship
                ? 'Stewardship stays visible to the whole platform. Board members are shown separately in the board tab.'
                : 'Members can participate in discussion and stay discoverable without crowding the header.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            const Text('No channel members are listed yet.')
          else
            for (final member in members) ...[
              _MiniRow(
                title: _userHandle(member),
                body:
                    '${channel.moderatorSeats.any((seat) => seat.userId == member.id) ? (isStewardship ? 'Board member' : 'Moderator') : 'Member'} · ${member.bio}',
                onTap: () => widget.onOpenProfile(member),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Widget _buildModerators(MockChannel channel) {
    final isStewardship = widget.repository.isStewardshipChannel(channel);
    final scopeId = 'channel:${channel.id}';
    final seats = channel.moderatorSeats.where((seat) {
      final activeVote =
          widget.governanceVotes['$scopeId::${seat.userId}'] ?? 0;
      final approval = seat.approveCount + (activeVote == 1 ? 1 : 0);
      final rejection = seat.rejectCount + (activeVote == -1 ? 1 : 0);
      return _approvalPercentFromCounts(
            approval: approval,
            rejection: rejection,
          ) >=
          70;
    }).toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isStewardship ? 'Board Members' : 'Moderators',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isStewardship
                ? 'Board seats stay in place while they maintain at least 70% approval from all platform users. These same seats manage every stewardship-tagged project.'
                : 'Moderators stay in place while they maintain at least 70% approval.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (seats.isEmpty)
            Text(
              isStewardship
                  ? 'No board members currently meet the approval threshold.'
                  : 'No moderators currently meet the approval threshold.',
            )
          else
            for (final seat in seats) ...[
              _GovernanceCard(
                user: widget.repository.userById(seat.userId)!,
                roleLabel: isStewardship ? 'Board member' : 'Moderator',
                approveCount: seat.approveCount,
                rejectCount: seat.rejectCount,
                activeVote:
                    widget.governanceVotes['$scopeId::${seat.userId}'] ?? 0,
                onVote: (value) => _refresh(
                  () => widget.onGovernanceVote(scopeId, seat.userId, value),
                ),
                onOpenProfile: () => widget.onOpenProfile(
                  widget.repository.userById(seat.userId)!,
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _CommunityPage extends StatefulWidget {
  const _CommunityPage({
    required this.repository,
    required this.community,
    required this.currentUserId,
    required this.leftRail,
    required this.votes,
    required this.governanceVotes,
    required this.removedGovernance,
    required this.joinedCommunities,
    required this.communityNotifications,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
    required this.onOpenChannel,
    required this.onOpenCommunity,
    required this.onOpenProfile,
    required this.onCreateThread,
    required this.onCreateEvent,
    required this.topNav,
    required this.onVote,
    required this.onGovernanceVote,
    required this.onToggleGovernanceRemoval,
    required this.onToggleMembership,
    required this.onToggleNotifications,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockCommunity community;
  final String currentUserId;
  final Widget leftRail;
  final Map<String, int> votes;
  final Map<String, int> governanceVotes;
  final Set<String> removedGovernance;
  final Map<String, bool> joinedCommunities;
  final Map<String, bool> communityNotifications;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;
  final ValueChanged<MockChannel> onOpenChannel;
  final ValueChanged<MockCommunity> onOpenCommunity;
  final void Function(MockUser user) onOpenProfile;
  final VoidCallback onCreateThread;
  final void Function({String? initialChannelId, String? initialCommunityId})
  onCreateEvent;
  final Widget topNav;
  final void Function(String id, int value) onVote;
  final void Function(String scopeId, String userId, int value)
  onGovernanceVote;
  final void Function(String scopeId, String userId) onToggleGovernanceRemoval;
  final void Function(String communityId) onToggleMembership;
  final void Function(String communityId) onToggleNotifications;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<_CommunityPage> {
  _TaggedFeedFilter filter = _TaggedFeedFilter.all;
  _ScopedPeoplePanel peoplePanel = _ScopedPeoplePanel.feed;

  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  Future<void> _openCreateMenu(BuildContext buttonContext) async {
    final buttonBox = buttonContext.findRenderObject() as RenderBox;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<_ScopedCreateAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox),
          buttonBox.localToGlobal(
            buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox,
          ),
        ),
        Offset.zero & overlayBox.size,
      ),
      items: const [
        PopupMenuItem<_ScopedCreateAction>(
          value: _ScopedCreateAction.thread,
          child: Text('Create Thread'),
        ),
        PopupMenuItem<_ScopedCreateAction>(
          value: _ScopedCreateAction.event,
          child: Text('Create Event'),
        ),
      ],
    );

    if (!mounted || selected == null) {
      return;
    }

    switch (selected) {
      case _ScopedCreateAction.thread:
        widget.onCreateThread();
        break;
      case _ScopedCreateAction.project:
        break;
      case _ScopedCreateAction.event:
        widget.onCreateEvent(initialCommunityId: widget.community.id);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = widget.community;
    final projects = widget.repository.projectsForCommunity(community.id);
    final threads = widget.repository.threadsForCommunity(community.id);
    final events = widget.repository.standaloneEventsForCommunity(
      community.id,
      viewerUserId: widget.currentUserId,
    );
    final feed = _combinedFeedEntries(
      projects: projects,
      threads: threads,
      events: events,
      filter: filter,
    );
    final isBaseMember = community.memberIds.contains(widget.currentUserId);
    final hasPendingJoin = widget.joinedCommunities[community.id] ?? false;
    final isJoined =
        isBaseMember || (community.openness == 'Open' && hasPendingJoin);
    final notificationsEnabled =
        widget.communityNotifications[community.id] ?? isJoined;
    final membershipLabel = isBaseMember
        ? 'Joined'
        : community.openness == 'Open'
        ? (isJoined ? 'Joined' : '+ Join')
        : (hasPendingJoin ? 'Applied' : '+ Apply');

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: community.name,
      subtitle:
          'Communities stay people-centered and discoverable while keeping tagged projects and discussions visible without collapsing into a single content stream.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      showHeaderText: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: LayoutBuilder(
              builder: (context, _) {
                final headerActions = _PageHeaderActions(
                  primaryLabel: membershipLabel,
                  onPrimaryPressed: isBaseMember
                      ? null
                      : () => _refresh(
                          () => widget.onToggleMembership(community.id),
                        ),
                  notificationsEnabled: notificationsEnabled,
                  canToggleNotifications: isJoined,
                  onToggleNotifications: () => _refresh(
                    () => widget.onToggleNotifications(community.id),
                  ),
                  disabledNotificationHint: community.openness == 'Open'
                      ? 'Join this community to turn notifications on.'
                      : 'Join approval must complete before notifications can turn on.',
                );

                return _PeopleHeaderRow(
                  title: community.name,
                  actions: headerActions,
                  description: community.description,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final value in _TaggedFeedFilter.values)
                        _PageTabChip(
                          label: _taggedFeedFilterLabel(value),
                          selected:
                              peoplePanel == _ScopedPeoplePanel.feed &&
                              filter == value,
                          onSelected: () => setState(() {
                            peoplePanel = _ScopedPeoplePanel.feed;
                            filter = value;
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Builder(
                  builder: (buttonContext) => _PageActionChip(
                    label: '+',
                    onPressed: () => _openCreateMenu(buttonContext),
                  ),
                ),
                const SizedBox(width: 12),
                _PageTabChip(
                  label: 'Members',
                  selected: peoplePanel == _ScopedPeoplePanel.members,
                  onSelected: () =>
                      setState(() => peoplePanel = _ScopedPeoplePanel.members),
                ),
                const SizedBox(width: 12),
                _PageTabChip(
                  label: 'Moderators',
                  selected: peoplePanel == _ScopedPeoplePanel.moderators,
                  onSelected: () => setState(
                    () => peoplePanel = _ScopedPeoplePanel.moderators,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (peoplePanel == _ScopedPeoplePanel.members) ...[
            _buildMembers(community),
          ] else if (peoplePanel == _ScopedPeoplePanel.moderators) ...[
            _buildModerators(community),
          ] else if (filter == _TaggedFeedFilter.taggedProjects) ...[
            _ProjectFeedList(
              repository: widget.repository,
              projects: projects,
              votes: widget.votes,
              onVote: widget.onVote,
              onOpenProject: widget.onOpenProject,
              emptyText:
                  'No tagged projects are attached to this community yet.',
            ),
          ] else ...[
            if (feed.isEmpty)
              const _SectionCard(
                child: Text(
                  'No content matches this community filter right now.',
                ),
              )
            else
              for (final entry in feed) ...[
                _FeedCard(
                  repository: widget.repository,
                  entry: entry,
                  votes: widget.votes,
                  onVote: widget.onVote,
                  onOpenProject: widget.onOpenProject,
                  onOpenThread: widget.onOpenThread,
                  onOpenStandaloneEvent: widget.onOpenStandaloneEvent,
                ),
                const SizedBox(height: 16),
              ],
          ],
        ],
      ),
    );
  }

  Widget _buildMembers(MockCommunity community) {
    final canSeeApplicants =
        community.openness == 'Closed' &&
        community.memberIds.contains(widget.currentUserId);
    final members = community.memberIds
        .map(widget.repository.userById)
        .whereType<MockUser>()
        .toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Members', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            community.openness == 'Closed'
                ? 'Closed communities can review applicants here before bringing them into the visible member list.'
                : 'Members stay visible here without crowding the community header.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _openMembersPage(community),
            child: const Text('Open full roster view'),
          ),
          if (canSeeApplicants && community.membershipRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Pending applications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final request in community.membershipRequests) ...[
              if (widget.repository.userById(request.userId)
                  case final user?) ...[
                _MiniRow(
                  title: _userHandle(user),
                  body: 'Applicant · ${user.bio}',
                  onTap: () => widget.onOpenProfile(user),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
          const SizedBox(height: 16),
          if (members.isEmpty)
            const Text('No community members are listed yet.')
          else
            for (final member in members) ...[
              _MiniRow(
                title: _userHandle(member),
                body:
                    '${community.moderatorSeats.any((seat) => seat.userId == member.id) ? 'Moderator' : 'Member'} · ${member.bio}',
                onTap: () => widget.onOpenProfile(member),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Widget _buildModerators(MockCommunity community) {
    final scopeId = 'community:${community.id}';
    final seats = community.moderatorSeats.where((seat) {
      final activeVote =
          widget.governanceVotes['$scopeId::${seat.userId}'] ?? 0;
      final approval = seat.approveCount + (activeVote == 1 ? 1 : 0);
      final rejection = seat.rejectCount + (activeVote == -1 ? 1 : 0);
      return _approvalPercentFromCounts(
            approval: approval,
            rejection: rejection,
          ) >=
          70;
    }).toList();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Moderators', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Moderators stay in place while they maintain at least 70% approval.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (seats.isEmpty)
            const Text('No moderators currently meet the approval threshold.')
          else
            for (final seat in seats) ...[
              _GovernanceCard(
                user: widget.repository.userById(seat.userId)!,
                roleLabel: 'Moderator',
                approveCount: seat.approveCount,
                rejectCount: seat.rejectCount,
                activeVote:
                    widget.governanceVotes['$scopeId::${seat.userId}'] ?? 0,
                onVote: (value) => _refresh(
                  () => widget.onGovernanceVote(scopeId, seat.userId, value),
                ),
                onOpenProfile: () => widget.onOpenProfile(
                  widget.repository.userById(seat.userId)!,
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  void _openMembersPage(MockCommunity community) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CommunityMembersPage(
          repository: widget.repository,
          community: community,
          currentUserId: widget.currentUserId,
          governanceVotes: widget.governanceVotes,
          onGovernanceVote: widget.onGovernanceVote,
          onOpenProfile: widget.onOpenProfile,
          topNav: widget.topNav,
          leftRail: widget.leftRail,
          onOpenProject: widget.onOpenProject,
          onOpenPlan: widget.onOpenPlan,
          onOpenEvent: widget.onOpenEvent,
        ),
      ),
    );
  }
}

class _CommunityMembersPage extends StatefulWidget {
  const _CommunityMembersPage({
    required this.repository,
    required this.community,
    required this.currentUserId,
    required this.governanceVotes,
    required this.onGovernanceVote,
    required this.onOpenProfile,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockCommunity community;
  final String currentUserId;
  final Map<String, int> governanceVotes;
  final void Function(String scopeId, String userId, int value)
  onGovernanceVote;
  final void Function(MockUser user) onOpenProfile;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CommunityMembersPage> createState() => _CommunityMembersPageState();
}

class _CommunityMembersPageState extends State<_CommunityMembersPage> {
  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final community = widget.community;
    final canSeeApplicants =
        community.openness == 'Closed' &&
        community.memberIds.contains(widget.currentUserId);
    final members = community.memberIds
        .map(widget.repository.userById)
        .whereType<MockUser>()
        .toList();
    final applicantScopeId = 'community-request:${community.id}';

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: '${community.name} Members',
      subtitle:
          'Closed communities show pending applications to members first, then the current membership list below.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canSeeApplicants && community.membershipRequests.isNotEmpty) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Applications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Applications keep the same approval model as other voting surfaces, but they stay visible until the community acts on them.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final request in community.membershipRequests) ...[
                    _GovernanceCard(
                      user: widget.repository.userById(request.userId)!,
                      roleLabel: 'Applicant',
                      approveCount: request.approveCount,
                      rejectCount: request.rejectCount,
                      activeVote:
                          widget
                              .governanceVotes['$applicantScopeId::${request.userId}'] ??
                          0,
                      onVote: (value) => _refresh(
                        () => widget.onGovernanceVote(
                          applicantScopeId,
                          request.userId,
                          value,
                        ),
                      ),
                      onOpenProfile: () => widget.onOpenProfile(
                        widget.repository.userById(request.userId)!,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Members', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final user in members)
                      _LinkedTile(
                        title: _userHandle(user),
                        body: user.location,
                        badges: [
                          widget.community.moderatorSeats.any(
                                (seat) => seat.userId == user.id,
                              )
                              ? 'Moderator'
                              : 'Member',
                        ],
                        onTap: () => widget.onOpenProfile(user),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _taggedFeedFilterLabel(_TaggedFeedFilter value) {
  switch (value) {
    case _TaggedFeedFilter.all:
      return 'All';
    case _TaggedFeedFilter.threads:
      return 'Threads';
    case _TaggedFeedFilter.events:
      return 'Events';
    case _TaggedFeedFilter.taggedProjects:
      return 'Tagged Projects';
  }
}

List<MockFeedEntry> _combinedFeedEntries({
  required List<MockProject> projects,
  required List<MockThread> threads,
  required List<MockEvent> events,
  required _TaggedFeedFilter filter,
}) {
  final entries = <MockFeedEntry>[
    if (filter == _TaggedFeedFilter.all ||
        filter == _TaggedFeedFilter.taggedProjects)
      for (final project in projects)
        MockFeedEntry.project(
          id: project.id,
          lastActivity: project.lastActivity,
        ),
    if (filter == _TaggedFeedFilter.all || filter == _TaggedFeedFilter.threads)
      for (final thread in threads)
        MockFeedEntry.thread(id: thread.id, lastActivity: thread.lastActivity),
    if (filter == _TaggedFeedFilter.all || filter == _TaggedFeedFilter.events)
      for (final event in events)
        MockFeedEntry.event(
          id: event.id,
          lastActivity: event.lastActivity ?? event.createdAt ?? prototypeNow,
        ),
  ];

  entries.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  return entries;
}
