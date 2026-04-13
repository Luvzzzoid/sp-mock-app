part of '../main.dart';

enum _PersonalTimelineFilter { all, public, posts, events }

String _personalTimelineFilterLabel(_PersonalTimelineFilter value) {
  switch (value) {
    case _PersonalTimelineFilter.all:
      return 'All';
    case _PersonalTimelineFilter.public:
      return 'Public';
    case _PersonalTimelineFilter.posts:
      return 'Post';
    case _PersonalTimelineFilter.events:
      return 'Event';
  }
}

bool _matchesPersonalTimelineFilter(
  _PersonalFeedItem item,
  _PersonalTimelineFilter filter,
) {
  switch (filter) {
    case _PersonalTimelineFilter.all:
      return true;
    case _PersonalTimelineFilter.public:
      if (item.publicActivity != null) {
        return item.publicActivity!.subject !=
            _PersonalPublicActivitySubject.event;
      }
      return item.timelineEntry?.kind ==
          MockPersonalTimelineEntryKind.sharedComment;
    case _PersonalTimelineFilter.posts:
      return item.timelineEntry?.kind == MockPersonalTimelineEntryKind.post;
    case _PersonalTimelineFilter.events:
      return item.publicActivity?.subject ==
              _PersonalPublicActivitySubject.event ||
          item.timelineEntry?.kind == MockPersonalTimelineEntryKind.event;
  }
}

class _PersonalFeedItem {
  _PersonalFeedItem.timeline(MockPersonalTimelineEntry entry)
    : timelineEntry = entry,
      publicActivity = null,
      time = entry.lastActivity;

  _PersonalFeedItem.public(_PersonalPublicActivity activity)
    : timelineEntry = null,
      publicActivity = activity,
      time = activity.time;

  final DateTime time;
  final MockPersonalTimelineEntry? timelineEntry;
  final _PersonalPublicActivity? publicActivity;
}

enum _PersonalPublicActivitySubject { thread, project, event }

class _PersonalPublicActivity {
  _PersonalPublicActivity({
    required this.actionLabel,
    required this.subject,
    required this.title,
    required this.body,
    required this.meta,
    required this.author,
    required this.authorHandle,
    required this.time,
    required this.onTap,
    this.thread,
    this.project,
    this.event,
    this.showEventVisibilityChip = false,
  });

  final String actionLabel;
  final _PersonalPublicActivitySubject subject;
  final String title;
  final String body;
  final String meta;
  final MockUser? author;
  final String authorHandle;
  final DateTime time;
  final VoidCallback onTap;
  final MockThread? thread;
  final MockProject? project;
  final MockEvent? event;
  final bool showEventVisibilityChip;
}

