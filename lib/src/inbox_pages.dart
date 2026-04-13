part of '../main.dart';

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({
    required this.repository,
    required this.readNotifications,
    required this.leftRail,
    required this.onMarkRead,
    required this.onMarkAllRead,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.topNav,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Map<String, bool> readNotifications;
  final Widget leftRail;
  final ValueChanged<String> onMarkRead;
  final VoidCallback onMarkAllRead;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final Widget topNav;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final items = [
      ...repository.notifications.where(
        (item) => item.targetKind != 'conversation',
      ),
    ]..sort((left, right) => right.time.compareTo(left.time));
    final unreadCount = items
        .where((item) => !(readNotifications[item.id] ?? false))
        .length;

    return _DetailShell(
      repository: repository,
      topNav: topNav,
      leftRail: leftRail,
      title: 'Notifications',
      subtitle:
          'One inbox keeps project, governance, and logistics updates in the same place without mixing in direct messages.',
      onOpenProject: onOpenProject,
      onOpenPlan: onOpenPlan,
      onOpenEvent: onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Unread: $unreadCount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton(
                  onPressed: onMarkAllRead,
                  child: const Text('Mark All Read'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _NotificationSection(
            title: 'Inbox',
            items: items,
            readNotifications: readNotifications,
            onTap: (item) {
              _openNotification(item);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openNotification(MockNotificationItem item) async {
    onMarkRead(item.id);
    if (item.targetKind == 'project') {
      final project = repository.projectById(item.targetId);
      if (project != null) {
        if (item.targetUpdateId != null) {
          repository.setPendingProjectUpdateTarget(
            project.id,
            item.targetUpdateId!,
          );
        }
        onOpenProject(
          project,
          initialTab: item.targetProjectTab ?? MockProjectTab.overview,
        );
      }
    }

    if (item.targetKind == 'plan') {
      final plan = repository.planById(item.targetId);
      if (plan != null) {
        onOpenPlan(plan);
      }
    }
  }
}

class _MessengerPage extends StatefulWidget {
  const _MessengerPage({
    required this.repository,
    required this.currentUserId,
    required this.leftRail,
    required this.topNav,
    required this.onOpenProfile,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final String currentUserId;
  final Widget leftRail;
  final Widget topNav;
  final void Function(MockUser user) onOpenProfile;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<_MessengerPage> {
  Future<void> _openConversation(MockDirectConversation conversation) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _DirectConversationPage(
          repository: widget.repository,
          currentUserId: widget.currentUserId,
          conversation: conversation,
          topNav: widget.topNav,
          leftRail: widget.leftRail,
          onOpenProfile: widget.onOpenProfile,
          onOpenProject: widget.onOpenProject,
          onOpenPlan: widget.onOpenPlan,
          onOpenEvent: widget.onOpenEvent,
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _openComposer() async {
    final user = await showDialog<MockUser>(
      context: context,
      builder: (context) => _NewMessageDialog(
        repository: widget.repository,
        currentUserId: widget.currentUserId,
      ),
    );

    if (user == null || !mounted) {
      return;
    }

    await _openConversation(
      widget.repository.conversationWithUser(widget.currentUserId, user.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations = widget.repository.directConversationsForUser(
      widget.currentUserId,
    );

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Messages',
      subtitle:
          'Direct messages stay separate from channels, communities, and project discussion while still using the same lightweight communication language.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Direct conversations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton(
                  onPressed: _openComposer,
                  child: const Text('Start Conversation'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (conversations.isEmpty)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No direct conversations yet. Start one from here or from any profile.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _openComposer,
                    child: const Text('Find Someone'),
                  ),
                ],
              ),
            )
          else
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final conversation in conversations) ...[
                    Builder(
                      builder: (context) {
                        final otherUser = widget.repository
                            .otherParticipantForConversation(
                              conversation,
                              widget.currentUserId,
                            );
                        final latestMessage = widget.repository
                            .latestMessageForConversation(conversation.id);

                        return _InboxRow(
                          leading: _buildUserAvatar(otherUser, radius: 20),
                          title: otherUser == null
                              ? 'Direct message'
                              : _userHandle(otherUser),
                          body:
                              latestMessage?.body ??
                              'No messages yet. Open the thread and send the first note.',
                          meta: latestMessage == null
                              ? 'Draft ready'
                              : _relativeTime(latestMessage.time),
                          unread: conversation.unreadCount > 0,
                          badge: conversation.unreadCount > 0
                              ? '${conversation.unreadCount} unread'
                              : null,
                          flatStyle: true,
                          onTap: () {
                            _openConversation(conversation);
                          },
                        );
                      },
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

class _NewMessageDialog extends StatefulWidget {
  const _NewMessageDialog({
    required this.repository,
    required this.currentUserId,
  });

  final MockRepository repository;
  final String currentUserId;

  @override
  State<_NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends State<_NewMessageDialog> {
  late final TextEditingController _searchController;
  String query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users =
        widget.repository.users
            .where((user) => user.id != widget.currentUserId)
            .where((user) => _matchesUserSearch(user, query))
            .toList()
          ..sort((left, right) => left.username.compareTo(right.username));

    return AlertDialog(
      title: const Text('Start Conversation'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search all users by username, location, or bio.'),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Search users',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: users.isEmpty
                  ? const Center(child: Text('No users match that search yet.'))
                  : ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(user),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _appSurfaceSoft(context),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _appBorder(context)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildUserAvatar(user, radius: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.location,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          user.bio,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _DirectConversationPage extends StatefulWidget {
  const _DirectConversationPage({
    required this.repository,
    required this.currentUserId,
    required this.conversation,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProfile,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final String currentUserId;
  final MockDirectConversation conversation;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockUser user) onOpenProfile;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_DirectConversationPage> createState() =>
      _DirectConversationPageState();
}

class _DirectConversationPageState extends State<_DirectConversationPage> {
  late final TextEditingController _replyController;

  MockDirectConversation get _conversation =>
      widget.repository.directConversationById(widget.conversation.id) ??
      widget.conversation;

  MockUser? get _otherUser => widget.repository.otherParticipantForConversation(
    _conversation,
    widget.currentUserId,
  );

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    widget.repository.markConversationRead(widget.conversation.id);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final otherUser = _otherUser;
    final body = _replyController.text.trim();
    if (otherUser == null || body.isEmpty) {
      return;
    }

    widget.repository.sendDirectMessage(
      currentUserId: widget.currentUserId,
      otherUserId: otherUser.id,
      body: body,
    );
    setState(() {
      _replyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = _otherUser;
    final messages = [
      ...widget.repository.messagesForConversation(_conversation.id),
    ]..sort((left, right) => left.time.compareTo(right.time));
    final canSend =
        _replyController.text.trim().isNotEmpty && otherUser != null;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: otherUser == null ? 'Direct Message' : _userHandle(otherUser),
      subtitle:
          'This conversation stays private to the participants and does not appear in channels, communities, or public project discussion.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(otherUser, radius: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUser == null
                            ? 'Direct message'
                            : _userHandle(otherUser),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        otherUser == null
                            ? 'Private conversation'
                            : otherUser.location,
                      ),
                    ],
                  ),
                ),
                if (otherUser != null)
                  OutlinedButton(
                    onPressed: () => widget.onOpenProfile(otherUser),
                    child: const Text('Open Profile'),
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
                  'Conversation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (messages.isEmpty)
                  const Text(
                    'No messages yet. This mock conversation is ready for the first note.',
                  )
                else
                  for (final message in messages) ...[
                    _DirectMessageBubble(
                      repository: widget.repository,
                      message: message,
                      currentUserId: widget.currentUserId,
                      isCurrentUser: message.authorId == widget.currentUserId,
                      onToggleReaction: (emoji) {
                        widget.repository.toggleDirectMessageReaction(
                          conversationId: _conversation.id,
                          messageId: message.id,
                          userId: widget.currentUserId,
                          emoji: emoji,
                        );
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reply', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _MentionComposerField(
                  repository: widget.repository,
                  controller: _replyController,
                  onChanged: (_) => setState(() {}),
                  hintText: 'Write a direct message...',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Messages save into the mock conversation immediately.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: canSend ? _sendMessage : null,
                      child: const Text('Send'),
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

class _DirectMessageBubble extends StatelessWidget {
  const _DirectMessageBubble({
    required this.repository,
    required this.message,
    required this.currentUserId,
    required this.isCurrentUser,
    required this.onToggleReaction,
  });

  final MockRepository repository;
  final MockDirectMessage message;
  final String currentUserId;
  final bool isCurrentUser;
  final ValueChanged<String> onToggleReaction;

  @override
  Widget build(BuildContext context) {
    final author = repository.userById(message.authorId);
    final activeReaction = repository.directMessageReactionForUser(
      message.id,
      currentUserId,
    );
    final reactionOptions = <String>{
      ...message.reactions.keys,
      '👍',
      '❤️',
      '✅',
      '👀',
    }.toList();
    final tone = isCurrentUser
        ? _appSurfaceStrong(
            context,
          ).withValues(alpha: _isDarkTheme(context) ? 0.56 : 0.46)
        : _appSurfaceSoft(
            context,
          ).withValues(alpha: _isDarkTheme(context) ? 0.28 : 0.4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone,
        border: Border(bottom: BorderSide(color: _appBorder(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  isCurrentUser ? 'You' : _userHandle(author),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                _relativeTime(message.time),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TaggedBodyText(repository: repository, text: message.body),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final emoji in reactionOptions)
                ChoiceChip(
                  label: Text(
                    message.reactions.containsKey(emoji)
                        ? '$emoji ${message.reactions[emoji]}'
                        : emoji,
                  ),
                  selected: activeReaction == emoji,
                  onSelected: (_) => onToggleReaction(emoji),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.title,
    required this.items,
    required this.readNotifications,
    required this.onTap,
  });

  final String title;
  final List<MockNotificationItem> items;
  final Map<String, bool> readNotifications;
  final ValueChanged<MockNotificationItem> onTap;

  @override
  Widget build(BuildContext context) {
    Widget leadingFor(MockNotificationItem item) {
      final (icon, background, foreground) = switch (item.targetKind) {
        'plan' => (
          Icons.how_to_vote_outlined,
          const Color(0xFFFFF1DB),
          const Color(0xFFB45309),
        ),
        'conversation' => (
          Icons.forum_outlined,
          const Color(0xFFE7F0FF),
          const Color(0xFF2563EB),
        ),
        'project' => (
          Icons.account_tree_outlined,
          const Color(0xFFDFF1E5),
          const Color(0xFF0F3F20),
        ),
        _ => (
          Icons.notifications_none_rounded,
          _appSurfaceStrong(context),
          Theme.of(context).textTheme.labelLarge?.color ?? MockPalette.text,
        ),
      };

      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: foreground, size: 20),
      );
    }

    String badgeFor(MockNotificationItem item) {
      if (item.targetKind == 'conversation') {
        return 'Message';
      }
      if (item.targetKind == 'plan') {
        return 'Plan';
      }
      return 'Project';
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('Nothing new in this section.')
          else
            for (final item in items) ...[
              _InboxRow(
                leading: leadingFor(item),
                title: item.title,
                body: item.body,
                meta: _relativeTime(item.time),
                unread: !(readNotifications[item.id] ?? false),
                badge: badgeFor(item),
                onTap: () => onTap(item),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({
    required this.leading,
    required this.title,
    required this.body,
    required this.meta,
    required this.unread,
    required this.onTap,
    this.badge,
    this.flatStyle = false,
  });

  final Widget leading;
  final String title;
  final String body;
  final String meta;
  final bool unread;
  final VoidCallback onTap;
  final String? badge;
  final bool flatStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(flatStyle ? 0 : 10),
        hoverColor: _rowHoverOverlay(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unread
                ? _unreadNotificationSurface(context)
                : _appSurfaceSoft(
                    context,
                  ).withValues(alpha: _isDarkTheme(context) ? 0.24 : 0.36),
            borderRadius: BorderRadius.circular(flatStyle ? 0 : 10),
            border: flatStyle
                ? Border(bottom: BorderSide(color: _appBorder(context)))
                : Border.all(color: _appBorder(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: unread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _appSurfaceStrong(context),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge!,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(meta, style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
