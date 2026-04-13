part of '../main.dart';

enum _ProfilePageTab { activity, projectRoles, channelsCommunities }

String _profilePageTabLabel(_ProfilePageTab value) {
  switch (value) {
    case _ProfilePageTab.activity:
      return 'Activity';
    case _ProfilePageTab.projectRoles:
      return 'Project Roles';
    case _ProfilePageTab.channelsCommunities:
      return 'Channels/Communities';
  }
}

List<_PersonalFeedItem> _profileActivityItems({
  required MockRepository repository,
  required String profileUserId,
  required String viewerUserId,
  required void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject,
  required void Function(MockThread thread) onOpenThread,
  required void Function(MockEvent event) onOpenStandaloneEvent,
  required void Function(MockPlan plan) onOpenPlan,
  required void Function(MockProject project, MockEvent event) onOpenEvent,
}) {
  final publicActivities = _personalPublicActivities(
    repository: repository,
    viewerUserId: viewerUserId,
    onOpenProject: onOpenProject,
    onOpenThread: onOpenThread,
    onOpenStandaloneEvent: onOpenStandaloneEvent,
    onOpenPlan: onOpenPlan,
    onOpenEvent: onOpenEvent,
    actorUserIds: {profileUserId},
  );

  final items = <_PersonalFeedItem>[
    for (final post in repository.personalPosts)
      if (post.authorId == profileUserId)
        _PersonalFeedItem.timeline(
          MockPersonalTimelineEntry.post(
            post: post,
            lastActivity: post.createdAt,
          ),
        ),
    for (final activity in publicActivities) _PersonalFeedItem.public(activity),
    for (final event in repository.standaloneEvents)
      if (event.creatorId == profileUserId &&
          repository.canViewStandaloneEvent(event, viewerUserId: viewerUserId))
        _PersonalFeedItem.public(
          _personalActivityForStandaloneEventEntry(
            repository: repository,
            event: event,
            onOpenEvent: onOpenStandaloneEvent,
          ),
        ),
  ]..sort((left, right) => right.time.compareTo(left.time));

  return items;
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({
    required this.repository,
    required this.user,
    required this.currentUserId,
    required this.showLocation,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
    required this.onOpenChannel,
    required this.onOpenCommunity,
    required this.onOpenConversation,
    required this.onOpenProfile,
    required this.onToggleFollow,
    required this.topNav,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockUser user;
  final String currentUserId;
  final bool showLocation;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;
  final ValueChanged<MockChannel> onOpenChannel;
  final ValueChanged<MockCommunity> onOpenCommunity;
  final void Function(MockUser user) onOpenConversation;
  final void Function(MockUser user) onOpenProfile;
  final VoidCallback? onToggleFollow;
  final Widget topNav;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  _ProfilePageTab selectedTab = _ProfilePageTab.activity;
  _PersonalTimelineFilter activityFilter = _PersonalTimelineFilter.all;

  void _openSharedComment(MockPersonalCommentShare share) {
    switch (share.sourceKind) {
      case MockCommentShareSourceKind.project:
        final project = widget.repository.projectById(share.sourceId);
        if (project == null) {
          return;
        }
        widget.repository.setPendingProjectCommentTarget(
          project.id,
          share.commentId,
        );
        widget.onOpenProject(project, initialTab: MockProjectTab.discussion);
        return;
      case MockCommentShareSourceKind.thread:
        final thread = widget.repository.threadById(share.sourceId);
        if (thread == null) {
          return;
        }
        widget.repository.setPendingThreadCommentTarget(
          thread.id,
          share.commentId,
        );
        widget.onOpenThread(thread);
        return;
    }
  }

  void _openPersonalPost(MockPersonalPost post) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PersonalPostDetailPage(
          repository: widget.repository,
          post: post,
          currentUserId: widget.currentUserId,
          topNav: widget.topNav,
          leftRail: widget.leftRail,
          onOpenProject: widget.onOpenProject,
          onOpenPlan: widget.onOpenPlan,
          onOpenEvent: widget.onOpenEvent,
        ),
      ),
    );
  }

  void _showUserListDialog({
    required String title,
    required List<MockUser> users,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: users.isEmpty
              ? const Text('No one is visible in this list yet.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in users) ...[
                        _MiniRow(
                          title: _userHandle(item),
                          body: item.bio,
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            widget.onOpenProfile(item);
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final projects = widget.repository.projects
        .where(
          (item) =>
              item.authorId == user.id ||
              item.managerIds.contains(user.id) ||
              item.memberIds.contains(user.id),
        )
        .toList();
    final channels = widget.repository.channels
        .where(
          (item) =>
              item.memberIds.contains(user.id) ||
              item.moderatorSeats.any((seat) => seat.userId == user.id),
        )
        .toList();
    final communities = widget.repository.communities
        .where(
          (item) =>
              item.memberIds.contains(user.id) ||
              item.moderatorSeats.any((seat) => seat.userId == user.id),
        )
        .toList();
    final moderatedChannels = widget.repository.channels
        .where(
          (item) => item.moderatorSeats.any((seat) => seat.userId == user.id),
        )
        .toList();
    final moderatedCommunities = widget.repository.communities
        .where(
          (item) => item.moderatorSeats.any((seat) => seat.userId == user.id),
        )
        .toList();
    final following = widget.repository.followingForUser(user.id);
    final followers = widget.repository.followersForUser(user.id);
    final isFollowing = widget.repository.isFollowing(
      widget.currentUserId,
      user.id,
    );
    final activityItems = _profileActivityItems(
      repository: widget.repository,
      profileUserId: user.id,
      viewerUserId: widget.currentUserId,
      onOpenProject: widget.onOpenProject,
      onOpenThread: widget.onOpenThread,
      onOpenStandaloneEvent: widget.onOpenStandaloneEvent,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
    );
    final visibleActivities = activityItems
        .where((item) => _matchesPersonalTimelineFilter(item, activityFilter))
        .toList();

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: _userHandle(user),
      subtitle:
          'Profiles stay activity-based and visibility-aware, while role badges remain descriptive rather than magical status markers.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildUserAvatar(user, radius: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userHandle(user),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.showLocation
                                ? user.location
                                : 'Location hidden',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.bio),
                if (user.id != widget.currentUserId) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: () => widget.onOpenConversation(user),
                        child: const Text('Message'),
                      ),
                      ElevatedButton(
                        onPressed: widget.onToggleFollow == null
                            ? null
                            : () => setState(() => widget.onToggleFollow!()),
                        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: '${following.length} following',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                      onTap: () => _showUserListDialog(
                        title: 'Following',
                        users: following,
                      ),
                    ),
                    _InfoChip(
                      label: '${followers.length} followers',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                      onTap: () => _showUserListDialog(
                        title: 'Followers',
                        users: followers,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final value in _ProfilePageTab.values)
                  _PageTabChip(
                    label: _profilePageTabLabel(value),
                    selected: selectedTab == value,
                    onSelected: () => setState(() => selectedTab = value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (selectedTab == _ProfilePageTab.activity) ...[
            _SectionCard(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final value in _PersonalTimelineFilter.values)
                    _PageTabChip(
                      label: _personalTimelineFilterLabel(value),
                      selected: activityFilter == value,
                      onSelected: () => setState(() => activityFilter = value),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (visibleActivities.isEmpty)
              const _SectionCard(
                child: Text('No activity matches this view yet.'),
              )
            else
              for (final item in visibleActivities) ...[
                _buildPersonalTimelineItemCard(
                  repository: widget.repository,
                  item: item,
                  currentUserId: widget.currentUserId,
                  onOpenPersonalPost: _openPersonalPost,
                  onOpenSharedComment: _openSharedComment,
                  onOpenStandaloneEvent: widget.onOpenStandaloneEvent,
                  onDeletePost: user.id == widget.currentUserId
                      ? (postId) => setState(
                          () => widget.repository.deletePersonalPost(postId),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
              ],
          ] else if (selectedTab == _ProfilePageTab.projectRoles) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Roles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (projects.isEmpty)
                    const Text('No current project roles.')
                  else
                    for (final item in projects) ...[
                      _MiniRow(
                        title: item.title,
                        body:
                            '${item.authorId == user.id
                                ? 'Manager'
                                : widget.repository.isProjectManager(item, user.id)
                                ? 'Manager'
                                : 'Member'} · ${item.summary}',
                        onTap: () => widget.onOpenProject(item),
                      ),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ] else ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Channels',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (channels.isEmpty)
                    const Text('No current channel memberships.')
                  else
                    for (final item in channels) ...[
                      _MiniRow(
                        title: item.name,
                        body:
                            '${moderatedChannels.any((channel) => channel.id == item.id) ? (item.id == 'stewardship' ? 'Board member' : 'Moderator') : 'Member'} · ${item.description}',
                        onTap: () => widget.onOpenChannel(item),
                      ),
                      const SizedBox(height: 8),
                    ],
                  const SizedBox(height: 8),
                  Text(
                    'Communities',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (communities.isEmpty)
                    const Text('No current community memberships.')
                  else
                    for (final item in communities) ...[
                      _MiniRow(
                        title: item.name,
                        body:
                            '${moderatedCommunities.any((community) => community.id == item.id) ? 'Moderator' : 'Member'} · ${item.description}',
                        onTap: () => widget.onOpenCommunity(item),
                      ),
                      const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
