part of '../main.dart';

class _LeftRail extends StatelessWidget {
  const _LeftRail({
    required this.repository,
    this.onCreateProject,
    this.onCreateThread,
    this.onCreateEvent,
    this.onCreateCommunity,
    this.onCreateChannel,
    this.onOpenFoundation,
    this.onOpenChannel,
    this.onOpenCommunity,
    this.selectedChannelId,
    this.selectedCommunityId,
    this.foundationSelected = false,
  });

  final MockRepository repository;
  final VoidCallback? onCreateProject;
  final VoidCallback? onCreateThread;
  final VoidCallback? onCreateEvent;
  final VoidCallback? onCreateCommunity;
  final VoidCallback? onCreateChannel;
  final VoidCallback? onOpenFoundation;
  final ValueChanged<MockChannel>? onOpenChannel;
  final ValueChanged<MockCommunity>? onOpenCommunity;
  final String? selectedChannelId;
  final String? selectedCommunityId;
  final bool foundationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _sidePaneSurface(context),
        border: Border(right: BorderSide(color: _paneDivider(context))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: _LeftRailSections(
          repository: repository,
          onCreateProject: onCreateProject,
          onCreateThread: onCreateThread,
          onCreateEvent: onCreateEvent,
          onCreateCommunity: onCreateCommunity,
          onCreateChannel: onCreateChannel,
          onOpenFoundation: onOpenFoundation,
          onOpenChannel: onOpenChannel,
          onOpenCommunity: onOpenCommunity,
          selectedChannelId: selectedChannelId,
          selectedCommunityId: selectedCommunityId,
          foundationSelected: foundationSelected,
        ),
      ),
    );
  }
}

class _LeftRailSections extends StatelessWidget {
  const _LeftRailSections({
    required this.repository,
    this.onCreateProject,
    this.onCreateThread,
    this.onCreateEvent,
    this.onCreateCommunity,
    this.onCreateChannel,
    this.onOpenFoundation,
    this.onOpenChannel,
    this.onOpenCommunity,
    this.selectedChannelId,
    this.selectedCommunityId,
    this.foundationSelected = false,
  });

  final MockRepository repository;
  final VoidCallback? onCreateProject;
  final VoidCallback? onCreateThread;
  final VoidCallback? onCreateEvent;
  final VoidCallback? onCreateCommunity;
  final VoidCallback? onCreateChannel;
  final VoidCallback? onOpenFoundation;
  final ValueChanged<MockChannel>? onOpenChannel;
  final ValueChanged<MockCommunity>? onOpenCommunity;
  final String? selectedChannelId;
  final String? selectedCommunityId;
  final bool foundationSelected;