List<_PersonalPublicActivity> _personalPublicActivities({
  required MockRepository repository,
  required String viewerUserId,
  required void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject,
  required void Function(MockThread thread) onOpenThread,
  required void Function(MockEvent event) onOpenStandaloneEvent,
  required void Function(MockPlan plan) onOpenPlan,
  required void Function(MockProject project, MockEvent event) onOpenEvent,
  Set<String>? actorUserIds,
}) {
  final visibleActorIds =
      actorUserIds ??
      repository.followingForUser(viewerUserId).map((user) => user.id).toSet();
  if (visibleActorIds.isEmpty) {
    return const <_PersonalPublicActivity>[];
  }

  final activities = <_PersonalPublicActivity>[];

  for (final thread in repository.threads) {
    final author = repository.userById(thread.authorId);
    if (author != null && visibleActorIds.contains(thread.authorId)) {
      activities.add(
        _PersonalPublicActivity(
          actionLabel: 'Created',
          subject: _PersonalPublicActivitySubject.thread,
          title: thread.title,
          body: thread.body,
          meta: _personalActivityScopeLabel(
            repository: repository,
            channelIds: thread.channelIds,
            communityIds: thread.communityIds,
            fallback: 'Public thread',
          ),
          author: author,
          authorHandle: author.username,
          time: thread.createdAt,
          onTap: () => onOpenThread(thread),
          thread: thread,
        ),
      );
    }

    for (final comment in _flattenActivityComments(
      repository.commentsForThread(thread.id),
    )) {
      final commentAuthor = repository.userById(comment.authorId);
      if (commentAuthor == null ||
          !visibleActorIds.contains(comment.authorId)) {
        continue;
      }
      activities.add(
        _PersonalPublicActivity(
          actionLabel: 'Commented',
          subject: _PersonalPublicActivitySubject.thread,
          title: thread.title,
          body: comment.body,
          meta: _personalActivityScopeLabel(
            repository: repository,
            channelIds: thread.channelIds,
            communityIds: thread.communityIds,
            fallback: 'Public discussion',
          ),
          author: commentAuthor,
          authorHandle: commentAuthor.username,
          time: comment.time,
          onTap: () {
            repository.setPendingThreadCommentTarget(thread.id, comment.id);
            onOpenThread(thread);
          },
          thread: thread,
        ),
      );
    }
  }

  for (final project in repository.projects) {
    final author = repository.userById(project.authorId);
    if (author != null && visibleActorIds.contains(project.authorId)) {
      activities.add(
        _PersonalPublicActivity(
          actionLabel: 'Created',
          subject: _PersonalPublicActivitySubject.project,
          title: project.title,
          body: project.summary,
          meta: _personalActivityScopeLabel(
            repository: repository,
            channelIds: project.channelIds,
            communityIds: project.communityIds,
            fallback: project.locationLabel,
          ),
          author: author,
          authorHandle: author.username,
          time: project.createdAt,
          onTap: () => onOpenProject(project),
          project: project,
        ),
      );
    }

    for (final update in project.updates) {
      for (final comment in _flattenActivityComments(
        repository.commentsForUpdate(update.id),
      )) {
        final commentAuthor = repository.userById(comment.authorId);
        if (commentAuthor == null ||
            !visibleActorIds.contains(comment.authorId)) {
          continue;
        }
        activities.add(
          _PersonalPublicActivity(
            actionLabel: 'Commented',
            subject: _PersonalPublicActivitySubject.project,
            title: project.title,
            body: comment.body,
            meta: 'Update: ${update.title}',
            author: commentAuthor,
            authorHandle: commentAuthor.username,
            time: comment.time,
            onTap: () {
              repository.setPendingProjectUpdateTarget(project.id, update.id);
              onOpenProject(project, initialTab: MockProjectTab.updates);
            },
            project: project,
          ),
        );
      }
    }

    for (final comment in _flattenActivityComments(
      repository.commentsForProject(project.id),
    )) {
      final commentAuthor = repository.userById(comment.authorId);
      if (commentAuthor == null ||
          !visibleActorIds.contains(comment.authorId)) {
        continue;
      }
      activities.add(
        _PersonalPublicActivity(
          actionLabel: 'Commented',
          subject: _PersonalPublicActivitySubject.project,
          title: project.title,
          body: comment.body,
          meta: 'Main discussion',
          author: commentAuthor,
          authorHandle: commentAuthor.username,
          time: comment.time,
          onTap: () {
            repository.setPendingProjectCommentTarget(project.id, comment.id);
            onOpenProject(project, initialTab: MockProjectTab.discussion);
          },
          project: project,
        ),
      );
    }

    for (final event in project.events) {
      final creator = event.creatorId == null
          ? null
          : repository.userById(event.creatorId!);
      if (creator != null && visibleActorIds.contains(creator.id)) {
        activities.add(
          _PersonalPublicActivity(
            actionLabel: 'Created',
            subject: _PersonalPublicActivitySubject.event,
            title: event.title,
            body: event.description,
            meta: project.title,
            author: creator,
            authorHandle: creator.username,
            time: event.createdAt ?? event.lastActivity ?? prototypeNow,
            onTap: () => onOpenEvent(project, event),
            event: event,
          ),
        );
      }

      for (final comment in _flattenActivityComments(event.discussion)) {
        final commentAuthor = repository.userById(comment.authorId);
        if (commentAuthor == null ||
            !visibleActorIds.contains(comment.authorId)) {
          continue;
        }
        activities.add(
          _PersonalPublicActivity(
            actionLabel: 'Commented',
            subject: _PersonalPublicActivitySubject.event,
            title: event.title,
            body: comment.body,
            meta: project.title,
            author: commentAuthor,
            authorHandle: commentAuthor.username,
            time: comment.time,
            onTap: () => onOpenEvent(project, event),
            event: event,
          ),
        );
      }
    }
  }

  for (final event in repository.standaloneEvents) {
    if (!repository.canViewStandaloneEvent(event, viewerUserId: viewerUserId)) {
      continue;
    }
    for (final comment in _flattenActivityComments(event.discussion)) {
      final commentAuthor = repository.userById(comment.authorId);
      if (commentAuthor == null ||
          !visibleActorIds.contains(comment.authorId)) {
        continue;
      }
      activities.add(
        _PersonalPublicActivity(
          actionLabel: 'Commented',
          subject: _PersonalPublicActivitySubject.event,
          title: event.title,
          body: comment.body,
          meta: '${event.timeLabel} · ${event.location}',
          author: commentAuthor,
          authorHandle: commentAuthor.username,
          time: comment.time,
          onTap: () => onOpenStandaloneEvent(event),
          event: event,
          showEventVisibilityChip: true,
        ),
      );
    }
  }

  for (final plan in repository.plans) {
    final project = repository.projectById(plan.projectId);
    if (project == null) {
      continue;
    }

    for (final comment in _flattenActivityComments(plan.discussion)) {
      final commentAuthor = repository.userById(comment.authorId);
      if (commentAuthor == null ||
          !visibleActorIds.contains(comment.authorId)) {
        continue;
      }
      activities.add(
        _PersonalPublicActivity(
          actionLabel: 'Commented',
          subject: _PersonalPublicActivitySubject.project,
          title: project.title,
          body: comment.body,
          meta: 'Plan: ${plan.title}',
          author: commentAuthor,
          authorHandle: commentAuthor.username,
          time: comment.time,
          onTap: () => onOpenPlan(plan),
          project: project,
        ),
      );
    }
  }

  activities.sort((left, right) => right.time.compareTo(left.time));
  return activities;
}

