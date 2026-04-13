part of '../main.dart';

_FeedPrimaryChipStyle _landAssetChipStyle(BuildContext context) {
  if (_isDarkTheme(context)) {
    return const _FeedPrimaryChipStyle(
      label: 'Land Asset',
      background: Color(0xFF264734),
      foreground: Color(0xFFD8EFD9),
    );
  }

  return const _FeedPrimaryChipStyle(
    label: 'Land Asset',
    background: Color(0xFF1E5A33),
    foreground: Color(0xFFE4F5E8),
  );
}

String _requestabilityLabel(MockAssetRequestability value) {
  switch (value) {
    case MockAssetRequestability.both:
      return 'Personal and project';
    case MockAssetRequestability.personalOnly:
      return 'Personal only';
    case MockAssetRequestability.projectOnly:
      return 'Project only';
    case MockAssetRequestability.unavailable:
      return 'Unavailable';
  }
}

Color _requestabilityBackground(
  BuildContext context,
  MockAssetRequestability value,
) {
  if (_isDarkTheme(context)) {
    switch (value) {
      case MockAssetRequestability.both:
        return const Color(0xFF1F3D2C);
      case MockAssetRequestability.personalOnly:
        return const Color(0xFF203447);
      case MockAssetRequestability.projectOnly:
        return const Color(0xFF47311F);
      case MockAssetRequestability.unavailable:
        return const Color(0xFF2A2D31);
    }
  }

  switch (value) {
    case MockAssetRequestability.both:
      return MockPalette.greenSoft;
    case MockAssetRequestability.personalOnly:
      return MockPalette.blueSoft;
    case MockAssetRequestability.projectOnly:
      return MockPalette.orangeSoft;
    case MockAssetRequestability.unavailable:
      return MockPalette.panelSoft;
  }
}

Color _requestabilityForeground(
  BuildContext context,
  MockAssetRequestability value,
) {
  if (_isDarkTheme(context)) {
    switch (value) {
      case MockAssetRequestability.both:
        return const Color(0xFFA8E3BB);
      case MockAssetRequestability.personalOnly:
        return const Color(0xFFA9CBFF);
      case MockAssetRequestability.projectOnly:
        return const Color(0xFFF1C389);
      case MockAssetRequestability.unavailable:
        return const Color(0xFFD6D8DD);
    }
  }

  switch (value) {
    case MockAssetRequestability.both:
      return MockPalette.greenDark;
    case MockAssetRequestability.personalOnly:
      return MockPalette.blue;
    case MockAssetRequestability.projectOnly:
      return MockPalette.orangeDark;
    case MockAssetRequestability.unavailable:
      return MockPalette.text;
  }
}

Color _requestabilityBorder(
  BuildContext context,
  MockAssetRequestability value,
) {
  if (_isDarkTheme(context)) {
    switch (value) {
      case MockAssetRequestability.both:
        return const Color(0xFF2B6A43);
      case MockAssetRequestability.personalOnly:
        return const Color(0xFF325676);
      case MockAssetRequestability.projectOnly:
        return const Color(0xFF7D4C25);
      case MockAssetRequestability.unavailable:
        return const Color(0xFF44474D);
    }
  }

  switch (value) {
    case MockAssetRequestability.both:
      return MockPalette.green;
    case MockAssetRequestability.personalOnly:
      return MockPalette.blue;
    case MockAssetRequestability.projectOnly:
      return MockPalette.orange;
    case MockAssetRequestability.unavailable:
      return MockPalette.border;
  }
}