  @override
  Widget build(BuildContext context) {
    final stewardshipChannel = repository.channelById('stewardship');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RailGroup(
          index: 0,
          title: 'Create',
          subtitle: 'Start a new production, service, or discussion surface.',
          child: _QuickActions(
            onCreateProject: onCreateProject,
            onCreateThread: onCreateThread,
            onCreateEvent: onCreateEvent,
            onCreateCommunity: onCreateCommunity,
            onCreateChannel: onCreateChannel,
          ),
        ),
        const SizedBox(height: 12),
        _RailGroup(
          index: 1,
          title: 'Collective',
          subtitle: 'Shared governance, land, and common assets.',
          child: _LinkList(
            items: [
              _RailLinkItem(
                label: 'Assets',
                active: foundationSelected,
                onTap: onOpenFoundation,
              ),
              if (stewardshipChannel != null)
                _RailLinkItem(
                  label: stewardshipChannel.name,
                  active: selectedChannelId == stewardshipChannel.id,
                  onTap: onOpenChannel == null
                      ? null
                      : () => onOpenChannel!(stewardshipChannel),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _RailGroup(
          index: 2,
          title: 'Channels',
          subtitle:
              'Topic-based discovery across projects, threads, and events.',
          child: _LinkList(
            items: [
              for (final item in repository.channels)
                if (!repository.isStewardshipChannel(item))
                  _RailLinkItem(
                    label: item.name,
                    active: selectedChannelId == item.id,
                    onTap: onOpenChannel == null
                        ? null
                        : () => onOpenChannel!(item),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _RailGroup(
          index: 3,
          title: 'Communities',
          subtitle: 'Social coordination spaces around shared work.',
          child: _LinkList(
            items: [
              for (final item in repository.communities)
                _RailLinkItem(
                  label: item.name,
                  active: selectedCommunityId == item.id,
                  onTap: onOpenCommunity == null
                      ? null
                      : () => onOpenCommunity!(item),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RightRail extends StatelessWidget {
  const _RightRail({
    required this.repository,
    this.onOpenProject,
    this.onOpenPlan,
    this.onOpenEvent,
  });

  final MockRepository repository;
  final void Function(MockProject project, {MockProjectTab initialTab})?
  onOpenProject;
  final void Function(MockPlan plan)? onOpenPlan;
  final void Function(MockProject project, MockEvent event)? onOpenEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _sidePaneSurface(context),
        border: Border(left: BorderSide(color: _paneDivider(context))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
        child: _RightRailContent(
          repository: repository,
          onOpenProject: onOpenProject,
          onOpenPlan: onOpenPlan,
          onOpenEvent: onOpenEvent,
        ),
      ),
    );
  }
}

class _RightRailContent extends StatelessWidget {
  const _RightRailContent({
    required this.repository,
    this.onOpenProject,
    this.onOpenPlan,
    this.onOpenEvent,
  });

  final MockRepository repository;
  final void Function(MockProject project, {MockProjectTab initialTab})?
  onOpenProject;
  final void Function(MockPlan plan)? onOpenPlan;
  final void Function(MockProject project, MockEvent event)? onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final events = repository.upcomingEvents();
    final funds = repository.openFunds();
    final projectActivityItems = <_RailSnapshotItem>[
      for (final item in events)
        _RailSnapshotItem(
          title: item.event.title,
          body: 'Activity - ${item.project.title} - ${item.event.timeLabel}',
          time: item.event.lastActivity ?? item.event.createdAt ?? prototypeNow,
          onTap: onOpenEvent != null
              ? () => onOpenEvent!(item.project, item.event)
              : onOpenProject == null
              ? null
              : () => onOpenProject!(
                  item.project,
                  initialTab: MockProjectTab.events,
                ),
        ),
    ]..sort((left, right) => right.time.compareTo(left.time));
    final latestUpdateItems = <_RailSnapshotItem>[
      for (final project in repository.projects)
        if (repository.latestUpdateForProject(project.id) case final update?)
          _RailSnapshotItem(
            title: update.title,
            body: 'Update - ${project.title} - ${_relativeTime(update.time)}',
            time: update.time,
            onTap: onOpenProject == null
                ? null
                : () => onOpenProject!(
                    project,
                    initialTab: MockProjectTab.updates,
                  ),
          ),
    ]..sort((left, right) => right.time.compareTo(left.time));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RailGroup(
          index: 0,
          title: 'Project activity',
          subtitle: 'Upcoming scheduled activity inside projects.',
          child: Column(
            children: [
              if (projectActivityItems.isEmpty)
                const _MiniRow(
                  title: 'No project activity',
                  body: 'Nothing is scheduled right now.',
                  inverted: true,
                )
              else
                for (final item in projectActivityItems.take(4)) ...[
                  _MiniRow(
                    title: item.title,
                    body: item.body,
                    inverted: true,
                    onTap: item.onTap,
                  ),
                  const SizedBox(height: 4),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _RailGroup(
          index: 1,
          title: 'Latest updates',
          subtitle: 'Recent project update posts.',
          child: Column(
            children: [
              if (latestUpdateItems.isEmpty)
                const _MiniRow(
                  title: 'No recent updates',
                  body: 'Projects have not posted new updates yet.',
                  inverted: true,
                )
              else
                for (final item in latestUpdateItems.take(4)) ...[
                  _MiniRow(
                    title: item.title,
                    body: item.body,
                    inverted: true,
                    onTap: item.onTap,
                  ),
                  const SizedBox(height: 4),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _RailGroup(
          index: 2,
          title: 'Open funds',
          subtitle: 'Projects currently raising shared cash contributions.',
          child: Column(
            children: [
              for (final fund in funds) ...[
                _RailFundRow(
                  project: fund,
                  onTap: onOpenProject == null
                      ? null
                      : () => onOpenProject!(
                          fund,
                          initialTab: MockProjectTab.fund,
                        ),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RailSnapshotItem {
  const _RailSnapshotItem({
    required this.title,
    required this.body,
    required this.time,
    this.onTap,
  });

  final String title;
  final String body;
  final DateTime time;
  final VoidCallback? onTap;
}

class _RailFundRow extends StatelessWidget {
  const _RailFundRow({required this.project, this.onTap});

  final MockProject project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fund = project.fund!;
    final progress = fund.goal == 0 ? 0.0 : fund.raised / fund.goal;
    final row = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      decoration: BoxDecoration(
        color: _appSurfaceStrong(
          context,
        ).withValues(alpha: _isDarkTheme(context) ? 0.58 : 0.38),
        borderRadius: BorderRadius.circular(6),
        border: Border(bottom: BorderSide(color: _paneDivider(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            '${_money(fund.raised)} of ${_money(fund.goal)} - ${fund.deadlineLabel}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: _progressTrack(context),
            color: _fundProgressColor(context, progress),
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: _rowHoverOverlay(context),
        child: row,
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    this.onCreateProject,
    this.onCreateThread,
    this.onCreateEvent,
    this.onCreateCommunity,
    this.onCreateChannel,
  });

  final VoidCallback? onCreateProject;
  final VoidCallback? onCreateThread;
  final VoidCallback? onCreateEvent;
  final VoidCallback? onCreateCommunity;
  final VoidCallback? onCreateChannel;

  @override
  Widget build(BuildContext context) {
    return _LinkList(
      items: [
        _RailLinkItem(
          label: 'Project',
          leading: '+',
          prominent: true,
          onTap: onCreateProject,
        ),
        _RailLinkItem(
          label: 'Thread',
          leading: '+',
          prominent: true,
          onTap: onCreateThread,
        ),
        _RailLinkItem(
          label: 'Event',
          leading: '+',
          prominent: true,
          onTap: onCreateEvent,
        ),
        _RailLinkItem(
          label: 'Community',
          leading: '+',
          prominent: true,
          onTap: onCreateCommunity,
        ),
        _RailLinkItem(
          label: 'Channel',
          leading: '+',
          prominent: true,
          onTap: onCreateChannel,
        ),
      ],
    );
  }
}

class _LinkList extends StatelessWidget {
  const _LinkList({required this.items});

  final List<_RailLinkItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items) ...[
          Container(
            decoration: BoxDecoration(
              color: item.active
                  ? _appSurfaceStrong(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: item.active
                  ? Border(
                      left: BorderSide(
                        color: _interactionAccent(context),
                        width: 2.5,
                      ),
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      if (item.leading != null) ...[
                        SizedBox(
                          width: 12,
                          child: Text(
                            item.leading!,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: item.prominent
                                      ? _interactionAccent(context)
                                      : _appMuted(context),
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: item.active || item.prominent
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color
                                    : _appMuted(context),
                                fontWeight: item.active || item.prominent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),
        ],
      ],
    );
  }
}

class _RailLinkItem {
  const _RailLinkItem({
    required this.label,
    this.onTap,
    this.active = false,
    this.leading,
    this.prominent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool active;
  final String? leading;
  final bool prominent;
}

class _RailGroup extends StatelessWidget {
  const _RailGroup({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final int index;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({
    required this.currentDestination,
    required this.currentUsername,
    required this.onOpenFeed,
    required this.onOpenPersonal,
    required this.onOpenSearch,
    required this.onOpenOnboarding,
    required this.onOpenNotifications,
    required this.onOpenMessenger,
    required this.onOpenProfile,
    required this.onOpenSettings,
  });

  final MockShellDestination currentDestination;
  final String currentUsername;
  final VoidCallback onOpenFeed;
  final VoidCallback onOpenPersonal;
  final ValueChanged<String> onOpenSearch;
  final VoidCallback onOpenOnboarding;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenMessenger;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final menuActive =
        currentDestination == MockShellDestination.onboarding ||
        currentDestination == MockShellDestination.profile ||
        currentDestination == MockShellDestination.settings;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _toolbarSurface(context),
        border: Border(bottom: BorderSide(color: _paneDivider(context))),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _BrandButton(onTap: onOpenFeed),
          ),
          _PanelToggleButton(
            label: 'Left panel',
            isLeft: true,
            listenable: leftRailVisibleListenable,
          ),
          const SizedBox(width: 4),
          _PanelToggleButton(
            label: 'Right panel',
            isLeft: false,
            listenable: rightRailVisibleListenable,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: _ToolbarSearchField(
                    active: currentDestination == MockShellDestination.search,
                    onSearch: onOpenSearch,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TopNavItem(
                          label: 'Public',
                          active:
                              currentDestination == MockShellDestination.feed,
                          onTap: onOpenFeed,
                        ),
                        _TopNavItem(
                          label: 'Personal',
                          active:
                              currentDestination ==
                              MockShellDestination.personal,
                          onTap: onOpenPersonal,
                        ),
                        _TopNavItem(
                          label: 'Notifications',
                          active:
                              currentDestination ==
                              MockShellDestination.notifications,
                          onTap: onOpenNotifications,
                        ),
                        _TopNavItem(
                          label: 'Messages',
                          active:
                              currentDestination ==
                              MockShellDestination.messages,
                          onTap: onOpenMessenger,
                        ),
                        _ToolbarMenuButton(
                          active: menuActive,
                          currentUsername: currentUsername,
                          onOpenProfile: onOpenProfile,
                          onOpenSettings: onOpenSettings,
                          onOpenOnboarding: onOpenOnboarding,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ToolbarSearchField extends StatefulWidget {
  const _ToolbarSearchField({required this.active, required this.onSearch});

  final bool active;
  final ValueChanged<String> onSearch;

  @override
  State<_ToolbarSearchField> createState() => _ToolbarSearchFieldState();
}

class _ToolbarSearchFieldState extends State<_ToolbarSearchField> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = controller.text.trim();
    if (query.isEmpty && widget.active) {
      return;
    }
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submitSearch(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search projects, threads, events, and channels',
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: widget.active
              ? _interactionAccent(context)
              : _appMuted(context),
        ),
        suffixIcon: IconButton(
          onPressed: _submitSearch,
          icon: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: widget.active
                ? _interactionAccent(context)
                : _appMuted(context),
          ),
        ),
        filled: true,
        fillColor: widget.active
            ? _appSurfaceStrong(context)
            : _appSurfaceSoft(context),
      ),
    );
  }
}

class _PanelToggleButton extends StatelessWidget {
  const _PanelToggleButton({
    required this.label,
    required this.isLeft,
    required this.listenable,
  });

  final String label;
  final bool isLeft;
  final ValueNotifier<bool> listenable;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, isVisible, _) {
        final icon = isLeft
            ? (isVisible
                  ? Icons.keyboard_double_arrow_left_rounded
                  : Icons.keyboard_double_arrow_right_rounded)
            : (isVisible
                  ? Icons.keyboard_double_arrow_right_rounded
                  : Icons.keyboard_double_arrow_left_rounded);

        return Tooltip(
          message: isVisible ? 'Hide $label' : 'Show $label',
          child: Material(
            color: isVisible ? _appSurfaceStrong(context) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => listenable.value = !isVisible,
              borderRadius: BorderRadius.circular(6),
              hoverColor: _rowHoverOverlay(context),
              child: SizedBox(
                width: 34,
                height: 34,
                child: Icon(
                  icon,
                  size: 18,
                  color: isVisible
                      ? _interactionAccent(context)
                      : _appMuted(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandButton extends StatelessWidget {
  const _BrandButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: _rowHoverOverlay(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: mockAccentTheme(context).badge,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _toolbarBrandIcon(context),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/brand/app-icon.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Social Production',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: _titleAccent(context)),
              ),
              Text('mock shell', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: active ? mockAccentTheme(context).soft : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          hoverColor: _rowHoverOverlay(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: active
                    ? _titleAccent(context)
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _ToolbarMenuAction { profile, settings, onboarding }

class _ToolbarMenuButton extends StatelessWidget {
  const _ToolbarMenuButton({
    required this.active,
    required this.currentUsername,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onOpenOnboarding,
  });

  final bool active;
  final String currentUsername;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenOnboarding;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ToolbarMenuAction>(
      tooltip: 'Open shell menu',
      onSelected: (value) {
        switch (value) {
          case _ToolbarMenuAction.profile:
            onOpenProfile();
            break;
          case _ToolbarMenuAction.settings:
            onOpenSettings();
            break;
          case _ToolbarMenuAction.onboarding:
            onOpenOnboarding();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_ToolbarMenuAction>(
          value: _ToolbarMenuAction.profile,
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(currentUsername)),
            ],
          ),
        ),
        PopupMenuItem<_ToolbarMenuAction>(
          value: _ToolbarMenuAction.settings,
          child: const Row(
            children: [
              Icon(Icons.settings_outlined, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('Settings')),
            ],
          ),
        ),
        PopupMenuItem<_ToolbarMenuAction>(
          value: _ToolbarMenuAction.onboarding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.flag_outlined, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text('Onboarding')),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Temporary shell shortcut',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Material(
          color: active ? mockAccentTheme(context).soft : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            hoverColor: _rowHoverOverlay(context),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.settings_outlined,
                size: 19,
                color: active
                    ? _titleAccent(context)
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowToolbarButtons extends StatelessWidget {
  const _WindowToolbarButtons({required this.brightness});
  final Brightness brightness;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}