Iterable<MockComment> _flattenActivityComments(
  List<MockComment> comments,
) sync* {
  for (final comment in comments) {
    yield comment;
    yield* _flattenActivityComments(comment.replies);
  }
}

String _personalActivityScopeLabel({
  required MockRepository repository,
  required List<String> channelIds,
  required List<String> communityIds,
  required String fallback,
}) {
  final labels = <String>[
    for (final channelId in channelIds)
      if (repository.channelById(channelId) case final channel?) channel.name,
    for (final communityId in communityIds)
      if (repository.communityById(communityId) case final community?)
        community.name,
  ];
  if (labels.isEmpty) {
    return fallback;
  }
  return labels.join(' · ');
}

_PersonalPublicActivity _personalActivityForSharedComment({
  required MockRepository repository,
  required MockPersonalCommentShare share,
  required VoidCallback onOpenOriginal,
}) {
  final authorHandle =
      repository.userById(share.authorId)?.username ?? 'unknown';
  switch (share.sourceKind) {
    case MockCommentShareSourceKind.project:
      final project = repository.projectById(share.sourceId);
      final comment = repository.projectCommentById(
        share.sourceId,
        share.commentId,
      );
      return _PersonalPublicActivity(
        actionLabel: 'Commented',
        subject: _PersonalPublicActivitySubject.project,
        title: project?.title ?? 'Unknown project',
        body: comment?.body ?? 'Original comment is no longer available.',
        meta: share.caption.trim().isNotEmpty
            ? share.caption
            : 'Main discussion',
        author: repository.userById(share.authorId),
        authorHandle: authorHandle,
        time: share.sharedAt,
        onTap: onOpenOriginal,
        project: project,
      );
    case MockCommentShareSourceKind.thread:
      final thread = repository.threadById(share.sourceId);
      final comment = repository.threadCommentById(
        share.sourceId,
        share.commentId,
      );
      return _PersonalPublicActivity(
        actionLabel: 'Commented',
        subject: _PersonalPublicActivitySubject.thread,
        title: thread?.title ?? 'Unknown thread',
        body: comment?.body ?? 'Original comment is no longer available.',
        meta: thread == null
            ? 'Public thread'
            : _personalActivityScopeLabel(
                repository: repository,
                channelIds: thread.channelIds,
                communityIds: thread.communityIds,
                fallback: 'Public thread',
              ),
        author: repository.userById(share.authorId),
        authorHandle: authorHandle,
        time: share.sharedAt,
        onTap: onOpenOriginal,
        thread: thread,
      );
  }
}

