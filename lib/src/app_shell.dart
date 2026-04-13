part of '../main.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ValueNotifier<bool> themeModeListenable = ValueNotifier<bool>(true);
  final ValueNotifier<MockAccentKind> accentListenable =
      ValueNotifier<MockAccentKind>(MockAccentKind.green);
  final ValueNotifier<MockFontKind> fontListenable =
      ValueNotifier<MockFontKind>(MockFontKind.inter);

  @override
  void dispose() {
    fontListenable.dispose();
    accentListenable.dispose();
    themeModeListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeModeListenable,
      builder: (context, isDarkMode, _) {
        return ValueListenableBuilder<MockAccentKind>(
          valueListenable: accentListenable,
          builder: (context, accentKind, _) {
            return ValueListenableBuilder<MockFontKind>(
              valueListenable: fontListenable,
              builder: (context, fontKind, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: buildMockTheme(
                    isDarkMode: isDarkMode,
                    accentKind: accentKind,
                    fontKind: fontKind,
                  ),
                  title: 'Social Production Mock App',
                  home: MockHomePage(
                    themeModeListenable: themeModeListenable,
                    accentListenable: accentListenable,
                    fontListenable: fontListenable,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

enum MockShellDestination {
  feed,
  personal,
  foundation,
  search,
  onboarding,
  notifications,
  messages,
  profile,
  settings,
}

class MockHomePage extends StatefulWidget {
  const MockHomePage({
    super.key,
    required this.themeModeListenable,
    required this.accentListenable,
    required this.fontListenable,
  });

  final ValueNotifier<bool> themeModeListenable;
  final ValueNotifier<MockAccentKind> accentListenable;
  final ValueNotifier<MockFontKind> fontListenable;

  @override
  State<MockHomePage> createState() => _MockHomePageState();
}

class _MockHomePageState extends State<MockHomePage> {
  final MockRepository repository = MockRepository();
  final Map<String, int> votes = <String, int>{};
  final Map<String, int> planVotes = <String, int>{};
  final Map<String, bool> demandSignals = <String, bool>{};
  final Map<String, bool> rsvpEvents = <String, bool>{};
  final Map<String, bool> readNotifications = <String, bool>{};
  final Map<String, bool> subscribedChannels = <String, bool>{};
  final Map<String, bool> channelNotifications = <String, bool>{};
  final Map<String, bool> joinedCommunities = <String, bool>{};
  final Map<String, bool> communityNotifications = <String, bool>{};
  final Map<String, int> governanceVotes = <String, int>{};
  final Set<String> removedGovernance = <String>{};

  MockFeedScope scope = MockFeedScope.home;
  MockFeedFilter filter = MockFeedFilter.all;
  MockFeedSort sort = MockFeedSort.latest;
  late String currentUsername;
  late String currentLocation;
  late String currentBio;
  String nodeMode = 'light';
  bool showLocation = true;
  bool publicAcknowledgement = false;
  bool sharePublicCommentsInPersonal = true;
  String? currentAvatarLabel;

  @override
  void initState() {
    super.initState();
    final user = repository.userById(mockCurrentUserId)!;
    currentUsername = user.username;
    currentLocation = user.location;
    currentBio = user.bio;
  }

  MockUser get currentUser {
    final base = repository.userById(mockCurrentUserId)!;
    return MockUser(
      id: base.id,
      username: currentUsername,
      name: currentUsername,
      location: currentLocation,
      bio: currentBio,
      avatarLabel: currentAvatarLabel,
    );
  }

  String _governanceKey(String scopeId, String userId) => '$scopeId::$userId';

  void setVote(String id, int value) {
    setState(() {
      final current = votes[id] ?? 0;
      votes[id] = current == value ? 0 : value;
    });
  }

  void setPlanVote(String id, int value) {
    setState(() {
      final current = planVotes[id] ?? 0;
      planVotes[id] = current == value ? 0 : value;
    });
  }

  void toggleDemand(String projectId) {
    setState(() {
      demandSignals[projectId] = !(demandSignals[projectId] ?? false);
    });
  }

  void toggleRsvp(String eventId) {
    setState(() {
      rsvpEvents[eventId] = !(rsvpEvents[eventId] ?? false);
    });
  }

  void toggleChannelSubscription(String channelId) {
    setState(() {
      final nextValue = !(subscribedChannels[channelId] ?? false);
      subscribedChannels[channelId] = nextValue;
      if (!nextValue) {
        channelNotifications.remove(channelId);
      }
    });
  }

  void toggleChannelNotifications(String channelId) {
    setState(() {
      channelNotifications[channelId] =
          !(channelNotifications[channelId] ?? true);
    });
  }

  void toggleCommunityMembership(String communityId) {
    setState(() {
      final nextValue = !(joinedCommunities[communityId] ?? false);
      joinedCommunities[communityId] = nextValue;
      if (!nextValue) {
        communityNotifications.remove(communityId);
      }
    });
  }

  void toggleCommunityNotifications(String communityId) {
    setState(() {
      communityNotifications[communityId] =
          !(communityNotifications[communityId] ?? true);
    });
  }

  void setGovernanceVote(String scopeId, String userId, int value) {
    setState(() {
      final key = _governanceKey(scopeId, userId);
      final current = governanceVotes[key] ?? 0;
      governanceVotes[key] = current == value ? 0 : value;
    });
  }

  void toggleGovernanceRemoval(String scopeId, String userId) {
    setState(() {
      final key = _governanceKey(scopeId, userId);
      if (removedGovernance.contains(key)) {
        removedGovernance.remove(key);
      } else {
        removedGovernance.add(key);
      }
    });
  }

  Widget _buildInteractiveLeftRail({
    String? selectedChannelId,
    String? selectedCommunityId,
    bool foundationSelected = false,
  }) {
    return _LeftRail(
      repository: repository,
      onCreateProject: openCreateProject,
      onCreateThread: openCreateThread,
      onCreateEvent: () => openCreateEvent(),
      onCreateCommunity: openCreateCommunity,
      onCreateChannel: openCreateChannel,
      onOpenFoundation: openFoundation,
      onOpenChannel: openChannel,
      onOpenCommunity: openCommunity,
      selectedChannelId: selectedChannelId,
      selectedCommunityId: selectedCommunityId,
      foundationSelected: foundationSelected,
    );
  }

  Widget _buildInlineLeftRailContent({
    String? selectedChannelId,
    String? selectedCommunityId,
    bool foundationSelected = false,
  }) {
    return _LeftRailSections(
      repository: repository,
      onCreateProject: openCreateProject,
      onCreateThread: openCreateThread,
      onCreateEvent: () => openCreateEvent(),
      onCreateCommunity: openCreateCommunity,
      onCreateChannel: openCreateChannel,
      onOpenFoundation: openFoundation,
      onOpenChannel: openChannel,
      onOpenCommunity: openCommunity,
      selectedChannelId: selectedChannelId,
      selectedCommunityId: selectedCommunityId,
      foundationSelected: foundationSelected,
    );
  }

  void openProject(
    MockProject project, {
    MockProjectTab initialTab = MockProjectTab.overview,
    String? initialEventId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ProjectPage(
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          repository: repository,
          currentUser: currentUser,
          sharePublicCommentsInPersonal: sharePublicCommentsInPersonal,
          project: project,
          initialTab: initialTab,
          initialEventId: initialEventId,
          votes: votes,
          demandSignals: demandSignals,
          rsvpEvents: rsvpEvents,
          governanceVotes: governanceVotes,
          removedGovernance: removedGovernance,
          onVote: setVote,
          onToggleDemand: toggleDemand,
          onToggleRsvp: toggleRsvp,
          onGovernanceVote: setGovernanceVote,
          onToggleGovernanceRemoval: toggleGovernanceRemoval,
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenPlan: openPlan,
          onOpenProfile: openProfile,
          onOpenAsset: openFoundationAsset,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openThread(MockThread thread) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ThreadPage(
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          repository: repository,
          thread: thread,
          sharePublicCommentsInPersonal: sharePublicCommentsInPersonal,
          votes: votes,
          onVote: setVote,
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openPlan(MockPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PlanPage(
          repository: repository,
          plan: plan,
          planVotes: planVotes,
          onVote: setPlanVote,
          onOpenProject: openProject,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openEvent(MockProject project, MockEvent event) {
    openProject(
      project,
      initialTab: MockProjectTab.events,
      initialEventId: event.id,
    );
  }

  void openStandaloneEvent(MockEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _StandaloneEventDetailPage(
          repository: repository,
          event: event,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          rsvpEvents: rsvpEvents,
          onToggleRsvp: toggleRsvp,
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openChannel(MockChannel channel) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ChannelPage(
          repository: repository,
          channel: channel,
          currentUserId: currentUser.id,
          leftRail: _buildInteractiveLeftRail(selectedChannelId: channel.id),
          votes: votes,
          governanceVotes: governanceVotes,
          removedGovernance: removedGovernance,
          subscribedChannels: subscribedChannels,
          channelNotifications: channelNotifications,
          onVote: setVote,
          onGovernanceVote: setGovernanceVote,
          onToggleGovernanceRemoval: toggleGovernanceRemoval,
          onToggleSubscription: toggleChannelSubscription,
          onToggleNotifications: toggleChannelNotifications,
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenStandaloneEvent: openStandaloneEvent,
          onOpenChannel: openChannel,
          onOpenCommunity: openCommunity,
          onOpenProfile: openProfile,
          onCreateProject: openCreateProject,
          onCreateThread: openCreateThread,
          onCreateEvent: openCreateEvent,
          topNav: _buildTopNav(),
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openCommunity(MockCommunity community) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CommunityPage(
          repository: repository,
          community: community,
          currentUserId: currentUser.id,
          leftRail: _buildInteractiveLeftRail(
            selectedCommunityId: community.id,
          ),
          votes: votes,
          governanceVotes: governanceVotes,
          removedGovernance: removedGovernance,
          joinedCommunities: joinedCommunities,
          communityNotifications: communityNotifications,
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenStandaloneEvent: openStandaloneEvent,
          onOpenChannel: openChannel,
          onOpenCommunity: openCommunity,
          onOpenProfile: openProfile,
          onCreateThread: openCreateThread,
          onCreateEvent: openCreateEvent,
          topNav: _buildTopNav(),
          onVote: setVote,
          onGovernanceVote: setGovernanceVote,
          onToggleGovernanceRemoval: toggleGovernanceRemoval,
          onToggleMembership: toggleCommunityMembership,
          onToggleNotifications: toggleCommunityNotifications,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  Future<void> openOnboarding() async {
    final result = await Navigator.of(context).push<_OnboardingResult>(
      MaterialPageRoute<_OnboardingResult>(
        builder: (context) => _OnboardingPage(
          repository: repository,
          initialUsername: currentUsername,
          initialLocation: currentLocation,
          initialBio: currentBio,
          initialNodeMode: nodeMode,
          initialShowLocation: showLocation,
          initialPublicAcknowledgement: publicAcknowledgement,
          initialSubscribedChannelIds: subscribedChannels.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toSet(),
          initialJoinedCommunityIds: joinedCommunities.entries
              .where((entry) => entry.value)
              .map((entry) => entry.key)
              .toSet(),
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.onboarding,
          ),
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      currentUsername = result.username;
      currentLocation = result.location;
      currentBio = result.bio;
      nodeMode = result.nodeMode;
      showLocation = result.showLocation;
      publicAcknowledgement = result.publicAcknowledgement;

      subscribedChannels
        ..clear()
        ..addEntries(result.selectedChannelIds.map((id) => MapEntry(id, true)));
      joinedCommunities
        ..clear()
        ..addEntries(
          result.selectedCommunityIds.map((id) => MapEntry(id, true)),
        );
    });

    goHome();
  }

  void openFoundation() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _FoundationPage(
          repository: repository,
          leftRail: _buildInteractiveLeftRail(foundationSelected: true),
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.foundation,
          ),
          onOpenProject: openProject,
          onOpenAsset: openFoundationAsset,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openFoundationAsset(MockFoundationAsset asset) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AssetDetailPage(
          repository: repository,
          asset: asset,
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.foundation,
          ),
          leftRail: _buildInteractiveLeftRail(foundationSelected: true),
          onOpenProject: openProject,
          onOpenAsset: openFoundationAsset,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openSearch({String initialQuery = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _SearchPage(
          repository: repository,
          initialQuery: initialQuery,
          leftRail: _buildInteractiveLeftRail(),
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenStandaloneEvent: openStandaloneEvent,
          onOpenChannel: openChannel,
          onOpenCommunity: openCommunity,
          onOpenProfile: openProfile,
          topNav: _buildTopNav(currentDestination: MockShellDestination.search),
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _NotificationsPage(
          repository: repository,
          readNotifications: readNotifications,
          leftRail: _buildInteractiveLeftRail(),
          onMarkRead: markRead,
          onMarkAllRead: markAllRead,
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.notifications,
          ),
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openMessenger() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _MessengerPage(
          repository: repository,
          currentUserId: currentUser.id,
          leftRail: _buildInteractiveLeftRail(),
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.messages,
          ),
          onOpenProfile: openProfile,
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  Future<void> openConversation(MockDirectConversation conversation) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _DirectConversationPage(
          repository: repository,
          currentUserId: currentUser.id,
          conversation: conversation,
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.messages,
          ),
          leftRail: _buildInteractiveLeftRail(),
          onOpenProfile: openProfile,
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openConversationWithUser(MockUser user) {
    final conversation = repository.conversationWithUser(
      currentUser.id,
      user.id,
    );
    openConversation(conversation);
  }

  void openPersonalFeed() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _PersonalFeedPage(
          repository: repository,
          currentUserId: currentUser.id,
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.personal,
          ),
          leftRail: _buildInteractiveLeftRail(),
          onOpenProfile: openProfile,
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenStandaloneEvent: openStandaloneEvent,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _SettingsPage(
          repository: repository,
          currentUser: currentUser,
          currentAvatarLabel: currentAvatarLabel,
          sharePublicCommentsInPersonal: sharePublicCommentsInPersonal,
          leftRail: _buildInteractiveLeftRail(),
          themeModeListenable: widget.themeModeListenable,
          accentListenable: widget.accentListenable,
          fontListenable: widget.fontListenable,
          nodeMode: nodeMode,
          showLocation: showLocation,
          publicAcknowledgement: publicAcknowledgement,
          onUsernameChanged: (value) => setState(() => currentUsername = value),
          onLocationChanged: (value) => setState(() => currentLocation = value),
          onBioChanged: (value) => setState(() => currentBio = value),
          onNodeModeChanged: (value) => setState(() => nodeMode = value),
          onShowLocationChanged: (value) =>
              setState(() => showLocation = value),
          onPublicAcknowledgementChanged: (value) =>
              setState(() => publicAcknowledgement = value),
          onAvatarLabelChanged: (value) =>
              setState(() => currentAvatarLabel = value),
          onSharePublicCommentsInPersonalChanged: (value) => setState(() {
            sharePublicCommentsInPersonal = value;
            if (!value) {
              repository.removePersonalCommentSharesForAuthor(currentUser.id);
            }
          }),
          onOpenProfile: () => openProfile(currentUser),
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.settings,
          ),
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openProfile(MockUser user) {
    final resolved = user.id == mockCurrentUserId ? currentUser : user;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ProfilePage(
          repository: repository,
          user: resolved,
          currentUserId: currentUser.id,
          showLocation: resolved.id == mockCurrentUserId ? showLocation : true,
          leftRail: _buildInteractiveLeftRail(),
          onOpenProject: openProject,
          onOpenThread: openThread,
          onOpenStandaloneEvent: openStandaloneEvent,
          onOpenChannel: openChannel,
          onOpenCommunity: openCommunity,
          onOpenConversation: openConversationWithUser,
          onOpenProfile: openProfile,
          onToggleFollow: resolved.id == currentUser.id
              ? null
              : () => setState(
                  () => repository.toggleFollowing(currentUser.id, resolved.id),
                ),
          topNav: _buildTopNav(
            currentDestination: MockShellDestination.profile,
          ),
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openCreateProject() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CreateProjectPage(
          repository: repository,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openCreateThread() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CreateThreadPage(
          repository: repository,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openCreateEvent({String? initialChannelId, String? initialCommunityId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CreateEventPage(
          repository: repository,
          currentUserId: currentUser.id,
          initialChannelId: initialChannelId,
          initialCommunityId: initialCommunityId,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          onEventCreated: (event) {
            setState(() {});
            openStandaloneEvent(event);
          },
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openCreateCommunity() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CreateCommunityPage(
          repository: repository,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void openCreateChannel() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _CreateChannelPage(
          repository: repository,
          topNav: _buildTopNav(),
          leftRail: _buildInteractiveLeftRail(),
          onOpenProject: openProject,
          onOpenPlan: openPlan,
          onOpenEvent: openEvent,
        ),
      ),
    );
  }

  void goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void markRead(String id) {
    setState(() {
      readNotifications[id] = true;
    });
  }

  void markAllRead() {
    setState(() {
      for (final item in repository.notifications) {
        readNotifications[item.id] = true;
      }
    });
  }

  Widget _buildTopNav({
    MockShellDestination currentDestination = MockShellDestination.feed,
  }) {
    return _TopNav(
      currentDestination: currentDestination,
      currentUsername: currentUser.username,
      onOpenFeed: goHome,
      onOpenPersonal: currentDestination == MockShellDestination.personal
          ? () {}
          : openPersonalFeed,
      onOpenSearch: (query) => openSearch(initialQuery: query),
      onOpenOnboarding: () {
        openOnboarding();
      },
      onOpenNotifications: openNotifications,
      onOpenMessenger: openMessenger,
      onOpenProfile: () => openProfile(currentUser),
      onOpenSettings: openSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feed = repository.buildFeed(
      scope: scope,
      filter: filter,
      sort: sort,
      votes: votes,
      viewerUserId: currentUser.id,
    );
    final topNav = _buildTopNav();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            topNav,
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  leftRailVisibleListenable,
                  rightRailVisibleListenable,
                ]),
                builder: (context, _) {
                  final showLeftRail = leftRailVisibleListenable.value;
                  final showRightRail = rightRailVisibleListenable.value;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 1180) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showLeftRail)
                              SizedBox(
                                width: 232,
                                child: _buildInteractiveLeftRail(),
                              ),
                            Expanded(
                              child: _FeedColumn(
                                repository: repository,
                                feed: feed,
                                scope: scope,
                                filter: filter,
                                sort: sort,
                                votes: votes,
                                currentUser: currentUser,
                                onScopeChanged: (value) =>
                                    setState(() => scope = value),
                                onFilterChanged: (value) =>
                                    setState(() => filter = value),
                                onSortChanged: (value) =>
                                    setState(() => sort = value),
                                onVote: setVote,
                                onOpenProject: openProject,
                                onOpenThread: openThread,
                                onOpenStandaloneEvent: openStandaloneEvent,
                              ),
                            ),
                            if (showRightRail)
                              SizedBox(
                                width: 264,
                                child: _RightRail(
                                  repository: repository,
                                  onOpenProject: openProject,
                                  onOpenPlan: openPlan,
                                ),
                              ),
                          ],
                        );
                      }

                      return SingleChildScrollView(
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
                              onScopeChanged: (value) =>
                                  setState(() => scope = value),
                              onFilterChanged: (value) =>
                                  setState(() => filter = value),
                              onSortChanged: (value) =>
                                  setState(() => sort = value),
                            ),
                            if (showLeftRail) ...[
                              const SizedBox(height: 12),
                              _SectionCard(
                                child: _buildInlineLeftRailContent(),
                              ),
                            ],
                            const SizedBox(height: 12),
                            for (final entry in feed)
                              _FeedCard(
                                repository: repository,
                                entry: entry,
                                votes: votes,
                                onVote: setVote,
                                onOpenProject: openProject,
                                onOpenThread: openThread,
                                onOpenStandaloneEvent: openStandaloneEvent,
                              ),
                            if (showRightRail) ...[
                              const SizedBox(height: 12),
                              _SectionCard(
                                child: _RightRailContent(
                                  repository: repository,
                                  onOpenProject: openProject,
                                  onOpenPlan: openPlan,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