bool _isDarkTheme(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _appSurface(BuildContext context) =>
    _isDarkTheme(context) ? MockPalette.darkPanel : MockPalette.panel;

Color _centerPaneSurface(BuildContext context) =>
    _isDarkTheme(context) ? MockPalette.darkPanel : MockPalette.panel;

Color _sidePaneSurface(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF222429) : const Color(0xFFEEE6DA);

Color _appSurfaceSoft(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF25282D) : const Color(0xFFF2EADE);

Color _appSurfaceStrong(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF2D3035) : const Color(0xFFE8DDCF);

Color _appBorder(BuildContext context) =>
    _isDarkTheme(context) ? MockPalette.darkBorder : MockPalette.border;

Color _paneDivider(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF33363C) : const Color(0xFFD8CCBA);

Color _appMuted(BuildContext context) =>
    _isDarkTheme(context) ? MockPalette.darkMuted : MockPalette.muted;

Color _toolbarSurface(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF1B1D21) : const Color(0xFFF3EBDD);

Color _toolbarBrandIcon(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFFF0F2F4) : const Color(0xFF2F343C);

Color _interactionAccent(BuildContext context) =>
    mockAccentTheme(context).primary;

Color _titleAccent(BuildContext context) => mockAccentTheme(context).title;

Color _positiveVoteColor(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF74DB9E) : MockPalette.green;

Color _negativeVoteColor(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFFF0AA67) : MockPalette.amber;

Color _threadAccent(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF88C5FF) : MockPalette.blue;

Color _eventAccent(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFFC9B4FF) : MockPalette.purple;

Color _eventSurface(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF302544) : MockPalette.purpleSoft;

Color _eventBorder(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF5D4A88) : const Color(0xFFD5C1F6);

Color _serviceAccent(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFFF0C76E) : MockPalette.amber;

Color _communityAccent(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF8FD4A9) : MockPalette.greenDark;

Color _channelAccent(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFFE5AF71) : MockPalette.warning;

Color _threadSurface(BuildContext context) => _centerPaneSurface(context);

Color _feedDivider(BuildContext context) => _isDarkTheme(context)
    ? Colors.white.withValues(alpha: 0.14)
    : Colors.black.withValues(alpha: 0.10);

Color _rowHoverOverlay(BuildContext context) => _interactionAccent(
  context,
).withValues(alpha: _isDarkTheme(context) ? 0.18 : 0.14);

Color _progressTrack(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF141816) : const Color(0xFFE4EBE2);

Color _unreadNotificationSurface(BuildContext context) =>
    _isDarkTheme(context) ? const Color(0xFF2A2D33) : const Color(0xFFECEEF2);

Color _statusChipBackground(BuildContext context) => const Color(0xFF50555D);

Color _statusChipForeground(BuildContext context) => const Color(0xFFF5F7FA);

Color _fundProgressColor(BuildContext context, double progress) {
  final value = progress.clamp(0.0, 1.0);
  if (value < 0.25) {
    return _isDarkTheme(context)
        ? const Color(0xFFCE7867)
        : const Color(0xFFCC6A55);
  }
  if (value < 0.5) {
    return _isDarkTheme(context)
        ? const Color(0xFFE39A63)
        : const Color(0xFFD88742);
  }
  if (value < 0.75) {
    return _isDarkTheme(context)
        ? const Color(0xFFD7C06C)
        : const Color(0xFFC8A93A);
  }
  return _positiveVoteColor(context);
}

_AccentTone _tagTone(BuildContext context, _TagChipKind kind) {
  switch (kind) {
    case _TagChipKind.channel:
      return _isDarkTheme(context)
          ? _AccentTone(
              background: const Color(0xFF35281C),
              foreground: _channelAccent(context),
            )
          : const _AccentTone(
              background: Color(0xFFFFF0DE),
              foreground: Color(0xFFB45309),
            );
    case _TagChipKind.community:
      return _isDarkTheme(context)
          ? _AccentTone(
              background: const Color(0xFF1F3226),
              foreground: _communityAccent(context),
            )
          : const _AccentTone(
              background: Color(0xFFDFF1E5),
              foreground: Color(0xFF0F3F20),
            );
    case _TagChipKind.neutral:
      return _AccentTone(
        background: _appSurfaceStrong(context),
        foreground:
            Theme.of(context).textTheme.bodyLarge?.color ??
            (_isDarkTheme(context) ? MockPalette.darkText : MockPalette.text),
      );
  }
}

_AccentTone? _semanticChipTone(BuildContext context, String label) {
  final value = label.toLowerCase();
  if (value.startsWith('production')) {
    return _isDarkTheme(context)
        ? _AccentTone(
            background: const Color(0xFF203728),
            foreground: _communityAccent(context),
          )
        : const _AccentTone(
            background: Color(0xFFDFF1E5),
            foreground: Color(0xFF0F3F20),
          );
  }
  if (value.startsWith('service')) {
    return _isDarkTheme(context)
        ? _AccentTone(
            background: const Color(0xFF3A301D),
            foreground: _serviceAccent(context),
          )
        : const _AccentTone(
            background: Color(0xFFFFF1DB),
            foreground: Color(0xFFB45309),
          );
  }
  if (value.startsWith('thread')) {
    return _isDarkTheme(context)
        ? _AccentTone(
            background: const Color(0xFF1C3140),
            foreground: _threadAccent(context),
          )
        : const _AccentTone(
            background: Color(0xFFE7F0FF),
            foreground: Color(0xFF2563EB),
          );
  }
  if (value.startsWith('channel')) {
    return _isDarkTheme(context)
        ? _AccentTone(
            background: const Color(0xFF35281C),
            foreground: _channelAccent(context),
          )
        : const _AccentTone(
            background: Color(0xFFFFF0DE),
            foreground: Color(0xFFB45309),
          );
  }
  if (value.startsWith('community')) {
    return _isDarkTheme(context)
        ? _AccentTone(
            background: const Color(0xFF1F3226),
            foreground: _communityAccent(context),
          )
        : const _AccentTone(
            background: Color(0xFFDFF1E5),
            foreground: Color(0xFF0F3F20),
          );
  }
  return null;
}

Color _resolveChipBackground(BuildContext context, Color background) {
  if (background == MockPalette.panelSoft) {
    return _appSurfaceStrong(context);
  }
  if (background == MockPalette.panel) {
    return _appSurface(context);
  }
  return background;
}

Color _resolveChipForeground(BuildContext context, Color foreground) {
  if (foreground == MockPalette.text) {
    return Theme.of(context).textTheme.labelLarge?.color ??
        (_isDarkTheme(context) ? MockPalette.darkText : MockPalette.text);
  }
  return foreground;
}

String _userHandle(MockUser? user) {
  final username = user?.username.trim();
  if (username != null && username.isNotEmpty) {
    return username;
  }

  final name = user?.name.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  return 'unknown';
}

String _userInitial(MockUser? user) {
  final username = user?.username.trim();
  if (username != null && username.isNotEmpty) {
    return username.characters.first.toUpperCase();
  }

  final name = user?.name.trim();
  if (name != null && name.isNotEmpty) {
    return name.characters.first.toUpperCase();
  }

  return '?';
}

Widget _buildUserAvatar(
  MockUser? user, {
  double radius = 20,
  Color backgroundColor = MockPalette.greenSoft,
  Color foregroundColor = MockPalette.greenDark,
}) {
  final label = user?.avatarLabel?.trim();
  final display = label != null && label.isNotEmpty
      ? label
      : _userInitial(user);

  return CircleAvatar(
    radius: radius,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    child: Text(
      display,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: radius * 0.74),
    ),
  );
}

bool _matchesUserSearch(MockUser user, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return true;
  }

  return [
    user.username,
    user.name,
    user.location,
    user.bio,
  ].any((value) => value.toLowerCase().contains(needle));
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

List<String> _splitTags(String value) => value
    .split(',')
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .toList();

String _demandLabel(int count, bool isActive) =>
    '$count demand signals${isActive ? '' : ' +'}';

String _relativeTime(DateTime value) {
  final difference = prototypeNow.difference(value);
  if (difference.isNegative || difference.inMinutes <= 0) {
    return 'just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}

String _money(int amount) => '\$${amount.toString()}';