_PersonalPublicActivity _personalActivityForStandaloneEventEntry({
  required MockRepository repository,
  required MockEvent event,
  required void Function(MockEvent event) onOpenEvent,
}) {
  final creator = repository.userById(event.creatorId ?? mockCurrentUserId);
  return _PersonalPublicActivity(
    actionLabel: 'Created',
    subject: _PersonalPublicActivitySubject.event,
    title: event.title,
    body: event.description,
    meta: '${event.timeLabel} · ${event.location}',
    author: creator,
    authorHandle: creator?.username ?? 'unknown',
    time: event.lastActivity ?? event.createdAt ?? prototypeNow,
    onTap: () => onOpenEvent(event),
    event: event,
    showEventVisibilityChip: true,
  );
}

class _PersonalFeedPage extends StatefulWidget {
  const _PersonalFeedPage({
    required this.repository,
    required this.currentUserId,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProfile,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final String currentUserId;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockUser user) onOpenProfile;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_PersonalFeedPage> createState() => _PersonalFeedPageState();
}

class _PersonalFeedPageState extends State<_PersonalFeedPage> {
  final TextEditingController _composerController = TextEditingController();
  _PersonalTimelineFilter filter = _PersonalTimelineFilter.all;

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    final timelineEntries = widget.repository.personalTimelineForUser(
      widget.currentUserId,
    );
    final publicActivities = _personalPublicActivities(
      repository: widget.repository,
      viewerUserId: widget.currentUserId,
      onOpenProject: widget.onOpenProject,
      onOpenThread: widget.onOpenThread,
      onOpenStandaloneEvent: widget.onOpenStandaloneEvent,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
    );
    final allItems = [
      for (final item in publicActivities) _PersonalFeedItem.public(item),
      for (final entry in timelineEntries) _PersonalFeedItem.timeline(entry),
    ]..sort((left, right) => right.time.compareTo(left.time));
    final visibleItems = allItems
        .where((item) => _matchesPersonalTimelineFilter(item, filter))
        .toList();

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Personal',
      subtitle:
          'Personal is the follow-based timeline for direct posts, followed-user public activity, and events that do not need to start in Public.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      showHeaderText: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _titleAccent(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This timeline follows people instead of tags. Use it for direct social posting, followed-user public activity, and personal events that should not begin inside Public.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post To Personal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Text posts live here directly. Image posts can layer in later without changing the Personal/Public split.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _MentionComposerField(
                  repository: widget.repository,
                  controller: _composerController,
                  onChanged: (_) => setState(() {}),
                  hintText: 'Share a direct post to your personal timeline...',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _composerController.text.trim().isEmpty
                        ? null
                        : () => _refresh(() {
                            widget.repository.createPersonalPost(
                              authorId: widget.currentUserId,
                              body: _composerController.text.trim(),
                            );
                            _composerController.clear();
                          }),
                    child: const Text('Post'),
                  ),
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
                for (final value in _PersonalTimelineFilter.values)
                  _PageTabChip(
                    label: _personalTimelineFilterLabel(value),
                    selected: filter == value,
                    onSelected: () => setState(() => filter = value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (visibleItems.isEmpty)
            const _SectionCard(
              child: Text('Nothing matches this Personal view yet.'),
            )
          else
            for (final item in visibleItems) ...[
              _buildPersonalTimelineItemCard(
                repository: widget.repository,
                item: item,
                currentUserId: widget.currentUserId,
                onOpenPersonalPost: _openPersonalPost,
                onOpenSharedComment: _openSharedComment,
                onOpenStandaloneEvent: widget.onOpenStandaloneEvent,
                onDeletePost: (postId) => _refresh(
                  () => widget.repository.deletePersonalPost(postId),
                ),
              ),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

class _PersonalPostCard extends StatefulWidget {
  const _PersonalPostCard({
    required this.repository,
    required this.post,
    required this.currentUserId,
    required this.onOpenPost,
    this.onDelete,
  });

  final MockRepository repository;
  final MockPersonalPost post;
  final String currentUserId;
  final VoidCallback onOpenPost;
  final VoidCallback? onDelete;

  @override
  State<_PersonalPostCard> createState() => _PersonalPostCardState();
}

class _PersonalPostCardState extends State<_PersonalPostCard> {
  int activeVote = 0;

  void _toggleVote(int value) {
    setState(() {
      activeVote = activeVote == value ? 0 : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.repository.userById(widget.post.authorId)!;
    final comments = widget.repository.commentsForPersonalPost(widget.post.id);
    final signalCount = widget.post.signalCount + activeVote;
    final canDelete = widget.post.authorId == widget.currentUserId;

    return _InteractiveFeedRow(
      background: _threadSurface(context),
      onTap: widget.onOpenPost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PersonalActorHeader(
            user: author,
            fallbackHandle: _userHandle(author),
            trailing: canDelete
                ? TextButton(
                    onPressed: widget.onDelete,
                    child: const Text('Delete'),
                  )
                : null,
          ),
          const SizedBox(height: 10),
          _InfoChip(
            label: 'Post',
            background: MockPalette.orangeDark,
            foreground: MockPalette.amberSoft,
            border: Colors.transparent,
          ),
          const SizedBox(height: 10),
          _TaggedBodyText(
            repository: widget.repository,
            text: widget.post.body,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _VoteStrip(
                id: widget.post.id,
                count: signalCount,
                activeVote: activeVote,
                onVote: (id, value) => _toggleVote(value),
              ),
              const SizedBox(width: 8),
              _CountPill(
                icon: Icons.mode_comment_outlined,
                label: '${comments.length}',
                onTap: widget.onOpenPost,
              ),
              const Spacer(),
              Text(
                _relativeTime(widget.post.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          if (widget.post.imageLabel != null) ...[
            const SizedBox(height: 10),
            Text(
              'Image placeholder: ${widget.post.imageLabel}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalPostDetailPage extends StatefulWidget {
  const _PersonalPostDetailPage({
    required this.repository,
    required this.post,
    required this.currentUserId,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockPersonalPost post;
  final String currentUserId;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_PersonalPostDetailPage> createState() =>
      _PersonalPostDetailPageState();
}

class _PersonalPostDetailPageState extends State<_PersonalPostDetailPage> {
  int activeVote = 0;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleVote(int value) {
    setState(() {
      activeVote = activeVote == value ? 0 : value;
    });
  }

  void _addComment() {
    final body = _commentController.text.trim();
    if (body.isEmpty) {
      return;
    }
    widget.repository.addCommentToPersonalPost(
      postId: widget.post.id,
      authorId: widget.currentUserId,
      body: body,
    );
    setState(() {
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final post =
        widget.repository.personalPostById(widget.post.id) ?? widget.post;
    final author = widget.repository.userById(post.authorId);
    final comments = widget.repository.commentsForPersonalPost(post.id);
    final canDelete = post.authorId == widget.currentUserId;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Post',
      subtitle:
          'Personal posts open as their own conversation surface instead of taking you straight to the author profile.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      showHeaderText: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PersonalActorHeader(
                  user: author,
                  fallbackHandle: _userHandle(author),
                  trailing: canDelete
                      ? TextButton(
                          onPressed: () {
                            widget.repository.deletePersonalPost(post.id);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Delete'),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                _InfoChip(
                  label: 'Post',
                  background: MockPalette.orangeDark,
                  foreground: MockPalette.amberSoft,
                  border: Colors.transparent,
                ),
                const SizedBox(height: 14),
                _TaggedBodyText(repository: widget.repository, text: post.body),
                if (post.imageLabel != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Image placeholder: ${post.imageLabel}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _VoteStrip(
                      id: post.id,
                      count: post.signalCount + activeVote,
                      activeVote: activeVote,
                      onVote: (id, value) => _toggleVote(value),
                    ),
                    const SizedBox(width: 10),
                    _CountPill(
                      icon: Icons.mode_comment_outlined,
                      label: '${comments.length}',
                    ),
                    const Spacer(),
                    Text(
                      _relativeTime(post.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
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
                  controller: _commentController,
                  onChanged: (_) => setState(() {}),
                  hintText: 'Reply to this post...',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _commentController.text.trim().isEmpty
                        ? null
                        : _addComment,
                    child: const Text('Add Comment'),
                  ),
                ),
                const SizedBox(height: 16),
                if (comments.isEmpty)
                  const Text('No comments yet.')
                else
                  for (final comment in comments) ...[
                    _CommentNode(
                      repository: widget.repository,
                      comment: comment,
                      currentUserId: widget.currentUserId,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalActorHeader extends StatelessWidget {
  const _PersonalActorHeader({
    required this.user,
    required this.fallbackHandle,
    this.actionLabel,
    this.trailing,
  });

  final MockUser? user;
  final String fallbackHandle;
  final String? actionLabel;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final handle = _userHandle(user);
    final displayHandle = handle == 'unknown' ? fallbackHandle : handle;
    final trimmedAction = actionLabel?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildUserAvatar(user, radius: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: displayHandle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (trimmedAction != null && trimmedAction.isNotEmpty)
                  TextSpan(
                    text: ' · ${trimmedAction.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _appMuted(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

Widget _buildPersonalTimelineItemCard({
  required MockRepository repository,
  required _PersonalFeedItem item,
  required String currentUserId,
  required void Function(MockPersonalPost post) onOpenPersonalPost,
  required void Function(MockPersonalCommentShare share) onOpenSharedComment,
  required void Function(MockEvent event) onOpenStandaloneEvent,
  void Function(String postId)? onDeletePost,
}) {
  if (item.publicActivity != null) {
    return _PersonalPublicActivityCard(
      repository: repository,
      activity: item.publicActivity!,
    );
  }

  final entry = item.timelineEntry!;
  switch (entry.kind) {
    case MockPersonalTimelineEntryKind.post:
      final post = entry.post!;
      return _PersonalPostCard(
        repository: repository,
        post: post,
        currentUserId: currentUserId,
        onDelete: onDeletePost == null ? null : () => onDeletePost(post.id),
        onOpenPost: () => onOpenPersonalPost(post),
      );
    case MockPersonalTimelineEntryKind.sharedComment:
      return _PersonalPublicActivityCard(
        repository: repository,
        activity: _personalActivityForSharedComment(
          repository: repository,
          share: entry.share!,
          onOpenOriginal: () => onOpenSharedComment(entry.share!),
        ),
      );
    case MockPersonalTimelineEntryKind.event:
      return _PersonalPublicActivityCard(
        repository: repository,
        activity: _personalActivityForStandaloneEventEntry(
          repository: repository,
          event: entry.event!,
          onOpenEvent: onOpenStandaloneEvent,
        ),
      );
  }
}

List<Widget> _personalActivitySourceChips(
  BuildContext context,
  _PersonalPublicActivity activity,
) {
  switch (activity.subject) {
    case _PersonalPublicActivitySubject.thread:
      final chipStyle = _feedThreadChipStyle(context);
      return [
        _InfoChip(
          label: 'Thread',
          background: chipStyle.background,
          foreground: chipStyle.foreground,
          border: Colors.transparent,
        ),
      ];
    case _PersonalPublicActivitySubject.project:
      final project = activity.project;
      if (project == null) {
        return [
          _InfoChip(
            label: 'Project',
            background: MockPalette.greenDark,
            foreground: MockPalette.greenSoft,
            border: Colors.transparent,
          ),
        ];
      }
      final chipStyle = _feedPrimaryChipStyleForProject(project, context);
      final stageStyle = stageStyleForMode(
        project.stage,
        isDarkMode: _isDarkTheme(context),
      );
      return [
        _InfoChip(
          label: chipStyle.label,
          background: chipStyle.background,
          foreground: chipStyle.foreground,
          border: Colors.transparent,
        ),
        _InfoChip(
          label: stageStyle.label,
          background: stageStyle.soft,
          foreground: stageStyle.accent,
          border: Colors.transparent,
        ),
      ];
    case _PersonalPublicActivitySubject.event:
      final event = activity.event;
      if (event == null) {
        return [
          _InfoChip(
            label: 'Event',
            background: _eventSurface(context),
            foreground: _eventAccent(context),
            border: _eventBorder(context),
          ),
        ];
      }
      return [
        _InfoChip(
          label: 'Event',
          background: _eventSurface(context),
          foreground: _eventAccent(context),
          border: _eventBorder(context),
        ),
        if (activity.showEventVisibilityChip)
          _InfoChip(
            label: event.isPrivate ? 'Private' : 'Public',
            background: _statusChipBackground(context),
            foreground: _statusChipForeground(context),
            border: Colors.transparent,
          ),
      ];
  }
}

List<_TagChipData> _tagItemsForPersonalActivity(
  MockRepository repository,
  _PersonalPublicActivity activity,
) {
  final channelIds = switch (activity.subject) {
    _PersonalPublicActivitySubject.thread =>
      activity.thread?.channelIds ?? const <String>[],
    _PersonalPublicActivitySubject.project =>
      activity.project?.channelIds ?? const <String>[],
    _PersonalPublicActivitySubject.event =>
      activity.event?.channelIds ?? const <String>[],
  };
  final communityIds = switch (activity.subject) {
    _PersonalPublicActivitySubject.thread =>
      activity.thread?.communityIds ?? const <String>[],
    _PersonalPublicActivitySubject.project =>
      activity.project?.communityIds ?? const <String>[],
    _PersonalPublicActivitySubject.event =>
      activity.event?.communityIds ?? const <String>[],
  };

  return [
    for (final channelId in channelIds)
      if (repository.channelById(channelId) case final channel?)
        _TagChipData(label: channel.name, kind: _TagChipKind.channel),
    for (final communityId in communityIds)
      if (repository.communityById(communityId) case final community?)
        _TagChipData(label: community.name, kind: _TagChipKind.community),
  ];
}

class _PersonalPublicActivityCard extends StatelessWidget {
  const _PersonalPublicActivityCard({
    required this.repository,
    required this.activity,
  });

  final MockRepository repository;
  final _PersonalPublicActivity activity;

  @override
  Widget build(BuildContext context) {
    final sourceChips = _personalActivitySourceChips(context, activity);
    final tagItems = _tagItemsForPersonalActivity(repository, activity);
    final visibleMeta = _visiblePersonalActivityMeta(activity, tagItems);

    return _InteractiveFeedRow(
      background: _threadSurface(context),
      onTap: activity.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PersonalActorHeader(
            user: activity.author,
            fallbackHandle: activity.authorHandle,
            actionLabel: activity.actionLabel,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(spacing: 6, runSpacing: 6, children: sourceChips),
              ),
              if (tagItems.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(child: _TagWrap(items: tagItems, alignEnd: true)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(activity.title, style: Theme.of(context).textTheme.titleLarge),
          if (visibleMeta != null) ...[
            const SizedBox(height: 6),
            Text(visibleMeta, style: Theme.of(context).textTheme.labelLarge),
          ],
          const SizedBox(height: 8),
          _TaggedBodyText(repository: repository, text: activity.body),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _relativeTime(activity.time),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

String? _visiblePersonalActivityMeta(
  _PersonalPublicActivity activity,
  List<_TagChipData> tagItems,
) {
  final meta = activity.meta.trim();
  if (meta.isEmpty) {
    return null;
  }

  if (tagItems.isEmpty) {
    return meta;
  }

  final joinedTags = tagItems.map((item) => item.label).join(' · ').trim();
  if (joinedTags.isEmpty) {
    return meta;
  }

  if (meta.toLowerCase() == joinedTags.toLowerCase()) {
    return null;
  }

  return meta;
}
