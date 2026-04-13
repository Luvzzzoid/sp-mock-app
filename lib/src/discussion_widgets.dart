part of '../main.dart';

enum _MentionTargetKind { user, channel, community, project }

class _ResolvedMention {
  const _ResolvedMention({
    required this.kind,
    this.user,
    this.channel,
    this.community,
    this.project,
  });

  final _MentionTargetKind kind;
  final MockUser? user;
  final MockChannel? channel;
  final MockCommunity? community;
  final MockProject? project;
}

class _TaggedBodyText extends StatelessWidget {
  const _TaggedBodyText({required this.repository, required this.text});

  final MockRepository repository;
  final String text;

  @override
  Widget build(BuildContext context) {
    final mentionPattern = RegExp(r'@[A-Za-z0-9][A-Za-z0-9._-]*');
    final matches = mentionPattern.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text);
    }

    final baseStyle = DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in matches) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }

      final rawMention = match.group(0)!;
      final resolved = _resolveMention(repository, rawMention.substring(1));
      if (resolved == null) {
        spans.add(TextSpan(text: rawMention));
      } else {
        spans.add(
          TextSpan(
            text: rawMention,
            style: TextStyle(
              color: _mentionForeground(context, resolved),
              fontWeight: FontWeight.w700,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () =>
                  _showMentionPreview(context, rawMention, resolved),
          ),
        );
      }

      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: baseStyle, children: spans),
      overflow: TextOverflow.clip,
    );
  }
}

String _normalizeMentionKey(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

_ResolvedMention? _resolveMention(MockRepository repository, String token) {
  final key = _normalizeMentionKey(token);

  for (final user in repository.users) {
    if (_normalizeMentionKey(user.username) == key ||
        _normalizeMentionKey(user.id) == key ||
        _normalizeMentionKey(user.name) == key) {
      return _ResolvedMention(kind: _MentionTargetKind.user, user: user);
    }
  }

  for (final channel in repository.channels) {
    if (_normalizeMentionKey(channel.id) == key ||
        _normalizeMentionKey(channel.name) == key) {
      return _ResolvedMention(
        kind: _MentionTargetKind.channel,
        channel: channel,
      );
    }
  }

  for (final community in repository.communities) {
    if (_normalizeMentionKey(community.id) == key ||
        _normalizeMentionKey(community.name) == key) {
      return _ResolvedMention(
        kind: _MentionTargetKind.community,
        community: community,
      );
    }
  }

  for (final project in repository.projects) {
    if (_normalizeMentionKey(project.id) == key ||
        _normalizeMentionKey(project.title) == key) {
      return _ResolvedMention(
        kind: _MentionTargetKind.project,
        project: project,
      );
    }
  }

  return null;
}

void _showMentionPreview(
  BuildContext context,
  String rawMention,
  _ResolvedMention mention,
) {
  final (title, body) = switch (mention.kind) {
    _MentionTargetKind.user => (
      _userHandle(mention.user),
      mention.user == null
          ? 'This user is no longer available in the mock data.'
          : '${mention.user!.location} - ${mention.user!.bio}',
    ),
    _MentionTargetKind.channel => (
      mention.channel?.name ?? rawMention,
      mention.channel?.description ??
          'This channel is no longer available in the mock data.',
    ),
    _MentionTargetKind.community => (
      mention.community?.name ?? rawMention,
      mention.community?.description ??
          'This community is no longer available in the mock data.',
    ),
    _MentionTargetKind.project => (
      mention.project?.title ?? rawMention,
      mention.project?.summary ??
          'This project is no longer available in the mock data.',
    ),
  };

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(rawMention),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(dialogContext).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body),
        ],
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

Color _mentionForeground(BuildContext context, _ResolvedMention mention) {
  switch (mention.kind) {
    case _MentionTargetKind.user:
      return _threadAccent(context);
    case _MentionTargetKind.channel:
      return _tagTone(context, _TagChipKind.channel).foreground;
    case _MentionTargetKind.community:
      return _tagTone(context, _TagChipKind.community).foreground;
    case _MentionTargetKind.project:
      final project = mention.project;
      if (project == null) {
        return _titleAccent(context);
      }
      return project.type == MockProjectType.service
          ? _serviceAccent(context)
          : _communityAccent(context);
  }
}

class _MentionSuggestion {
  const _MentionSuggestion({
    required this.label,
    required this.insertText,
    required this.kindLabel,
  });

  final String label;
  final String insertText;
  final String kindLabel;
}

class _ActiveMentionRange {
  const _ActiveMentionRange({
    required this.start,
    required this.end,
    required this.query,
  });

  final int start;
  final int end;
  final String query;
}

class _MentionComposerField extends StatefulWidget {
  const _MentionComposerField({
    required this.repository,
    required this.hintText,
    this.controller,
    this.onChanged,
  });

  final MockRepository repository;
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  State<_MentionComposerField> createState() => _MentionComposerFieldState();
}

class _MentionComposerFieldState extends State<_MentionComposerField> {
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMention = _activeMentionRange(_controller);
    final suggestions = activeMention == null
        ? const <_MentionSuggestion>[]
        : _mentionSuggestions(widget.repository, activeMention.query);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) {
            setState(() {});
            widget.onChanged?.call(value);
          },
          maxLines: 3,
          decoration: InputDecoration(hintText: widget.hintText),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in suggestions)
                ActionChip(
                  label: Text('${suggestion.label} - ${suggestion.kindLabel}'),
                  onPressed: () => _insertMention(activeMention!, suggestion),
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _insertMention(
    _ActiveMentionRange range,
    _MentionSuggestion suggestion,
  ) {
    final nextText =
        '${_controller.text.substring(0, range.start)}@${suggestion.insertText} ${_controller.text.substring(range.end)}';
    final cursor = range.start + suggestion.insertText.length + 2;
    _controller.value = _controller.value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: cursor),
      composing: TextRange.empty,
    );
    setState(() {});
    widget.onChanged?.call(nextText);
  }
}

_ActiveMentionRange? _activeMentionRange(TextEditingController controller) {
  final selection = controller.selection;
  final cursor = selection.isValid
      ? selection.baseOffset
      : controller.text.length;
  if (cursor <= 0) {
    return null;
  }

  final text = controller.text;
  final atIndex = text.lastIndexOf('@', cursor - 1);
  if (atIndex == -1) {
    return null;
  }

  if (atIndex > 0) {
    final previous = text[atIndex - 1];
    if (!RegExp(r'[\s(\[{]').hasMatch(previous)) {
      return null;
    }
  }

  final query = text.substring(atIndex + 1, cursor);
  if (!RegExp(r'^[A-Za-z0-9._-]*$').hasMatch(query)) {
    return null;
  }

  return _ActiveMentionRange(start: atIndex, end: cursor, query: query);
}

List<_MentionSuggestion> _mentionSuggestions(
  MockRepository repository,
  String query,
) {
  final normalizedQuery = _normalizeMentionKey(query);
  final suggestions = <_MentionSuggestion>[];
  final seen = <String>{};

  bool matches(String value) {
    if (normalizedQuery.isEmpty) {
      return true;
    }
    return _normalizeMentionKey(value).contains(normalizedQuery);
  }

  void addSuggestion(_MentionSuggestion item) {
    final key = '${item.kindLabel}:${item.insertText}';
    if (seen.add(key)) {
      suggestions.add(item);
    }
  }

  for (final user in repository.users) {
    if (matches(user.username) || matches(user.name)) {
      addSuggestion(
        _MentionSuggestion(
          label: '@${user.username}',
          insertText: user.username,
          kindLabel: 'user',
        ),
      );
    }
  }

  for (final channel in repository.channels) {
    if (matches(channel.id) || matches(channel.name)) {
      addSuggestion(
        _MentionSuggestion(
          label: '@${channel.id}',
          insertText: channel.id,
          kindLabel: 'channel',
        ),
      );
    }
  }

  for (final community in repository.communities) {
    if (matches(community.id) || matches(community.name)) {
      addSuggestion(
        _MentionSuggestion(
          label: '@${community.id}',
          insertText: community.id,
          kindLabel: 'community',
        ),
      );
    }
  }

  for (final project in repository.projects) {
    final token = _normalizeMentionKey(project.title);
    if (matches(project.id) || matches(project.title)) {
      addSuggestion(
        _MentionSuggestion(
          label: '@$token',
          insertText: token,
          kindLabel: 'project',
        ),
      );
    }
  }

  return suggestions.take(6).toList();
}

class _CommentNode extends StatefulWidget {
  const _CommentNode({
    required this.repository,
    required this.comment,
    this.depth = 0,
    this.currentUserId,
    this.highlightedCommentId,
    this.isSharedToPersonal,
    this.onShareToPersonal,
    this.onChanged,
  });

  final MockRepository repository;
  final MockComment comment;
  final int depth;
  final String? currentUserId;
  final String? highlightedCommentId;
  final bool Function(MockComment comment)? isSharedToPersonal;
  final ValueChanged<MockComment>? onShareToPersonal;
  final VoidCallback? onChanged;

  @override
  State<_CommentNode> createState() => _CommentNodeState();
}

class _CommentNodeState extends State<_CommentNode> {
  int activeVote = 0;
  bool _deleted = false;

  void _toggleVote(int value) {
    setState(() {
      activeVote = activeVote == value ? 0 : value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }

    final comment = widget.comment;
    final author = widget.repository.userById(comment.authorId);
    final score = comment.score + activeVote;
    final isHighlighted = widget.highlightedCommentId == comment.id;
    final canShareToPersonal =
        widget.currentUserId != null &&
        widget.currentUserId == comment.authorId &&
        widget.onShareToPersonal != null;
    final isAlreadyShared = widget.isSharedToPersonal?.call(comment) ?? false;
    final canDelete = widget.currentUserId == comment.authorId;

    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 18),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted
              ? _appSurfaceStrong(
                  context,
                ).withValues(alpha: _isDarkTheme(context) ? 0.7 : 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: widget.depth == 0
              ? null
              : Border(left: BorderSide(color: _appBorder(context), width: 2)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _userHandle(author),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _relativeTime(comment.time),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (canDelete) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final removed = widget.repository.deleteComment(
                        comment.id,
                      );
                      if (!removed) {
                        return;
                      }
                      widget.onChanged?.call();
                      setState(() => _deleted = true);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            _TaggedBodyText(repository: widget.repository, text: comment.body),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _VoteStrip(
                    id: comment.id,
                    count: score,
                    activeVote: activeVote,
                    onVote: (commentId, direction) => _toggleVote(direction),
                  ),
                ),
                if (canShareToPersonal)
                  TextButton(
                    onPressed: isAlreadyShared
                        ? null
                        : () => widget.onShareToPersonal!(comment),
                    child: Text(
                      isAlreadyShared
                          ? 'Shown In Personal'
                          : 'Show In Personal',
                    ),
                  ),
              ],
            ),
            for (final reply in comment.replies) ...[
              const SizedBox(height: 12),
              _CommentNode(
                repository: widget.repository,
                comment: reply,
                depth: widget.depth + 1,
                currentUserId: widget.currentUserId,
                highlightedCommentId: widget.highlightedCommentId,
                isSharedToPersonal: widget.isSharedToPersonal,
                onShareToPersonal: widget.onShareToPersonal,
                onChanged: widget.onChanged,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
