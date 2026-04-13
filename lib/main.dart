import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

import 'src/mock_data.dart';
import 'src/mock_theme.dart';

bool get _desktopWindowControlsEnabled =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

final ValueNotifier<bool> leftRailVisibleListenable = ValueNotifier<bool>(true);
final ValueNotifier<bool> rightRailVisibleListenable = ValueNotifier<bool>(
  true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_desktopWindowControlsEnabled) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1440, 920),
      minimumSize: Size(1120, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: 'Social Production Mock App',
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.show();
    await windowManager.focus();
  }

  runApp(const MainApp());
}

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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _EventDetailPage(
          repository: repository,
          project: project,
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
            : 'Latest update · ${_relativeTime(latestUpdate.time)}',
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

class _PageTabChip extends StatelessWidget {
  const _PageTabChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _PageActionChip extends StatelessWidget {
  const _PageActionChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: false,
      onSelected: (_) => onPressed(),
    );
  }
}

class _PageHeaderActions extends StatelessWidget {
  const _PageHeaderActions({
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.notificationsEnabled,
    required this.canToggleNotifications,
    required this.onToggleNotifications,
    required this.disabledNotificationHint,
  });

  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final bool notificationsEnabled;
  final bool canToggleNotifications;
  final VoidCallback onToggleNotifications;
  final String disabledNotificationHint;

  @override
  Widget build(BuildContext context) {
    final bell = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: notificationsEnabled
            ? mockAccentTheme(context).soft
            : _appSurfaceStrong(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notificationsEnabled
              ? _interactionAccent(context)
              : _appBorder(context),
        ),
      ),
      child: Icon(
        Icons.notifications_rounded,
        size: 20,
        color: notificationsEnabled
            ? _titleAccent(context)
            : _appMuted(context),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: canToggleNotifications
              ? (notificationsEnabled
                    ? 'Notifications on'
                    : 'Notifications off')
              : disabledNotificationHint,
          child: Opacity(
            opacity: canToggleNotifications ? 1 : 0.6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canToggleNotifications ? onToggleNotifications : null,
                borderRadius: BorderRadius.circular(8),
                hoverColor: _rowHoverOverlay(context),
                child: bell,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: onPrimaryPressed, child: Text(primaryLabel)),
      ],
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
              '${_money(project.fund!.raised)} of ${_money(project.fund!.goal)} · ${project.fund!.deadlineLabel}',
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
                '${project.memberIds.length} members · ${_relativeTime(project.lastActivity)}',
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
                '${author?.username ?? 'unknown'} · ${_relativeTime(thread.lastActivity)}',
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
            '${event.timeLabel} · ${event.location}',
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
                '${_userHandle(creator)} · ${_relativeTime(event.lastActivity ?? event.createdAt ?? prototypeNow)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
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
    final eventAndActivityItems = <_RailSnapshotItem>[
      for (final item in events)
        _RailSnapshotItem(
          title: item.event.title,
          body: 'Event · ${item.project.title} · ${item.event.timeLabel}',
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
      for (final project in repository.projects)
        if (repository.latestUpdateForProject(project.id) case final update?)
          _RailSnapshotItem(
            title: update.title,
            body: 'Update · ${project.title} · ${_relativeTime(update.time)}',
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
          title: 'Events and activity',
          subtitle: 'Near-term events and the latest visible project movement.',
          child: Column(
            children: [
              for (final item in eventAndActivityItems.take(4)) ...[
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
            '${_money(fund.raised)} of ${_money(fund.goal)} · ${fund.deadlineLabel}',
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

class _VoteStrip extends StatelessWidget {
  const _VoteStrip({
    required this.id,
    required this.count,
    required this.activeVote,
    required this.onVote,
  });

  final String id;
  final int count;
  final int activeVote;
  final void Function(String id, int value) onVote;

  @override
  Widget build(BuildContext context) {
    final voteColor = switch (activeVote) {
      1 => _positiveVoteColor(context),
      -1 => _negativeVoteColor(context),
      _ => Theme.of(context).textTheme.labelLarge?.color,
    };

    return Container(
      decoration: BoxDecoration(
        color: _appSurfaceStrong(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onVote(id, 1),
            icon: Icon(
              Icons.keyboard_arrow_up,
              color: activeVote == 1
                  ? _positiveVoteColor(context)
                  : _appMuted(context),
            ),
          ),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: voteColor),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => onVote(id, -1),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: activeVote == -1
                  ? _negativeVoteColor(context)
                  : _appMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TagChipKind { neutral, channel, community }

class _TagChipData {
  const _TagChipData({required this.label, this.kind = _TagChipKind.neutral});

  final String label;
  final _TagChipKind kind;
}

class _AccentTone {
  const _AccentTone({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _appSurfaceStrong(
          context,
        ).withValues(alpha: _isDarkTheme(context) ? 0.72 : 0.58),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      ),
    );

    if (onTap == null) {
      return pill;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: _rowHoverOverlay(context),
        child: pill,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
    this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final semanticTone = _semanticChipTone(context, label);
    final resolvedBackground = _resolveChipBackground(context, background);
    final resolvedForeground = _resolveChipForeground(context, foreground);

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: semanticTone?.background ?? resolvedBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
              border ??
              semanticTone?.foreground.withValues(alpha: 0.22) ??
              Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: semanticTone?.foreground ?? resolvedForeground,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        hoverColor: _rowHoverOverlay(context),
        child: chip,
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({
    this.labels = const <String>[],
    this.items = const <_TagChipData>[],
    this.alignEnd = false,
  });

  final List<String> labels;
  final List<_TagChipData> items;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final resolvedItems = items.isNotEmpty
        ? items
        : [for (final label in labels) _TagChipData(label: label)];

    return Wrap(
      alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final item in resolvedItems.take(5))
          Builder(
            builder: (context) {
              final tone = _tagTone(context, item.kind);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: tone.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tone.foreground,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

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
          : '${mention.user!.location} · ${mention.user!.bio}',
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
                  label: Text('${suggestion.label} · ${suggestion.kindLabel}'),
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

class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.title,
    required this.body,
    this.inverted = false,
    this.onTap,
  });

  final String title;
  final String body;
  final bool inverted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
      decoration: BoxDecoration(
        color: inverted
            ? _appSurfaceStrong(
                context,
              ).withValues(alpha: _isDarkTheme(context) ? 0.58 : 0.38)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border(bottom: BorderSide(color: _paneDivider(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.background});

  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _appSurfaceSoft(
          context,
        ).withValues(alpha: _isDarkTheme(context) ? 0.8 : 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: _appSurface(context),
          items: [
            for (final item in values)
              DropdownMenuItem<T>(value: item, child: Text(labelBuilder(item))),
          ],
          onChanged: (selected) {
            if (selected != null) {
              onChanged(selected);
            }
          },
        ),
      ),
    );
  }
}

class _DetailShell extends StatelessWidget {
  const _DetailShell({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onOpenProject,
    this.onOpenPlan,
    this.onOpenEvent,
    this.showHeaderText = true,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final String title;
  final String subtitle;
  final Widget child;
  final void Function(MockProject project, {MockProjectTab initialTab})?
  onOpenProject;
  final void Function(MockPlan plan)? onOpenPlan;
  final void Function(MockProject project, MockEvent event)? onOpenEvent;
  final bool showHeaderText;

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back'),
        ),
        if (showHeaderText) ...[
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: _titleAccent(context)),
          ),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ],
    );

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
                              SizedBox(width: 232, child: leftRail),
                            Expanded(
                              child: Container(
                                color: _centerPaneSurface(context),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      header,
                                      const SizedBox(height: 12),
                                      child,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (showRightRail)
                              SizedBox(
                                width: 264,
                                child: _RightRail(
                                  repository: repository,
                                  onOpenProject: onOpenProject,
                                  onOpenPlan: onOpenPlan,
                                  onOpenEvent: onOpenEvent,
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
                            header,
                            const SizedBox(height: 12),
                            child,
                            if (showRightRail) ...[
                              const SizedBox(height: 12),
                              _SectionCard(
                                child: _RightRailContent(
                                  repository: repository,
                                  onOpenProject: onOpenProject,
                                  onOpenPlan: onOpenPlan,
                                  onOpenEvent: onOpenEvent,
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

class _FlowSplit extends StatelessWidget {
  const _FlowSplit({required this.primary, required this.secondary});

  final Widget primary;
  final Widget secondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 980) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: primary),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: secondary),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [primary, const SizedBox(height: 16), secondary],
        );
      },
    );
  }
}

class _FlowPanel extends StatelessWidget {
  const _FlowPanel({
    required this.title,
    required this.description,
    required this.child,
    this.surface,
  });

  final String title;
  final String description;
  final Widget child;
  final Color? surface;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      background: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

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

class _ProjectPage extends StatefulWidget {
  const _ProjectPage({
    required this.repository,
    required this.currentUser,
    required this.sharePublicCommentsInPersonal,
    required this.topNav,
    required this.leftRail,
    required this.project,
    required this.initialTab,
    required this.votes,
    required this.demandSignals,
    required this.rsvpEvents,
    required this.governanceVotes,
    required this.removedGovernance,
    required this.onVote,
    required this.onToggleDemand,
    required this.onToggleRsvp,
    required this.onGovernanceVote,
    required this.onToggleGovernanceRemoval,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenPlan,
    required this.onOpenProfile,
    required this.onOpenAsset,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockUser currentUser;
  final bool sharePublicCommentsInPersonal;
  final Widget topNav;
  final Widget leftRail;
  final MockProject project;
  final MockProjectTab initialTab;
  final Map<String, int> votes;
  final Map<String, bool> demandSignals;
  final Map<String, bool> rsvpEvents;
  final Map<String, int> governanceVotes;
  final Set<String> removedGovernance;
  final void Function(String id, int value) onVote;
  final void Function(String projectId) onToggleDemand;
  final void Function(String eventId) onToggleRsvp;
  final void Function(String scopeId, String userId, int value)
  onGovernanceVote;
  final void Function(String scopeId, String userId) onToggleGovernanceRemoval;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockUser user) onOpenProfile;
  final void Function(MockFoundationAsset asset) onOpenAsset;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<_ProjectPage> {
  late MockProjectTab selectedTab;
  final Map<String, GlobalKey> _inventoryBuildingKeys = {};
  final TextEditingController _updateTitleController = TextEditingController();
  final TextEditingController _updateBodyController = TextEditingController();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskCheckpointController =
      TextEditingController();
  final TextEditingController _acquisitionTitleController =
      TextEditingController();
  final TextEditingController _acquisitionDeadlineController =
      TextEditingController();
  final TextEditingController _acquisitionGoalController =
      TextEditingController();
  final TextEditingController _acquisitionRaisedController =
      TextEditingController();
  final TextEditingController _acquisitionItemLabelController =
      TextEditingController();
  final TextEditingController _acquisitionItemCostController =
      TextEditingController();
  final TextEditingController _transferNeedByController =
      TextEditingController();
  final TextEditingController _transferNoteController = TextEditingController();
  final TextEditingController _planTitleController = TextEditingController();
  final TextEditingController _planSummaryController = TextEditingController();
  final TextEditingController _planBodyController = TextEditingController();
  final TextEditingController _planEstimatedController =
      TextEditingController();
  final TextEditingController _planChecklistController =
      TextEditingController();
  final TextEditingController _planNeedLabelController =
      TextEditingController();
  final TextEditingController _planNeedQuantityController =
      TextEditingController();
  final TextEditingController _planNeedNoteController = TextEditingController();
  final TextEditingController _planNeedCostController = TextEditingController();
  final TextEditingController _planCostLabelController =
      TextEditingController();
  final TextEditingController _planCostAmountController =
      TextEditingController();
  final TextEditingController _planCostNoteController = TextEditingController();
  final TextEditingController _landServiceTitleController =
      TextEditingController();
  final TextEditingController _landServiceSummaryController =
      TextEditingController();
  final TextEditingController _softwareRepoTargetController =
      TextEditingController();
  final TextEditingController _softwareDiffSummaryController =
      TextEditingController();
  final TextEditingController _softwareNoteController = TextEditingController();
  String? _pendingInventoryBuildingId;
  String? _highlightedInventoryBuildingId;
  String? _selectedUpdateId;
  String? _selectedCommentId;
  String? _acquisitionProjectId;
  String? _planDraftProjectId;
  String _draftNeedAssetId = '';
  String _draftLandAssetId = '';
  String _draftExistingLandManagementProjectId = '';
  MockPlanKind _draftPlanKind = MockPlanKind.production;
  MockLandPlanAction? _draftLandAction;
  MockLandManagementSelection _draftLandManagementSelection =
      MockLandManagementSelection.existingService;
  final List<MockPlanAssetNeed> _draftPlanAssetNeeds = [];
  final List<MockPlanCostLine> _draftPlanCostLines = [];

  @override
  void initState() {
    super.initState();
    final tabs = _projectTabsFor(
      widget.project,
      currentUserId: widget.currentUser.id,
      repository: widget.repository,
    );
    _selectedUpdateId = widget.repository.takePendingProjectUpdateTarget(
      widget.project.id,
    );
    _selectedCommentId = widget.repository.takePendingProjectCommentTarget(
      widget.project.id,
    );
    selectedTab = _selectedUpdateId != null
        ? MockProjectTab.updates
        : _selectedCommentId != null
        ? MockProjectTab.discussion
        : tabs.contains(widget.initialTab)
        ? widget.initialTab
        : MockProjectTab.overview;
  }

  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  GlobalKey _inventoryBuildingKey(String buildingId) =>
      _inventoryBuildingKeys.putIfAbsent(buildingId, () => GlobalKey());

  void _openInventoryBuilding(String buildingId) {
    setState(() {
      selectedTab = MockProjectTab.inventory;
      _pendingInventoryBuildingId = buildingId;
      _highlightedInventoryBuildingId = buildingId;
    });
  }

  void _openUpdate(String updateId) {
    setState(() {
      selectedTab = MockProjectTab.updates;
      _selectedUpdateId = updateId;
    });
  }

  void _closeUpdateDetail() {
    setState(() => _selectedUpdateId = null);
  }

  void _syncAcquisitionControllers(MockProject project) {
    if (_acquisitionProjectId == project.id) {
      return;
    }
    _acquisitionProjectId = project.id;
    _acquisitionTitleController.text = project.fund?.title ?? '';
    _acquisitionDeadlineController.text = project.fund?.deadlineLabel ?? '';
    _acquisitionGoalController.text = '${project.fund?.goal ?? ''}';
    _acquisitionRaisedController.text = '${project.fund?.raised ?? ''}';
  }

  void _syncPlanDraft(MockProject project) {
    if (_planDraftProjectId == project.id) {
      return;
    }
    _planDraftProjectId = project.id;
    _resetPlanDraft(keepProjectSelection: true);
  }

  void _resetPlanDraft({bool keepProjectSelection = false}) {
    _planTitleController.clear();
    _planSummaryController.clear();
    _planBodyController.clear();
    _planEstimatedController.clear();
    _planChecklistController.clear();
    _planNeedLabelController.clear();
    _planNeedQuantityController.clear();
    _planNeedNoteController.clear();
    _planNeedCostController.clear();
    _planCostLabelController.clear();
    _planCostAmountController.clear();
    _planCostNoteController.clear();
    _draftNeedAssetId = '';
    _draftLandAssetId = '';
    _draftExistingLandManagementProjectId = '';
    _draftPlanKind = MockPlanKind.production;
    _draftLandAction = null;
    _draftLandManagementSelection = MockLandManagementSelection.existingService;
    _draftPlanAssetNeeds.clear();
    _draftPlanCostLines.clear();
    _landServiceTitleController.clear();
    _landServiceSummaryController.clear();
    if (!keepProjectSelection) {
      _planDraftProjectId = null;
    }
  }

  List<MockProject> _managedTransferTargetsFor(MockProject sourceProject) =>
      widget.repository
          .projectsManagedByUser(widget.currentUser.id)
          .where((project) => project.id != sourceProject.id)
          .toList();

  Future<void> _openProjectTransferRequestDialog({
    required MockProject sourceProject,
    required MockFoundationAsset asset,
  }) async {
    final managedProjects = _managedTransferTargetsFor(sourceProject);
    if (managedProjects.isEmpty) {
      return;
    }

    var selectedProjectId = managedProjects.first.id;
    _transferNeedByController.text = 'Need by next available handoff window';
    _transferNoteController.text = 'Request ${asset.name} for managed use.';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Request As Project'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Managers can request this asset for another project they currently manage.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProjectId,
                      decoration: const InputDecoration(
                        labelText: 'Request as project',
                      ),
                      items: [
                        for (final project in managedProjects)
                          DropdownMenuItem<String>(
                            value: project.id,
                            child: Text(project.title),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() => selectedProjectId = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _transferNeedByController,
                      decoration: const InputDecoration(
                        labelText: 'Need-by window',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _transferNoteController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Purpose'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _transferNeedByController.clear();
                    _transferNoteController.clear();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final needBy = _transferNeedByController.text.trim();
                    final note = _transferNoteController.text.trim();
                    if (needBy.isEmpty || note.isEmpty) {
                      return;
                    }
                    _refresh(
                      () => widget.repository.createProjectTransferRequest(
                        selectedProjectId,
                        actorId: widget.currentUser.id,
                        assetId: asset.id,
                        needByLabel: needBy,
                        note: note,
                      ),
                    );
                    _transferNeedByController.clear();
                    _transferNoteController.clear();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Request Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _updateTitleController.dispose();
    _updateBodyController.dispose();
    _taskTitleController.dispose();
    _taskCheckpointController.dispose();
    _acquisitionTitleController.dispose();
    _acquisitionDeadlineController.dispose();
    _acquisitionGoalController.dispose();
    _acquisitionRaisedController.dispose();
    _acquisitionItemLabelController.dispose();
    _acquisitionItemCostController.dispose();
    _transferNeedByController.dispose();
    _transferNoteController.dispose();
    _planTitleController.dispose();
    _planSummaryController.dispose();
    _planBodyController.dispose();
    _planEstimatedController.dispose();
    _planChecklistController.dispose();
    _planNeedLabelController.dispose();
    _planNeedQuantityController.dispose();
    _planNeedNoteController.dispose();
    _planNeedCostController.dispose();
    _planCostLabelController.dispose();
    _planCostAmountController.dispose();
    _planCostNoteController.dispose();
    _landServiceTitleController.dispose();
    _landServiceSummaryController.dispose();
    _softwareRepoTargetController.dispose();
    _softwareDiffSummaryController.dispose();
    _softwareNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project =
        widget.repository.projectById(widget.project.id) ?? widget.project;
    final isAssetProject = _isAssetModeProject(project);
    final productionPlans = widget.repository.plansForProject(
      project.id,
      MockPlanKind.production,
    );
    final distributionPlans = widget.repository.plansForProject(
      project.id,
      MockPlanKind.distribution,
    );
    final approvedProduction =
        isAssetProject || productionPlans.any((item) => item.approved);
    _syncPlanDraft(project);

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: project.title,
      subtitle: isAssetProject
          ? 'Asset project detail keeps stock, access rules, steward requests, and linked work on one surface.'
          : 'Project detail keeps plans, updates, acquisition, linked work, and discussion on one surface.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      showHeaderText: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final tab in _projectTabsFor(
                  project,
                  currentUserId: widget.currentUser.id,
                  repository: widget.repository,
                ))
                  _PageTabChip(
                    label: _projectTabLabel(tab),
                    selected: selectedTab == tab,
                    onSelected: () => setState(() => selectedTab = tab),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          switch (selectedTab) {
            MockProjectTab.overview => _buildOverview(
              project,
              productionPlans,
              distributionPlans,
            ),
            MockProjectTab.inventory => _buildInventory(project),
            MockProjectTab.discussion => _buildDiscussion(project),
            MockProjectTab.updates => _buildUpdates(project),
            MockProjectTab.tasks => _buildTasks(project),
            MockProjectTab.plans => _buildPlans(
              project,
              productionPlans,
              distributionPlans,
              approvedProduction,
            ),
            MockProjectTab.fund => _buildFund(
              project,
              productionPlans,
              distributionPlans,
            ),
            MockProjectTab.events => _buildEvents(project),
            MockProjectTab.history => _buildHistory(project),
            MockProjectTab.managers => _buildManagers(project),
            MockProjectTab.requests => _buildRequests(project),
          },
        ],
      ),
    );
  }

  Widget _buildOverview(
    MockProject project,
    List<MockPlan> productionPlans,
    List<MockPlan> distributionPlans,
  ) {
    final isDarkMode = _isDarkTheme(context);
    final stageStyle = stageStyleForMode(project.stage, isDarkMode: isDarkMode);
    final feedChipStyle = _feedPrimaryChipStyleForProject(project, context);
    final author = widget.repository.userById(project.authorId);
    final isAssetProject = _isAssetModeProject(project);
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final demandCount =
        project.demandCount +
        ((widget.demandSignals[project.id] ?? false) ? 1 : 0);
    final linkedProjects = widget.repository.linkedProjectsForProject(project);
    final storageBuildings = widget.repository.storageBuildingsForProject(
      project.id,
    );
    final assetRequests = widget.repository.transferRequestsForProject(
      project.id,
    );
    final approvedProduction = productionPlans.any((item) => item.approved);
    final approvedDistribution = distributionPlans.any((item) => item.approved);
    final overviewRows = <(String, String)>[
      ('Location', project.locationLabel),
      ('Members', '${project.memberIds.length}'),
      if (isAssetProject) ...[
        (
          'Listed stock',
          project.inventoryItems.isEmpty
              ? 'No stock listed yet'
              : '${project.inventoryItems.length} items listed',
        ),
        (
          'Access plan',
          approvedDistribution ? 'Approved' : 'Needs approved circulation plan',
        ),
        (
          'Transfers',
          isManager
              ? '${assetRequests.length} visible · manager actions enabled'
              : '${assetRequests.length} visible · manager actions required',
        ),
        if (storageBuildings.isNotEmpty)
          ('Buildings', '${storageBuildings.length} linked buildings'),
      ] else if (project.type == MockProjectType.service) ...[
        (
          'Operating plan',
          approvedProduction
              ? 'Approved'
              : productionPlans.isEmpty
              ? 'Not set'
              : 'Voting open',
        ),
        (
          'Handoffs',
          approvedDistribution
              ? 'Approved'
              : distributionPlans.isEmpty
              ? 'Not set'
              : 'Voting open',
        ),
      ] else ...[
        (
          'Production',
          approvedProduction
              ? 'Approved'
              : productionPlans.isEmpty
              ? 'Not set'
              : 'Voting open',
        ),
        (
          'Distribution',
          approvedDistribution
              ? 'Approved'
              : distributionPlans.isEmpty
              ? 'Not set'
              : 'Voting open',
        ),
      ],
      ('Author', _userHandle(author)),
      ('Posted', _relativeTime(project.createdAt)),
      ('Updated', _relativeTime(project.lastActivity)),
      (
        'Next event',
        project.events.isEmpty
            ? 'No event scheduled'
            : '${project.events.first.title} · ${project.events.first.timeLabel}',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          label: feedChipStyle.label,
                          background: feedChipStyle.background,
                          foreground: feedChipStyle.foreground,
                          border: Colors.transparent,
                        ),
                        _InfoChip(
                          label: stageStyle.label,
                          background: stageStyle.soft,
                          foreground: stageStyle.accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TagWrap(
                      items: _tagItemsForProject(widget.repository, project),
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                project.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                project.summary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(project.body),
              const SizedBox(height: 16),
              _MetaTable(rows: overviewRows),
              if (isManager) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager Controls',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All current managers can directly move the mock project between lifecycle stages. Every change is written to the public History tab.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Stage',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(width: 12),
                          _EnumDropdown<MockProjectStage>(
                            value: project.stage,
                            values: MockProjectStage.values,
                            labelBuilder: (value) => stageStyleForMode(
                              value,
                              isDarkMode: _isDarkTheme(context),
                            ).label,
                            onChanged: (value) => _refresh(
                              () => widget.repository.changeProjectStage(
                                project.id,
                                value,
                                widget.currentUser.id,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(
                              () => selectedTab = MockProjectTab.history,
                            ),
                            child: const Text('Open History'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _VoteStrip(
                    id: project.id,
                    count:
                        project.awarenessCount +
                        (widget.votes[project.id] ?? 0),
                    activeVote: widget.votes[project.id] ?? 0,
                    onVote: (id, value) =>
                        _refresh(() => widget.onVote(id, value)),
                  ),
                  _CountPill(
                    icon: Icons.mode_comment_outlined,
                    label: '${project.comments}',
                    onTap: () =>
                        setState(() => selectedTab = MockProjectTab.discussion),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (project.fund != null) ...[
                LinearProgressIndicator(
                  value: project.fund!.raised / project.fund!.goal,
                  minHeight: 10,
                  backgroundColor: _progressTrack(context),
                  color: _fundProgressColor(
                    context,
                    project.fund!.raised / project.fund!.goal,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_money(project.fund!.raised)} of ${_money(project.fund!.goal)} · ${project.fund!.deadlineLabel}',
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (isAssetProject) ...[
                    OutlinedButton(
                      onPressed: () => setState(
                        () => selectedTab = MockProjectTab.inventory,
                      ),
                      child: const Text('Browse Stock'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Request Personally'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(
                        () => selectedTab = MockProjectTab.inventory,
                      ),
                      child: const Text('Request For Project'),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => selectedTab = MockProjectTab.requests),
                      child: const Text('Open Transfers'),
                    ),
                  ] else ...[
                    FilledButton.tonal(
                      onPressed: () =>
                          _refresh(() => widget.onToggleDemand(project.id)),
                      child: Text(
                        _demandLabel(
                          demandCount,
                          widget.demandSignals[project.id] ?? false,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Join Project'),
                    ),
                    if (project.fund != null)
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => selectedTab = MockProjectTab.fund),
                        child: const Text('Contribute'),
                      ),
                    if (isManager)
                      TextButton(
                        onPressed: () => setState(
                          () => selectedTab = MockProjectTab.history,
                        ),
                        child: const Text('Open History'),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (isAssetProject && storageBuildings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buildings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Buildings sit between the land asset and the stored asset records whenever a more precise physical location exists.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                for (final building in storageBuildings) ...[
                  _MiniRow(
                    title: building.name,
                    body:
                        '${building.kindLabel} · ${widget.repository.foundationAssetsForBuilding(building.id).length} asset records · ${building.summary}',
                    onTap: () => _openInventoryBuilding(building.id),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
        if (project.type == MockProjectType.service) ...[
          const SizedBox(height: 16),
          _SectionCard(
            child: _MetaTable(
              title: 'Service Availability',
              rows: [
                ('Mode', project.serviceMode ?? 'Not set'),
                ('Cadence', project.serviceCadence ?? 'Not set'),
                ('Availability', project.availability ?? 'Not set'),
                ('Requests', '$demandCount'),
              ],
            ),
          ),
        ],
        if (linkedProjects.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Linked Projects',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in linkedProjects)
                      _LinkedTile(
                        title: item.title,
                        body: item.summary,
                        onTap: () => widget.onOpenProject(item),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInventory(MockProject project) {
    final inventoryItems = _orderedInventoryItems(project.inventoryItems);
    final storageBuildings = widget.repository.storageBuildingsForProject(
      project.id,
    );
    final managedAssets = widget.repository.foundationAssetsForProject(
      project.id,
    );
    final managedTransferTargets = _managedTransferTargetsFor(project);
    final inventoryLockedMessage = switch (project.stage) {
      MockProjectStage.proposal
          when project.type == MockProjectType.production =>
        'Inventory stays empty during Demand Signalling. This project is still gathering demand and has not committed shared stock yet.',
      MockProjectStage.planning
          when project.type == MockProjectType.production =>
        'Inventory stays empty during planning until the project commits actual operating stock rather than proposed needs.',
      MockProjectStage.funding
          when project.type == MockProjectType.production &&
              !_productionInventoryAvailable(project, widget.repository) =>
        'Inventory stays locked until approved production and distribution plans exist and acquisition has turned planned inputs into committed stock.',
      _ => null,
    };
    final itemsByBuilding = {
      for (final building in storageBuildings)
        building.id: inventoryItems
            .where((item) => item.buildingId == building.id)
            .toList(),
    };
    final sharedItems = inventoryItems
        .where((item) => item.buildingId == null)
        .toList();
    final pendingBuildingId = _pendingInventoryBuildingId;

    if (pendingBuildingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final targetContext =
            _inventoryBuildingKeys[pendingBuildingId]?.currentContext;
        if (targetContext != null) {
          Scrollable.ensureVisible(
            targetContext,
            alignment: 0.08,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
        if (mounted && _pendingInventoryBuildingId == pendingBuildingId) {
          setState(() => _pendingInventoryBuildingId = null);
        }
      });
    }

    Widget buildAssetRow(MockAssetStockItem item) {
      final asset = widget.repository.assetForInventoryItem(project, item);
      final canRequestAsProject =
          (item.requestability == MockAssetRequestability.both ||
              item.requestability == MockAssetRequestability.projectOnly) &&
          managedTransferTargets.isNotEmpty;

      return _AssetStockRow(
        item: item,
        asset: asset,
        onOpenAsset: () => widget.onOpenAsset(asset),
        onRequestAsProject: canRequestAsProject
            ? () => _openProjectTransferRequestDialog(
                sourceProject: project,
                asset: asset,
              )
            : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Owned And In Stock',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                project.assetRequestPolicy ??
                    (storageBuildings.isNotEmpty
                        ? 'Inventory is grouped by building so the most precise physical location stays visible. Shared site rows stay separate when they apply across the whole property.'
                        : 'Inventory is listed item by item. Every row opens its underlying asset detail, and project transfer requests start directly from the relevant inventory row.'),
              ),
              if (storageBuildings.isEmpty &&
                  inventoryItems.any((item) => item.isSiteAsset)) ...[
                const SizedBox(height: 12),
                Text(
                  'The land or site row stays at the top when a project has a fixed collective base.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (inventoryLockedMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  inventoryLockedMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ] else if (inventoryItems.isEmpty &&
                  managedAssets.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'This project currently stewards asset or land records without listing lendable stock rows directly in inventory.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (inventoryLockedMessage != null)
          _SectionCard(child: Text(inventoryLockedMessage))
        else if (inventoryItems.isEmpty && managedAssets.isNotEmpty)
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stewarded Asset Records',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This service currently manages approval routing or land stewardship rather than itemized lendable stock.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                for (final asset in managedAssets) ...[
                  _MiniRow(
                    title: asset.name,
                    body:
                        '${asset.groupLabel} · ${asset.availabilityLabel} · ${asset.locationLabel}',
                    onTap: () => widget.onOpenAsset(asset),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          )
        else if (inventoryItems.isEmpty)
          const _SectionCard(
            child: Text('No owned stock or site assets are listed yet.'),
          )
        else
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In Stock',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (storageBuildings.isEmpty)
                  for (final item in inventoryItems) ...[
                    buildAssetRow(item),
                    const SizedBox(height: 8),
                  ]
                else ...[
                  for (final building in storageBuildings) ...[
                    Builder(
                      builder: (context) {
                        final buildingItems =
                            itemsByBuilding[building.id] ?? const [];
                        final isHighlighted =
                            _highlightedInventoryBuildingId == building.id;

                        return Container(
                          key: _inventoryBuildingKey(building.id),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                (isHighlighted
                                        ? _appSurfaceStrong(context)
                                        : _appSurfaceSoft(context))
                                    .withValues(
                                      alpha: _isDarkTheme(context)
                                          ? (isHighlighted ? 0.74 : 0.38)
                                          : (isHighlighted ? 0.42 : 0.22),
                                    ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isHighlighted
                                  ? _paneDivider(context)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                building.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${building.kindLabel} · ${building.summary}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              if (buildingItems.isEmpty)
                                const Text(
                                  'No asset rows are linked to this building yet.',
                                )
                              else
                                for (final item in buildingItems) ...[
                                  buildAssetRow(item),
                                  const SizedBox(height: 8),
                                ],
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (sharedItems.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _appSurfaceSoft(context).withValues(
                          alpha: _isDarkTheme(context) ? 0.28 : 0.16,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shared Across Site',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'These rows apply across the whole site instead of one named building.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          for (final item in sharedItems) ...[
                            buildAssetRow(item),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRequests(MockProject project) {
    if (project.governanceKind == MockGovernanceProjectKind.software) {
      return _buildSoftwareChangeRequests(project);
    }

    if (project.governanceKind == MockGovernanceProjectKind.collectiveFunds) {
      return const _SectionCard(
        child: Text(
          'This project uses public updates and history entries instead of a separate request queue. Collective-fund execution stays visible here, but the mock does not simulate invoice approval as a second workflow.',
        ),
      );
    }

    final landRequests = widget.repository.landManagementRequestsForProject(
      project.id,
    );
    final transferRequests = widget.repository.transferRequestsForProject(
      project.id,
    );
    final showLandManagement =
        project.serviceKind == MockServiceKind.landManagement ||
        landRequests.isNotEmpty;

    if (!showLandManagement) {
      return _buildTransferRequests(project, requests: transferRequests);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLandManagementRequests(project, landRequests),
        if (transferRequests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTransferRequests(project, requests: transferRequests),
        ],
      ],
    );
  }

  Widget _buildTransferRequests(
    MockProject project, {
    required List<MockFoundationRequest> requests,
  }) {
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final requestedCount = requests
        .where(
          (item) =>
              _transferVisualToneForRequest(
                repository: widget.repository,
                currentProject: project,
                request: item,
              ) ==
              _TransferVisualTone.requested,
        )
        .length;
    final incomingCount = requests
        .where(
          (item) =>
              _transferVisualToneForRequest(
                repository: widget.repository,
                currentProject: project,
                request: item,
              ) ==
              _TransferVisualTone.incoming,
        )
        .length;
    final outgoingCount = requests
        .where(
          (item) =>
              _transferVisualToneForRequest(
                repository: widget.repository,
                currentProject: project,
                request: item,
              ) ==
              _TransferVisualTone.outgoing,
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: '$requestedCount requested',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                  _InfoChip(
                    label: '$incomingCount incoming',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                  _InfoChip(
                    label: '$outgoingCount outgoing',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isManager
                    ? 'Transfers are visible to everyone. Managers of ${project.title} can dispatch outgoing handoffs, confirm receipts, and open requests from other projects\' inventory rows.'
                    : 'Transfers are visible to everyone. Only current managers can request, dispatch, or confirm handoffs.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          _SectionCard(
            child: Text(
              isManager
                  ? 'No transfer requests or handoffs are active right now. Open another project\'s inventory to request an asset as one of your managed projects.'
                  : 'No transfer requests or handoffs are active right now.',
            ),
          )
        else
          for (final request in requests) ...[
            _FoundationRequestCard(
              repository: widget.repository,
              request: request,
              currentProject: project,
              onOpenProject: widget.onOpenProject,
              onOpenAsset: widget.onOpenAsset,
              onOpenProfile: widget.onOpenProfile,
              onConfirmDispatch: () => _refresh(
                () => widget.repository.confirmTransferDispatch(
                  request.id,
                  widget.currentUser.id,
                ),
              ),
              onConfirmReceipt: () => _refresh(
                () => widget.repository.confirmTransferReceipt(
                  request.id,
                  widget.currentUser.id,
                ),
              ),
              managerActions: isManager,
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildLandManagementRequests(
    MockProject project,
    List<MockLandManagementRequest> requests,
  ) {
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final incomingCount = requests
        .where((item) => item.targetProjectId == project.id)
        .length;
    final outgoingCount = requests
        .where((item) => item.requestingProjectId == project.id)
        .length;
    final pendingCount = requests
        .where((item) => item.status == MockLandManagementRequestStatus.pending)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: '$incomingCount incoming',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                  _InfoChip(
                    label: '$outgoingCount outgoing',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                  _InfoChip(
                    label: '$pendingCount pending',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                project.serviceKind == MockServiceKind.landManagement
                    ? 'Land-management requests stay separate from transfer requests. Managers of ${project.title} can accept or refuse management when another project wants this service to handle land purchase execution or an attached land asset.'
                    : 'This project has land-management routing attached to one or more approved plans. The request stays open until a land-management service accepts or refuses it.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          _SectionCard(
            child: Text(
              project.serviceKind == MockServiceKind.landManagement
                  ? 'No land-management requests are active for this service right now.'
                  : 'No land-management requests are attached to this project right now.',
            ),
          )
        else
          for (final request in requests) ...[
            _LandManagementRequestCard(
              repository: widget.repository,
              request: request,
              currentProject: project,
              onOpenProject: widget.onOpenProject,
              onOpenPlan: widget.onOpenPlan,
              onOpenAsset: widget.onOpenAsset,
              onOpenProfile: widget.onOpenProfile,
              onAccept: () => _refresh(
                () => widget.repository.respondToLandManagementRequest(
                  request.id,
                  actorId: widget.currentUser.id,
                  accept: true,
                ),
              ),
              onRefuse: () => _refresh(
                () => widget.repository.respondToLandManagementRequest(
                  request.id,
                  actorId: widget.currentUser.id,
                  accept: false,
                ),
              ),
              managerActions: isManager,
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildSoftwareChangeRequests(MockProject project) {
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final requests = widget.repository.softwareChangeRequestsForProject(
      project.id,
    );
    final proposedCount = requests
        .where(
          (item) => item.status == MockSoftwareChangeRequestStatus.proposed,
        )
        .length;
    final reviewCount = requests
        .where(
          (item) => item.status == MockSoftwareChangeRequestStatus.underReview,
        )
        .length;
    final mergedCount = requests
        .where((item) => item.status == MockSoftwareChangeRequestStatus.merged)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: '$proposedCount proposed',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                  _InfoChip(
                    label: '$reviewCount under review',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                  _InfoChip(
                    label: '$mergedCount merged',
                    background: MockPalette.panelSoft,
                    foreground: MockPalette.text,
                    border: MockPalette.border,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Anyone can propose a software change here. Only the current board managers can move a request into review, request changes, merge it, or reject it.',
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
                'Submit Change Request',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _softwareRepoTargetController,
                decoration: const InputDecoration(labelText: 'Repo target'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _softwareDiffSummaryController,
                decoration: const InputDecoration(
                  labelText: 'Short diff summary',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _softwareNoteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Why this change matters',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    final repoTarget = _softwareRepoTargetController.text
                        .trim();
                    final diffSummary = _softwareDiffSummaryController.text
                        .trim();
                    final note = _softwareNoteController.text.trim();
                    if (repoTarget.isEmpty || diffSummary.isEmpty) {
                      return;
                    }
                    _refresh(() {
                      widget.repository.submitSoftwareChangeRequest(
                        project.id,
                        requesterId: widget.currentUser.id,
                        repoTarget: repoTarget,
                        diffSummary: diffSummary,
                        note: note.isEmpty ? null : note,
                      );
                      _softwareRepoTargetController.clear();
                      _softwareDiffSummaryController.clear();
                      _softwareNoteController.clear();
                    });
                  },
                  child: const Text('Submit Change Request'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isEmpty)
          const _SectionCard(
            child: Text('No software change requests are open right now.'),
          )
        else
          for (final request in requests) ...[
            _SoftwareChangeRequestCard(
              repository: widget.repository,
              request: request,
              managerActions: isManager,
              onOpenProfile: widget.onOpenProfile,
              onMoveToReview: () => _refresh(
                () => widget.repository.updateSoftwareChangeRequestStatus(
                  request.id,
                  actorId: widget.currentUser.id,
                  status: MockSoftwareChangeRequestStatus.underReview,
                ),
              ),
              onRequestChanges: () => _refresh(
                () => widget.repository.updateSoftwareChangeRequestStatus(
                  request.id,
                  actorId: widget.currentUser.id,
                  status: MockSoftwareChangeRequestStatus.changesRequested,
                ),
              ),
              onMerge: () => _refresh(
                () => widget.repository.updateSoftwareChangeRequestStatus(
                  request.id,
                  actorId: widget.currentUser.id,
                  status: MockSoftwareChangeRequestStatus.merged,
                ),
              ),
              onReject: () => _refresh(
                () => widget.repository.updateSoftwareChangeRequestStatus(
                  request.id,
                  actorId: widget.currentUser.id,
                  status: MockSoftwareChangeRequestStatus.rejected,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildDiscussion(MockProject project) {
    final comments = widget.repository.commentsForProject(project.id);
    final highlightedComment = _selectedCommentId == null
        ? null
        : widget.repository.projectCommentById(project.id, _selectedCommentId!);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Discussion',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _MentionComposerField(
            repository: widget.repository,
            hintText: 'Comment on ${project.title}...',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                highlightedComment == null
                    ? 'Nested Reddit-style comments only in this mock.'
                    : 'Opened directly to the comment currently shown in Personal.',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Add Comment'),
              ),
            ],
          ),
          if (highlightedComment != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _appSurfaceSoft(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _paneDivider(context)),
              ),
              child: Text(
                'Highlighted comment: ${highlightedComment.body}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (comments.isEmpty)
            const Text('No project comments yet.')
          else
            for (final comment in comments) ...[
              _CommentNode(
                repository: widget.repository,
                comment: comment,
                currentUserId: widget.currentUser.id,
                highlightedCommentId: _selectedCommentId,
                isSharedToPersonal: (item) =>
                    widget.repository.hasPersonalCommentShare(
                      authorId: widget.currentUser.id,
                      sourceKind: MockCommentShareSourceKind.project,
                      sourceId: project.id,
                      commentId: item.id,
                    ),
                onShareToPersonal: (item) => _refresh(
                  () => widget.repository.shareProjectCommentToPersonal(
                    authorId: widget.currentUser.id,
                    projectId: project.id,
                    commentId: item.id,
                  ),
                ),
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _buildUpdates(MockProject project) {
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final selectedUpdate = _selectedUpdateId == null
        ? null
        : project.updates
              .where((item) => item.id == _selectedUpdateId)
              .cast<MockUpdate?>()
              .firstWhere((item) => item != null, orElse: () => null);

    if (selectedUpdate != null) {
      final comments = widget.repository.commentsForUpdate(selectedUpdate.id);
      final author = widget.repository.userById(selectedUpdate.authorId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextButton(
                      onPressed: _closeUpdateDetail,
                      child: const Text('All Updates'),
                    ),
                    const Spacer(),
                    Text(
                      _relativeTime(selectedUpdate.time),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  selectedUpdate.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(selectedUpdate.body),
                const SizedBox(height: 12),
                Text(
                  _userHandle(author),
                  style: Theme.of(context).textTheme.labelSmall,
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
                  'Update Discussion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _MentionComposerField(
                  repository: widget.repository,
                  hintText: 'Reply to this update...',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Update comments stay inside the project context in this mock.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add Comment'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (comments.isEmpty)
                  const Text('No update comments yet.')
                else
                  for (final comment in comments) ...[
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
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isManager) ...[
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manager Update Post',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Current project managers can publish updates directly from this surface. Each post is also written into the public History tab.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _updateTitleController,
                  decoration: const InputDecoration(hintText: 'Update title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _updateBodyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'What changed, what is blocked, and what needs attention?',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = _updateTitleController.text.trim();
                      final body = _updateBodyController.text.trim();
                      if (title.isEmpty || body.isEmpty) {
                        return;
                      }
                      _refresh(
                        () => widget.repository.postProjectUpdate(
                          project.id,
                          actorId: widget.currentUser.id,
                          title: title,
                          body: body,
                        ),
                      );
                      _updateTitleController.clear();
                      _updateBodyController.clear();
                    },
                    child: const Text('Post Update'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Updates', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Updates can be opened as project-internal discussion threads without leaving the project surface.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              if (project.updates.isEmpty)
                const Text('No project updates yet.')
              else
                for (final update in project.updates) ...[
                  _SearchRow(
                    title: update.title,
                    body: update.body,
                    meta:
                        '${_userHandle(widget.repository.userById(update.authorId))} · ${_relativeTime(update.time)} · ${widget.repository.commentsForUpdate(update.id).length} comments',
                    onTap: () => _openUpdate(update.id),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlans(
    MockProject project,
    List<MockPlan> productionPlans,
    List<MockPlan> distributionPlans,
    bool approvedProduction,
  ) {
    final isAssetProject = _isAssetModeProject(project);
    final isServiceProject = project.type == MockProjectType.service;
    final isMember = widget.repository.isProjectMember(
      project,
      widget.currentUser.id,
    );
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMember) ...[
          _buildPlanComposer(
            project: project,
            isAssetProject: isAssetProject,
            isServiceProject: isServiceProject,
            distributionUnlocked: approvedProduction,
          ),
          const SizedBox(height: 16),
        ],
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plans', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                isAssetProject
                    ? 'Asset-mode projects use circulation plans to define borrowing, return, steward handling, and plan-linked transfer requests.'
                    : isServiceProject
                    ? 'Service projects keep operating and handoff plans on one surface. Handoff submissions stay locked until an operating plan has been approved.'
                    : 'Production and distribution plans live on one surface. Distribution submissions stay locked until a production plan has been approved, tied assets can generate transfer requests after approval, and land-related plans now carry an explicit land-management route.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              if (isAssetProject)
                _buildPlansGroup(
                  title: 'Circulation',
                  plans: distributionPlans,
                  emptyText:
                      'No circulation plan is attached to ${project.title} yet.',
                  isManager: isManager,
                )
              else if (isServiceProject) ...[
                _buildPlansGroup(
                  title: 'Operating',
                  plans: productionPlans,
                  emptyText:
                      'No operating plans are attached to ${project.title} yet.',
                  isManager: isManager,
                ),
                const SizedBox(height: 16),
                _buildPlansGroup(
                  title: 'Handoffs',
                  plans: distributionPlans,
                  emptyText: approvedProduction
                      ? 'No handoff plans are attached to ${project.title} yet.'
                      : 'Handoff plan submission is locked until an operating plan has been approved.',
                  locked: !approvedProduction,
                  isManager: isManager,
                ),
              ] else ...[
                _buildPlansGroup(
                  title: 'Production',
                  plans: productionPlans,
                  emptyText:
                      'No production plans are attached to ${project.title} yet.',
                  isManager: isManager,
                ),
                const SizedBox(height: 16),
                _buildPlansGroup(
                  title: 'Distribution',
                  plans: distributionPlans,
                  emptyText: approvedProduction
                      ? 'No distribution plans are attached to ${project.title} yet.'
                      : 'Distribution plan submission is locked until a production plan has been approved.',
                  locked: !approvedProduction,
                  isManager: isManager,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanComposer({
    required MockProject project,
    required bool isAssetProject,
    required bool isServiceProject,
    required bool distributionUnlocked,
  }) {
    final selectableAssets =
        widget.repository.foundationAssets
            .where((item) => item.groupLabel != 'Land')
            .toList()
          ..sort((left, right) => left.name.compareTo(right.name));
    final landAssets =
        widget.repository.foundationAssets
            .where((item) => item.groupLabel == 'Land')
            .toList()
          ..sort((left, right) => left.name.compareTo(right.name));
    final landManagementProjects = widget.repository.landManagementProjects()
      ..sort((left, right) => left.title.compareTo(right.title));
    final effectiveKind = isAssetProject
        ? MockPlanKind.distribution
        : _draftPlanKind;
    final distributionLabel = isAssetProject
        ? 'Circulation'
        : isServiceProject
        ? 'Handoff'
        : 'Distribution';
    final productionLabel = isServiceProject ? 'Operating' : 'Production';

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Detailed Plan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isAssetProject
                ? 'Use this form to submit a circulation plan with asset needs, timing, and itemized costs.'
                : 'Use this form to submit a detailed plan with tied assets or equipment, itemized costs, an execution date, and optional land-management routing.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isAssetProject)
                ChoiceChip(
                  label: Text(productionLabel),
                  selected: effectiveKind == MockPlanKind.production,
                  onSelected: (_) =>
                      setState(() => _draftPlanKind = MockPlanKind.production),
                ),
              ChoiceChip(
                label: Text(distributionLabel),
                selected: effectiveKind == MockPlanKind.distribution,
                onSelected: distributionUnlocked || isAssetProject
                    ? (_) => setState(
                        () => _draftPlanKind = MockPlanKind.distribution,
                      )
                    : null,
              ),
              if (!distributionUnlocked && !isAssetProject)
                Text(
                  'Distribution unlocks after one approved ${productionLabel.toLowerCase()} plan.',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _planTitleController,
            decoration: const InputDecoration(labelText: 'Plan title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _planSummaryController,
            decoration: const InputDecoration(labelText: 'Short summary'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _planBodyController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Detailed plan body'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _planEstimatedController,
                  decoration: const InputDecoration(
                    labelText: 'Estimated execution date or window',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _planChecklistController,
                  decoration: const InputDecoration(
                    labelText: 'Checklist items, separated by commas',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Assets And Equipment',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _planNeedLabelController,
                  decoration: const InputDecoration(labelText: 'Item or asset'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _planNeedQuantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _draftNeedAssetId.isEmpty
                      ? ''
                      : _draftNeedAssetId,
                  decoration: const InputDecoration(
                    labelText: 'Tie an in-network asset',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('No tied asset'),
                    ),
                    for (final asset in selectableAssets)
                      DropdownMenuItem<String>(
                        value: asset.id,
                        child: Text(asset.name),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _draftNeedAssetId = value ?? ''),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _planNeedCostController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fallback cost estimate',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _planNeedNoteController,
            decoration: const InputDecoration(labelText: 'Need note'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                final label = _planNeedLabelController.text.trim();
                final quantity = _planNeedQuantityController.text.trim();
                final note = _planNeedNoteController.text.trim();
                final estimatedCost = int.tryParse(
                  _planNeedCostController.text.replaceAll(',', '').trim(),
                );
                if (label.isEmpty || quantity.isEmpty) {
                  return;
                }
                setState(() {
                  _draftPlanAssetNeeds.add(
                    MockPlanAssetNeed(
                      label: label,
                      quantityLabel: quantity,
                      linkedAssetId: _draftNeedAssetId.isEmpty
                          ? null
                          : _draftNeedAssetId,
                      note: note.isEmpty ? null : note,
                      estimatedCost: estimatedCost,
                    ),
                  );
                  _planNeedLabelController.clear();
                  _planNeedQuantityController.clear();
                  _planNeedNoteController.clear();
                  _planNeedCostController.clear();
                  _draftNeedAssetId = '';
                });
              },
              child: const Text('Add Asset Need'),
            ),
          ),
          if (_draftPlanAssetNeeds.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (
              var index = 0;
              index < _draftPlanAssetNeeds.length;
              index++
            ) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _appSurfaceSoft(
                    context,
                  ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_draftPlanAssetNeeds[index].label} · ${_draftPlanAssetNeeds[index].quantityLabel}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _draftPlanAssetNeeds[index].linkedAssetId == null
                                ? (_draftPlanAssetNeeds[index].estimatedCost ==
                                          null
                                      ? 'No tied in-network asset'
                                      : 'Fallback cost ${_money(_draftPlanAssetNeeds[index].estimatedCost!)}')
                                : 'Tied asset: ${widget.repository.foundationAssetById(_draftPlanAssetNeeds[index].linkedAssetId!)?.name ?? 'Unknown asset'}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (_draftPlanAssetNeeds[index].note != null) ...[
                            const SizedBox(height: 4),
                            Text(_draftPlanAssetNeeds[index].note!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () =>
                          setState(() => _draftPlanAssetNeeds.removeAt(index)),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 16),
          Text(
            'Land Management Routing',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'If this plan buys land or attaches an existing land asset, choose the land-management service path here. Existing services must accept the request before the route is fully settled. New services appear only after the plan is approved.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('No land routing'),
                selected: _draftLandAction == null,
                onSelected: (_) => setState(() => _draftLandAction = null),
              ),
              ChoiceChip(
                label: const Text('Buy land through this plan'),
                selected: _draftLandAction == MockLandPlanAction.purchase,
                onSelected: (_) => setState(
                  () => _draftLandAction = MockLandPlanAction.purchase,
                ),
              ),
              ChoiceChip(
                label: const Text('Attach an existing land asset'),
                selected: _draftLandAction == MockLandPlanAction.attachExisting,
                onSelected: (_) => setState(
                  () => _draftLandAction = MockLandPlanAction.attachExisting,
                ),
              ),
            ],
          ),
          if (_draftLandAction != null) ...[
            const SizedBox(height: 12),
            if (_draftLandAction == MockLandPlanAction.attachExisting) ...[
              DropdownButtonFormField<String>(
                initialValue: _draftLandAssetId.isEmpty
                    ? ''
                    : _draftLandAssetId,
                decoration: const InputDecoration(
                  labelText: 'Existing land asset',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Choose a land asset'),
                  ),
                  for (final asset in landAssets)
                    DropdownMenuItem<String>(
                      value: asset.id,
                      child: Text(asset.name),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _draftLandAssetId = value ?? ''),
              ),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Request existing service'),
                  selected:
                      _draftLandManagementSelection ==
                      MockLandManagementSelection.existingService,
                  onSelected: (_) => setState(
                    () => _draftLandManagementSelection =
                        MockLandManagementSelection.existingService,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Create new service after approval'),
                  selected:
                      _draftLandManagementSelection ==
                      MockLandManagementSelection.createNewService,
                  onSelected: (_) => setState(
                    () => _draftLandManagementSelection =
                        MockLandManagementSelection.createNewService,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_draftLandManagementSelection ==
                MockLandManagementSelection.existingService)
              DropdownButtonFormField<String>(
                initialValue: _draftExistingLandManagementProjectId.isEmpty
                    ? ''
                    : _draftExistingLandManagementProjectId,
                decoration: const InputDecoration(
                  labelText: 'Land-management service',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Choose a service'),
                  ),
                  for (final item in landManagementProjects)
                    DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.title),
                    ),
                ],
                onChanged: (value) => setState(
                  () => _draftExistingLandManagementProjectId = value ?? '',
                ),
              )
            else ...[
              TextField(
                controller: _landServiceTitleController,
                decoration: const InputDecoration(
                  labelText: 'New land-management service title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _landServiceSummaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'New land-management service summary',
                ),
              ),
            ],
          ],
          const SizedBox(height: 16),
          Text('Itemized Costs', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _planCostLabelController,
                  decoration: const InputDecoration(labelText: 'Cost line'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _planCostAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _planCostNoteController,
            decoration: const InputDecoration(labelText: 'Cost note'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                final label = _planCostLabelController.text.trim();
                final amount = int.tryParse(
                  _planCostAmountController.text.replaceAll(',', '').trim(),
                );
                final note = _planCostNoteController.text.trim();
                if (label.isEmpty || amount == null) {
                  return;
                }
                setState(() {
                  _draftPlanCostLines.add(
                    MockPlanCostLine(
                      label: label,
                      cost: amount,
                      note: note.isEmpty ? null : note,
                    ),
                  );
                  _planCostLabelController.clear();
                  _planCostAmountController.clear();
                  _planCostNoteController.clear();
                });
              },
              child: const Text('Add Cost Line'),
            ),
          ),
          if (_draftPlanCostLines.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (
              var index = 0;
              index < _draftPlanCostLines.length;
              index++
            ) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _appSurfaceSoft(
                    context,
                  ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_draftPlanCostLines[index].label} · ${_money(_draftPlanCostLines[index].cost)}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          if (_draftPlanCostLines[index].note != null) ...[
                            const SizedBox(height: 4),
                            Text(_draftPlanCostLines[index].note!),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () =>
                          setState(() => _draftPlanCostLines.removeAt(index)),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                TextButton(
                  onPressed: () => setState(
                    () => _resetPlanDraft(keepProjectSelection: true),
                  ),
                  child: const Text('Clear Draft'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _planTitleController.text.trim();
                    final summary = _planSummaryController.text.trim();
                    final body = _planBodyController.text.trim();
                    final estimated = _planEstimatedController.text.trim();
                    final checklist = _planChecklistController.text
                        .split(RegExp(r'[\n,]+'))
                        .map((item) => item.trim())
                        .where((item) => item.isNotEmpty)
                        .toList();
                    if (title.isEmpty ||
                        summary.isEmpty ||
                        body.isEmpty ||
                        estimated.isEmpty ||
                        _draftPlanAssetNeeds.isEmpty &&
                            _draftPlanCostLines.isEmpty) {
                      return;
                    }
                    final submitKind = isAssetProject
                        ? MockPlanKind.distribution
                        : effectiveKind;
                    if (submitKind == MockPlanKind.distribution &&
                        !distributionUnlocked &&
                        !isAssetProject) {
                      return;
                    }
                    MockPlanLandRouting? landRouting;
                    if (_draftLandAction != null) {
                      if (_draftLandAction ==
                              MockLandPlanAction.attachExisting &&
                          _draftLandAssetId.isEmpty) {
                        return;
                      }
                      if (_draftLandManagementSelection ==
                              MockLandManagementSelection.existingService &&
                          _draftExistingLandManagementProjectId.isEmpty) {
                        return;
                      }
                      if (_draftLandManagementSelection ==
                              MockLandManagementSelection.createNewService &&
                          _landServiceTitleController.text.trim().isEmpty) {
                        return;
                      }
                      landRouting = MockPlanLandRouting(
                        action: _draftLandAction!,
                        managementSelection: _draftLandManagementSelection,
                        landAssetId:
                            _draftLandAction ==
                                MockLandPlanAction.attachExisting
                            ? _draftLandAssetId
                            : null,
                        existingProjectId:
                            _draftLandManagementSelection ==
                                MockLandManagementSelection.existingService
                            ? _draftExistingLandManagementProjectId
                            : null,
                        newServiceTitle:
                            _draftLandManagementSelection ==
                                MockLandManagementSelection.createNewService
                            ? _landServiceTitleController.text.trim()
                            : null,
                        newServiceSummary:
                            _draftLandManagementSelection ==
                                MockLandManagementSelection.createNewService
                            ? _landServiceSummaryController.text.trim()
                            : null,
                        statusLabel: 'Waiting for project approval',
                      );
                    }
                    _refresh(() {
                      widget.repository.submitProjectPlan(
                        project.id,
                        actorId: widget.currentUser.id,
                        kind: submitKind,
                        title: title,
                        summary: summary,
                        body: body,
                        estimatedExecutionLabel: estimated,
                        checklist: checklist,
                        assetNeeds: [..._draftPlanAssetNeeds],
                        costLines: [..._draftPlanCostLines],
                        landRouting: landRouting,
                      );
                      _resetPlanDraft(keepProjectSelection: true);
                    });
                  },
                  child: const Text('Submit Plan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasks(MockProject project) {
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    const taskStatuses = ['Todo', 'In progress', 'Blocked', 'Done'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isManager) ...[
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manager Task Controls',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Managers can add tasks, seed checkpoints, and update statuses. Task actions are mirrored into the public History tab.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(hintText: 'Task title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _taskCheckpointController,
                  decoration: const InputDecoration(
                    hintText: 'Checkpoint labels, separated by commas',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = _taskTitleController.text.trim();
                      if (title.isEmpty) {
                        return;
                      }
                      final checkpoints = _taskCheckpointController.text
                          .split(',')
                          .map((item) => item.trim())
                          .where((item) => item.isNotEmpty)
                          .toList();
                      _refresh(
                        () => widget.repository.addProjectTask(
                          project.id,
                          actorId: widget.currentUser.id,
                          title: title,
                          checkpoints: checkpoints,
                        ),
                      );
                      _taskTitleController.clear();
                      _taskCheckpointController.clear();
                    },
                    child: const Text('Add Task'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Task progress stays visible to ordinary members even when only managers can edit it in this mock.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              if (project.tasks.isEmpty)
                const Text('No tasks are listed for this project yet.')
              else
                for (final task in project.tasks) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _appSurfaceSoft(
                        context,
                      ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  _InfoChip(
                                    label: task.status,
                                    background: MockPalette.panelSoft,
                                    foreground: MockPalette.text,
                                    border: MockPalette.border,
                                  ),
                                ],
                              ),
                            ),
                            if (isManager) ...[
                              const SizedBox(width: 12),
                              _EnumDropdown<String>(
                                value: taskStatuses.contains(task.status)
                                    ? task.status
                                    : taskStatuses.first,
                                values: taskStatuses,
                                labelBuilder: (value) => value,
                                onChanged: (value) => _refresh(
                                  () =>
                                      widget.repository.updateProjectTaskStatus(
                                        project.id,
                                        task.id,
                                        value,
                                        widget.currentUser.id,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (task.checkpoints.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          for (
                            var index = 0;
                            index < task.checkpoints.length;
                            index++
                          ) ...[
                            Row(
                              children: [
                                Checkbox(
                                  value: task.checkpoints[index].done,
                                  onChanged: isManager
                                      ? (_) => _refresh(
                                          () => widget.repository
                                              .toggleProjectTaskCheckpoint(
                                                project.id,
                                                task.id,
                                                index,
                                                widget.currentUser.id,
                                              ),
                                        )
                                      : null,
                                ),
                                Expanded(
                                  child: Text(task.checkpoints[index].label),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistory(MockProject project) {
    final entries = widget.repository.projectHistoryForProject(project.id);

    String actorLabelFor(MockProjectHistoryEntry entry) {
      if (entry.actorLabel != null) {
        return entry.actorLabel!;
      }
      return _userHandle(
        entry.actorId == null
            ? null
            : widget.repository.userById(entry.actorId!),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('History', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Manager actions stay visible here for all users, including stage shifts, updates, task changes, and transfer handoffs.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Text('No manager actions are recorded for this project yet.')
          else
            for (final entry in entries) ...[
              _SearchRow(
                title: entry.title,
                body: entry.body,
                meta:
                    '${entry.categoryLabel} · ${actorLabelFor(entry)} · ${_relativeTime(entry.time)}',
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _buildPlansGroup({
    required String title,
    required List<MockPlan> plans,
    required String emptyText,
    required bool isManager,
    bool locked = false,
  }) {
    final approved = plans.where((item) => item.approved).toList();
    final voting = plans.where((item) => !item.approved).toList();
    final visible = [...approved, ...voting];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            if (locked) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _appSurfaceStrong(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Locked',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          Text(emptyText)
        else
          for (final plan in visible) ...[
            _PlanRow(plan: plan, onTap: () => widget.onOpenPlan(plan)),
            if (isManager && !plan.approved && !locked) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _refresh(
                    () => widget.repository.approveProjectPlan(
                      plan.id,
                      widget.currentUser.id,
                    ),
                  ),
                  child: const Text('Approve In Mock'),
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildFund(
    MockProject project,
    List<MockPlan> productionPlans,
    List<MockPlan> distributionPlans,
  ) {
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final fund = project.fund;
    if (fund == null) {
      return const _SectionCard(
        child: Text(
          'No active acquisition is attached to this project right now.',
        ),
      );
    }
    _syncAcquisitionControllers(project);

    final approvedProduction = productionPlans
        .where((item) => item.approved)
        .firstOrNull;
    final approvedDistribution = distributionPlans
        .where((item) => item.approved)
        .firstOrNull;

    return Column(
      children: [
        if (isManager) ...[
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manager Acquisition Controls',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Managers can adjust the acquisition brief and extend the purchase list here. Changes are mirrored into public project history.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _acquisitionTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Acquisition title',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _acquisitionDeadlineController,
                        decoration: const InputDecoration(
                          hintText: 'Deadline label',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _acquisitionGoalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Goal amount',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _acquisitionRaisedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Raised amount'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = _acquisitionTitleController.text.trim();
                      final deadline = _acquisitionDeadlineController.text
                          .trim();
                      final goal = int.tryParse(
                        _acquisitionGoalController.text
                            .replaceAll(',', '')
                            .trim(),
                      );
                      final raised = int.tryParse(
                        _acquisitionRaisedController.text
                            .replaceAll(',', '')
                            .trim(),
                      );
                      if (title.isEmpty ||
                          deadline.isEmpty ||
                          goal == null ||
                          raised == null) {
                        return;
                      }
                      _refresh(
                        () => widget.repository.updateProjectAcquisitionDetails(
                          project.id,
                          actorId: widget.currentUser.id,
                          title: title,
                          deadlineLabel: deadline,
                          goal: goal,
                          raised: raised,
                        ),
                      );
                    },
                    child: const Text('Update Acquisition'),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _acquisitionItemLabelController,
                  decoration: const InputDecoration(
                    hintText: 'New purchase item',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _acquisitionItemCostController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Cost'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final label = _acquisitionItemLabelController.text
                            .trim();
                        final cost = int.tryParse(
                          _acquisitionItemCostController.text
                              .replaceAll(',', '')
                              .trim(),
                        );
                        if (label.isEmpty || cost == null) {
                          return;
                        }
                        _refresh(
                          () => widget.repository.addProjectAcquisitionItem(
                            project.id,
                            actorId: widget.currentUser.id,
                            label: label,
                            cost: cost,
                          ),
                        );
                        _acquisitionItemLabelController.clear();
                        _acquisitionItemCostController.clear();
                      },
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acquisition',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(fund.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: fund.raised / fund.goal,
                minHeight: 10,
                backgroundColor: _progressTrack(context),
                color: _fundProgressColor(context, fund.raised / fund.goal),
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text(
                '${_money(fund.raised)} of ${_money(fund.goal)} · ${fund.deadlineLabel}',
              ),
              const SizedBox(height: 12),
              _MetaTable(
                rows: [
                  ('Contributors', '${fund.contributorCount}'),
                  (
                    'Production plan',
                    approvedProduction?.title ?? 'Not approved yet',
                  ),
                  (
                    'Distribution plan',
                    approvedDistribution?.title ?? 'Not approved yet',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Itemized Purchase List',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              for (final item in fund.purchaseItems) ...[
                Row(
                  children: [
                    Expanded(child: Text(item.label)),
                    Text(
                      _money(item.cost),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvents(MockProject project) {
    if (project.events.isEmpty) {
      return const _SectionCard(
        child: Text('No activity is scheduled for this project yet.'),
      );
    }

    return Column(
      children: [
        for (final event in project.events) ...[
          _SectionCard(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onOpenEvent(project, event),
                borderRadius: BorderRadius.circular(6),
                hoverColor: _rowHoverOverlay(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _appSurfaceSoft(
                      context,
                    ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text('${event.timeLabel} · ${event.location}'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () =>
                                _refresh(() => widget.onToggleRsvp(event.id)),
                            child: Text(
                              (widget.rsvpEvents[event.id] ?? false)
                                  ? 'Going'
                                  : 'RSVP',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            label:
                                '${event.going + ((widget.rsvpEvents[event.id] ?? false) ? 1 : 0)} going',
                            background: MockPalette.panelSoft,
                            foreground: MockPalette.text,
                            border: MockPalette.border,
                          ),
                          _InfoChip(
                            label: '${event.rolesNeeded.length} labor roles',
                            background: MockPalette.panelSoft,
                            foreground: MockPalette.text,
                            border: MockPalette.border,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildManagers(MockProject project) {
    final isStewardshipProject = widget.repository.isStewardshipTaggedProject(
      project,
    );
    final scopeId = isStewardshipProject
        ? 'channel:stewardship'
        : 'project:${project.id}';
    final isManager = widget.repository.isProjectManager(
      project,
      widget.currentUser.id,
    );
    final isMember = widget.repository.isProjectMember(
      project,
      widget.currentUser.id,
    );
    final seats = widget.repository.managerSeatsForProject(project).where((
      seat,
    ) {
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
            isStewardshipProject ? 'Board Managers' : 'Managers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isStewardshipProject
                ? 'Stewardship-tagged projects automatically mirror the current board seats from the Stewardship channel. Those same board seats keep merge authority and collective-fund execution authority while they maintain at least 70% approval from all platform users.'
                : 'Managers can publish updates, adjust acquisition details, manage tasks, move the project through stages, and keep the project surface operational while they maintain at least 70% approval.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (!isStewardshipProject && !isManager && isMember)
                ElevatedButton(
                  onPressed: () => _refresh(
                    () => widget.repository.optIntoProjectManagement(
                      project.id,
                      widget.currentUser.id,
                    ),
                  ),
                  child: const Text('Become Manager'),
                ),
              if (!isStewardshipProject && isManager)
                OutlinedButton(
                  onPressed: () => _refresh(
                    () => widget.repository.stepDownAsProjectManager(
                      project.id,
                      widget.currentUser.id,
                    ),
                  ),
                  child: const Text('Step Down'),
                ),
              TextButton(
                onPressed: () =>
                    setState(() => selectedTab = MockProjectTab.history),
                child: const Text('Open History'),
              ),
            ],
          ),
          if (!isStewardshipProject && !isMember) ...[
            const SizedBox(height: 8),
            Text(
              'Join the project before opting into manager responsibilities.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: 12),
          if (seats.isEmpty)
            Text(
              isStewardshipProject
                  ? 'No board seats currently meet the approval threshold.'
                  : 'No managers currently meet the approval threshold.',
            )
          else
            for (final seat in seats) ...[
              _GovernanceCard(
                user: widget.repository.userById(seat.userId)!,
                roleLabel: isStewardshipProject ? 'Board member' : 'Manager',
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

class _ThreadPage extends StatefulWidget {
  const _ThreadPage({
    required this.repository,
    required this.sharePublicCommentsInPersonal,
    required this.topNav,
    required this.leftRail,
    required this.thread,
    required this.votes,
    required this.onVote,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final bool sharePublicCommentsInPersonal;
  final Widget topNav;
  final Widget leftRail;
  final MockThread thread;
  final Map<String, int> votes;
  final void Function(String id, int value) onVote;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<_ThreadPage> {
  String? _selectedCommentId;

  @override
  void initState() {
    super.initState();
    _selectedCommentId = widget.repository.takePendingThreadCommentTarget(
      widget.thread.id,
    );
  }

  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    final author = widget.repository.userById(thread.authorId);
    final comments = widget.repository.commentsForThread(thread.id);
    final highlightedComment = _selectedCommentId == null
        ? null
        : widget.repository.threadCommentById(thread.id, _selectedCommentId!);
    final chipStyle = _feedThreadChipStyle(context);

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: thread.title,
      subtitle:
          'Thread detail keeps discussion first without folding nearby context back into project logistics.',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoChip(
                      label: 'Thread',
                      background: chipStyle.background,
                      foreground: chipStyle.foreground,
                      border: Colors.transparent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TagWrap(
                        items: _tagItemsForThread(widget.repository, thread),
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  thread.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(thread.body),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _VoteStrip(
                      id: thread.id,
                      count:
                          thread.awarenessCount +
                          (widget.votes[thread.id] ?? 0),
                      activeVote: widget.votes[thread.id] ?? 0,
                      onVote: (id, value) =>
                          _refresh(() => widget.onVote(id, value)),
                    ),
                    const SizedBox(width: 10),
                    _CountPill(
                      icon: Icons.mode_comment_outlined,
                      label: '${thread.replyCount}',
                    ),
                    const Spacer(),
                    Text(
                      '${_userHandle(author)} · ${_relativeTime(thread.lastActivity)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Discussion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _MentionComposerField(
                  repository: widget.repository,
                  hintText: 'Write a comment...',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Add Comment'),
                  ),
                ),
                if (highlightedComment != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _appSurfaceSoft(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _paneDivider(context)),
                    ),
                    child: Text(
                      'Highlighted comment: ${highlightedComment.body}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (comments.isEmpty)
                  const Text('No comments yet.')
                else
                  for (final comment in comments) ...[
                    _CommentNode(
                      repository: widget.repository,
                      comment: comment,
                      currentUserId: mockCurrentUserId,
                      highlightedCommentId: _selectedCommentId,
                      isSharedToPersonal: widget.sharePublicCommentsInPersonal
                          ? (item) => widget.repository.hasPersonalCommentShare(
                              authorId: mockCurrentUserId,
                              sourceKind: MockCommentShareSourceKind.thread,
                              sourceId: thread.id,
                              commentId: item.id,
                            )
                          : null,
                      onShareToPersonal: widget.sharePublicCommentsInPersonal
                          ? (item) => _refresh(
                              () => widget.repository
                                  .shareThreadCommentToPersonal(
                                    authorId: mockCurrentUserId,
                                    threadId: thread.id,
                                    commentId: item.id,
                                  ),
                            )
                          : null,
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

class _PlanPage extends StatefulWidget {
  const _PlanPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.plan,
    required this.planVotes,
    required this.onVote,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final MockPlan plan;
  final Map<String, int> planVotes;
  final void Function(String id, int value) onVote;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<_PlanPage> {
  void _refresh(VoidCallback action) {
    action();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.repository.planById(widget.plan.id) ?? widget.plan;
    final project = widget.repository.projectById(plan.projectId)!;
    final activeVote = widget.planVotes[plan.id] ?? 0;
    final resolvedApprove = plan.yes + (activeVote == 1 ? 1 : 0);
    final resolvedReject = plan.no + (activeVote == -1 ? 1 : 0);
    final linkedTransfers = widget.repository.transferRequestsForPlan(plan.id);
    final landManagementRequests = widget.repository
        .landManagementRequestsForPlan(plan.id);

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: plan.title,
      subtitle:
          'Plan detail keeps the exact proposal, approval numbers, and discussion visible together.',
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
                OutlinedButton(
                  onPressed: () => widget.onOpenProject(
                    project,
                    initialTab: MockProjectTab.plans,
                  ),
                  child: const Text('Open Project View'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: _planKindLabel(plan.kind),
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                    ),
                    _InfoChip(
                      label: plan.status,
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                    ),
                    _InfoChip(
                      label: plan.threshold,
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _appSurfaceSoft(
                      context,
                    ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ApprovalSummaryRow(
                        approvalCount: resolvedApprove,
                        rejectionCount: resolvedReject,
                        abstainCount: plan.abstain,
                        activeVote: activeVote,
                        onVote: plan.approved
                            ? null
                            : (value) =>
                                  _refresh(() => widget.onVote(plan.id, value)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${plan.closesLabel} · ${plan.threshold}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (plan.approved) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Voting closed on this approved plan.',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(plan.body),
                if (plan.estimatedExecutionLabel != null) ...[
                  const SizedBox(height: 16),
                  _MetaTable(
                    rows: [
                      ('Estimated execution', plan.estimatedExecutionLabel!),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (plan.assetNeeds.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assets And Equipment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final need in plan.assetNeeds) ...[
                    _SearchRow(
                      title: '${need.label} · ${need.quantityLabel}',
                      body:
                          need.note ?? 'Tied through this plan for execution.',
                      meta: need.linkedAssetId == null
                          ? (need.estimatedCost == null
                                ? 'No tied in-network asset'
                                : 'Fallback cost ${_money(need.estimatedCost!)}')
                          : 'Tied asset: ${widget.repository.foundationAssetById(need.linkedAssetId!)?.name ?? 'Unknown asset'}',
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
          if (plan.landRouting != null) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Land Management Routing',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _MetaTable(
                    rows: [
                      (
                        'Action',
                        plan.landRouting!.action == MockLandPlanAction.purchase
                            ? 'Buy land through this plan'
                            : 'Attach an existing land asset',
                      ),
                      (
                        'Management path',
                        plan.landRouting!.managementSelection ==
                                MockLandManagementSelection.existingService
                            ? 'Existing land-management service'
                            : 'New land-management service after approval',
                      ),
                      if (plan.landRouting!.landAssetId != null)
                        (
                          'Selected land asset',
                          widget.repository
                                  .foundationAssetById(
                                    plan.landRouting!.landAssetId!,
                                  )
                                  ?.name ??
                              'Unknown land asset',
                        ),
                      if (plan.landRouting!.existingProjectId != null)
                        (
                          'Existing service',
                          widget.repository
                                  .projectById(
                                    plan.landRouting!.existingProjectId!,
                                  )
                                  ?.title ??
                              'Unknown service',
                        ),
                      if (plan.landRouting!.resolvedProjectId != null)
                        (
                          'Resolved service',
                          widget.repository
                                  .projectById(
                                    plan.landRouting!.resolvedProjectId!,
                                  )
                                  ?.title ??
                              'Unknown service',
                        ),
                      if ((plan.landRouting!.statusLabel ?? '').isNotEmpty)
                        ('Status', plan.landRouting!.statusLabel!),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (plan.costLines.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cost Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final line in plan.costLines) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.label,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              if (line.note != null) ...[
                                const SizedBox(height: 4),
                                Text(line.note!),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _money(line.cost),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
          if (plan.checklist.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Execution Checklist',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final item in plan.checklist) ...[
                    Text('• $item'),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
          if (linkedTransfers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated Transfer Requests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Approved plan-linked asset needs appear here once the request queue is created.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final request in linkedTransfers) ...[
                    _SearchRow(
                      title:
                          widget.repository
                              .foundationAssetById(request.assetId)
                              ?.name ??
                          request.assetId,
                      body: request.note,
                      meta: '${request.statusLabel} · ${request.needByLabel}',
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
          if (landManagementRequests.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated Land-Management Requests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Approved plans that rely on an existing land-management service show their acceptance request here until the target service accepts or refuses it.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final request in landManagementRequests) ...[
                    _SearchRow(
                      title:
                          widget.repository
                              .projectById(request.targetProjectId)
                              ?.title ??
                          request.targetProjectId,
                      body:
                          request.note ??
                          'Land-management acceptance request created from this plan.',
                      meta:
                          '${_landManagementRequestStatusLabel(request.status)} · ${request.action == MockLandPlanAction.purchase ? 'Land purchase' : 'Land attachment'}',
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
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
                  hintText: 'Comment on this plan...',
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
                if (plan.discussion.isEmpty)
                  const Text('No plan comments yet.')
                else
                  for (final comment in plan.discussion) ...[
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
        ],
      ),
    );
  }
}

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
          'Events now stay social-first: overview, discussion, updates, and managers live on one purple surface.',
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
                          label: 'Event',
                          background: _eventSurface(context),
                          foreground: _eventAccent(context),
                          border: _eventBorder(context),
                        ),
                        _InfoChip(
                          label: widget.project == null
                              ? (event.isPrivate ? 'Private' : 'Public')
                              : 'Project Event',
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
                      : 'Project events now emphasize the social rhythm around the work instead of turning every gathering into a labor-planning checklist.',
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
                  hintText: 'Start an event discussion...',
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
                  const Text('No event discussion yet.')
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
                  const Text('No event updates yet.')
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

class _CreateProjectPage extends StatefulWidget {
  const _CreateProjectPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<_CreateProjectPage> {
  MockProjectType selectedType = MockProjectType.production;
  String title = 'Neighborhood Heat Pump Retrofit Pilot';
  String summary =
      'Research a small retrofit round before moving into full planning and procurement.';
  String locationLabel = 'Block 2 Retrofit Cluster, East Market, Riverbend';
  String district = 'East Market';
  String primaryChannel = 'Housing & Build';
  String additionalChannels = '';
  String taggedCommunities = '';
  String notes =
      'Looking for visible demand, likely participant count, and similar project overlap before the planning stage.';
  String serviceCadence = 'Scheduled';
  String serviceFlow =
      'Weekly evening service slots with direct request intake and lightweight triage.';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = _isDarkTheme(context);
    final typeStyle = typeStyleForMode(selectedType, isDarkMode: isDarkMode);
    final productionStyle = typeStyleForMode(
      MockProjectType.production,
      isDarkMode: isDarkMode,
    );
    final serviceStyle = typeStyleForMode(
      MockProjectType.service,
      isDarkMode: isDarkMode,
    );
    final stageStyle = stageStyleForMode(
      MockProjectStage.proposal,
      isDarkMode: isDarkMode,
    );
    final locationSuggestions = widget.repository.projects
        .map((item) => item.locationLabel)
        .toSet()
        .toList();
    final previewTagItems = [
      if (primaryChannel.trim().isNotEmpty)
        _TagChipData(label: primaryChannel, kind: _TagChipKind.channel),
      for (final label in _splitTags(additionalChannels))
        _TagChipData(label: label, kind: _TagChipKind.channel),
      for (final label in _splitTags(taggedCommunities))
        _TagChipData(label: label, kind: _TagChipKind.community),
    ];

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Project',
      subtitle:
          'New projects start in demand signalling so need, labor interest, and early coordination stay visible before planning begins.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Project setup',
          description:
              'Choose the project type, give it a location, and anchor discovery with at least one channel tag.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Type',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _TypeOptionCard(
                    title: 'Production',
                    body:
                        'Starts in demand signalling and can gather visible demand before planning locks.',
                    active: selectedType == MockProjectType.production,
                    accent: productionStyle.accent,
                    soft: productionStyle.soft,
                    border: productionStyle.border,
                    onTap: () => setState(
                      () => selectedType = MockProjectType.production,
                    ),
                  ),
                  _TypeOptionCard(
                    title: 'Service',
                    body:
                        'Starts in demand signalling and can move into recurring or one-time service once the operating shape is clear.',
                    active: selectedType == MockProjectType.service,
                    accent: serviceStyle.accent,
                    soft: serviceStyle.soft,
                    border: serviceStyle.border,
                    onTap: () =>
                        setState(() => selectedType = MockProjectType.service),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: locationSuggestions.contains(locationLabel)
                    ? locationLabel
                    : locationSuggestions.first,
                decoration: const InputDecoration(
                  labelText: 'Suggested location',
                ),
                items: [
                  for (final option in locationSuggestions)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => locationLabel = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: district,
                decoration: const InputDecoration(
                  labelText: 'District or neighborhood',
                ),
                onChanged: (value) => setState(() => district = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: summary,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Summary'),
                onChanged: (value) => setState(() => summary = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: primaryChannel,
                decoration: const InputDecoration(
                  labelText: 'Primary channel tag',
                ),
                onChanged: (value) => setState(() => primaryChannel = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: additionalChannels,
                decoration: const InputDecoration(
                  labelText: 'Additional channel tags',
                ),
                onChanged: (value) =>
                    setState(() => additionalChannels = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: taggedCommunities,
                decoration: const InputDecoration(labelText: 'Community tags'),
                onChanged: (value) => setState(() => taggedCommunities = value),
              ),
              const SizedBox(height: 12),
              if (selectedType == MockProjectType.production)
                TextFormField(
                  initialValue: notes,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Demand-signalling note',
                  ),
                  onChanged: (value) => setState(() => notes = value),
                )
              else
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: serviceCadence,
                      decoration: const InputDecoration(
                        labelText: 'Service cadence',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'One-time',
                          child: Text('One-time'),
                        ),
                        DropdownMenuItem(
                          value: 'Scheduled',
                          child: Text('Scheduled'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => serviceCadence = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: serviceFlow,
                      decoration: const InputDecoration(
                        labelText: 'Request pattern',
                      ),
                      onChanged: (value) => setState(() => serviceFlow = value),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: primaryChannel.trim().isEmpty ? null : () {},
                    child: const Text('Create Project'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description: 'Matches the current feed treatment for projects.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: typeStyle.soft,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
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
                                label: typeStyle.label,
                                background: typeStyle.soft,
                                foreground: typeStyle.accent,
                                border: typeStyle.border,
                              ),
                              _InfoChip(
                                label: stageStyle.label,
                                background: stageStyle.soft,
                                foreground: stageStyle.accent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TagWrap(
                            items: previewTagItems,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(summary),
                    const SizedBox(height: 10),
                    Text(
                      'Location · $locationLabel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedType == MockProjectType.service
                          ? '${serviceCadence.toLowerCase()} service flow · $serviceFlow'
                          : 'Research note · $notes',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _VoteStrip(
                          id: 'project-preview',
                          count: 0,
                          activeVote: 0,
                          onVote: (previewId, direction) {},
                        ),
                        const SizedBox(width: 8),
                        const _CountPill(
                          icon: Icons.mode_comment_outlined,
                          label: '0',
                        ),
                        const Spacer(),
                        Text(
                          '0 members · Posted now',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Posting rules',
              description:
                  'What happens immediately after creation in this mock.',
              child: Text(
                selectedType == MockProjectType.production
                    ? 'New production projects start in Demand Signalling. Votes stay separate from demand, and planning stays public because at least one channel tag is required.'
                    : 'New service projects also start in Demand Signalling. They can gather visible demand before moving into ongoing service and live request handling.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateThreadPage extends StatefulWidget {
  const _CreateThreadPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateThreadPage> createState() => _CreateThreadPageState();
}

class _CreateThreadPageState extends State<_CreateThreadPage> {
  String title = 'How should we coordinate first-round retrofit walkthroughs?';
  String body =
      'Looking for a discussion space that stays separate from the project logistics view so people can compare options without cluttering the project page.';
  String primaryTagType = 'Channel';
  String primaryTagValue = 'Housing & Build';
  String additionalChannels = '';
  String taggedCommunities = '';

  @override
  Widget build(BuildContext context) {
    final previewTagItems = [
      if (primaryTagValue.trim().isNotEmpty)
        _TagChipData(
          label: primaryTagValue,
          kind: primaryTagType == 'Community'
              ? _TagChipKind.community
              : _TagChipKind.channel,
        ),
      for (final label in _splitTags(additionalChannels))
        _TagChipData(label: label, kind: _TagChipKind.channel),
      for (final label in _splitTags(taggedCommunities))
        _TagChipData(label: label, kind: _TagChipKind.community),
    ];

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Thread',
      subtitle:
          'Threads are discussion-first surfaces. The primary tag can be either a channel or a community.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Thread setup',
          description:
              'Start the discussion, choose a primary discovery tag, and add optional tags for wider reach.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Thread title'),
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: primaryTagType,
                decoration: const InputDecoration(
                  labelText: 'Primary tag type',
                ),
                items: const [
                  DropdownMenuItem(value: 'Channel', child: Text('Channel')),
                  DropdownMenuItem(
                    value: 'Community',
                    child: Text('Community'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => primaryTagType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: primaryTagValue,
                decoration: InputDecoration(
                  labelText: primaryTagType == 'Community'
                      ? 'Primary community tag'
                      : 'Primary channel tag',
                ),
                onChanged: (value) => setState(() => primaryTagValue = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: additionalChannels,
                decoration: const InputDecoration(
                  labelText: 'Additional channel tags',
                ),
                onChanged: (value) =>
                    setState(() => additionalChannels = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: taggedCommunities,
                decoration: const InputDecoration(labelText: 'Community tags'),
                onChanged: (value) => setState(() => taggedCommunities = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: body,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Opening post'),
                onChanged: (value) => setState(() => body = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: primaryTagValue.trim().isEmpty ? null : () {},
                    child: const Text('Create Thread'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description:
                  'Threads now sit on the same surface as the feed background.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _threadSurface(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoChip(
                          label: 'Thread',
                          background: _appSurfaceStrong(context),
                          foreground:
                              Theme.of(context).textTheme.labelLarge?.color ??
                              Colors.white,
                          border: _appBorder(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TagWrap(
                            items: previewTagItems,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(body),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _VoteStrip(
                          id: 'thread-preview',
                          count: 0,
                          activeVote: 0,
                          onVote: (previewId, direction) {},
                        ),
                        const SizedBox(width: 8),
                        const _CountPill(
                          icon: Icons.mode_comment_outlined,
                          label: '0',
                        ),
                        const Spacer(),
                        Text(
                          'you · Posted now',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Discussion note',
              description:
                  'How the tag choice affects discovery in the mock app.',
              child: const Text(
                'Threads keep lightweight public discussion, comment nesting, and idea comparison outside the project logistics view.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateEventPage extends StatefulWidget {
  const _CreateEventPage({
    required this.repository,
    required this.currentUserId,
    this.initialChannelId,
    this.initialCommunityId,
    required this.topNav,
    required this.leftRail,
    required this.onEventCreated,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final String currentUserId;
  final String? initialChannelId;
  final String? initialCommunityId;
  final Widget topNav;
  final Widget leftRail;
  final ValueChanged<MockEvent> onEventCreated;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<_CreateEventPage> {
  String title = 'Transit Fare Protest Rally';
  String description =
      'A one-off public rally with speakers, sign-making, and a short station march.';
  String timeLabel = 'Apr 12, 1:00 PM';
  String location = 'East Market Station Plaza';
  bool isPrivate = false;
  late final Set<String> selectedChannelIds;
  late final Set<String> selectedCommunityIds;
  late final Set<String> invitedUserIds;

  @override
  void initState() {
    super.initState();
    final scopedCreate =
        widget.initialChannelId != null || widget.initialCommunityId != null;
    selectedChannelIds = {
      if (widget.initialChannelId != null)
        widget.initialChannelId!
      else if (!scopedCreate)
        'mutual-aid',
    };
    selectedCommunityIds = {
      if (widget.initialCommunityId != null)
        widget.initialCommunityId!
      else if (!scopedCreate)
        'east-market-retrofit-circle',
    };
    invitedUserIds = {if (!scopedCreate) 'mara-holt'};
  }

  @override
  Widget build(BuildContext context) {
    final channels = widget.repository.channels;
    final communities = widget.repository.communities;
    final following = widget.repository.followingForUser(widget.currentUserId);
    final previewEvent = MockEvent(
      id: 'event-preview',
      title: title.trim().isEmpty ? 'Untitled event' : title.trim(),
      timeLabel: timeLabel.trim().isEmpty ? 'Time not set' : timeLabel.trim(),
      location: location.trim().isEmpty ? 'Location not set' : location.trim(),
      going: 1,
      description: description.trim().isEmpty
          ? 'Describe the one-off event, who it is for, and what should happen.'
          : description.trim(),
      rolesNeeded: const [],
      materials: const [],
      outcome: '',
      managerIds: [widget.currentUserId],
      creatorId: widget.currentUserId,
      channelIds: selectedChannelIds.toList(),
      communityIds: selectedCommunityIds.toList(),
      invitedUserIds: invitedUserIds.toList(),
      isPrivate: isPrivate,
      createdAt: prototypeNow,
      lastActivity: prototypeNow,
    );
    final canSubmit =
        title.trim().isNotEmpty &&
        timeLabel.trim().isNotEmpty &&
        location.trim().isNotEmpty &&
        description.trim().isNotEmpty;

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Event',
      subtitle:
          'Events are one-off social surfaces: public meetups, private hangs, celebrations, protests, teach-ins, or any other gathering that should not be stretched into a project.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Event setup',
          description:
              'Choose whether the event lives on Public or Personal, add optional channel or community tags, and invite specific people directly when you need a tighter audience.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Visibility', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Public'),
                    selected: !isPrivate,
                    onSelected: (_) => setState(() => isPrivate = false),
                  ),
                  ChoiceChip(
                    showCheckmark: false,
                    label: const Text('Private'),
                    selected: isPrivate,
                    onSelected: (_) => setState(() => isPrivate = true),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Event title'),
                onChanged: (value) => setState(() => title = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: timeLabel,
                decoration: const InputDecoration(labelText: 'Time label'),
                onChanged: (value) => setState(() => timeLabel = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: location,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) => setState(() => location = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 14),
              Text(
                'Channel tags',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final channel in channels)
                    FilterChip(
                      label: Text(channel.name),
                      selected: selectedChannelIds.contains(channel.id),
                      onSelected:
                          widget.repository.canCreateEventInChannel(
                            channel,
                            widget.currentUserId,
                          )
                          ? (selected) => setState(() {
                              if (selected) {
                                selectedChannelIds.add(channel.id);
                              } else {
                                selectedChannelIds.remove(channel.id);
                              }
                            })
                          : null,
                    ),
                ],
              ),
              if (channels.any(
                (channel) =>
                    widget.repository.isStewardshipChannel(channel) &&
                    !widget.repository.canCreateEventInChannel(
                      channel,
                      widget.currentUserId,
                    ),
              )) ...[
                const SizedBox(height: 6),
                Text(
                  'Stewardship-tagged events can only be created by current board members.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 14),
              Text(
                'Community tags',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final community in communities)
                    FilterChip(
                      label: Text(community.name),
                      selected: selectedCommunityIds.contains(community.id),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          selectedCommunityIds.add(community.id);
                        } else {
                          selectedCommunityIds.remove(community.id);
                        }
                      }),
                    ),
                ],
              ),
              if (isPrivate) ...[
                const SizedBox(height: 14),
                Text(
                  'Invite people you follow',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                if (following.isEmpty)
                  const Text(
                    'You are not following anyone yet, so Personal will rely on your own followers plus direct tags.',
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final person in following)
                        FilterChip(
                          label: Text(_userHandle(person)),
                          selected: invitedUserIds.contains(person.id),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              invitedUserIds.add(person.id);
                            } else {
                              invitedUserIds.remove(person.id);
                            }
                          }),
                        ),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  'Private events can stay entirely personal, be shared with specific followers here, or still be scoped through channel and community tags.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: !canSubmit
                        ? null
                        : () {
                            final event = widget.repository
                                .createStandaloneEvent(
                                  title: title.trim(),
                                  timeLabel: timeLabel.trim(),
                                  location: location.trim(),
                                  description: description.trim(),
                                  creatorId: widget.currentUserId,
                                  channelIds: selectedChannelIds.toList(),
                                  communityIds: selectedCommunityIds.toList(),
                                  isPrivate: isPrivate,
                                  invitedUserIds: invitedUserIds.toList(),
                                  managerIds: [widget.currentUserId],
                                );
                            Navigator.of(context).pop();
                            widget.onEventCreated(event);
                          },
                    child: const Text('Create Event'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description:
                  'Shows how the event will appear once it starts surfacing in feeds and search.',
              surface: Colors.transparent,
              child: _StandaloneEventCard(
                repository: widget.repository,
                event: previewEvent,
                onOpenEvent: (_) {},
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Visibility rule',
              description: 'How discovery works in this mock.',
              child: Text(
                isPrivate
                    ? 'Private events can stay in Personal, can be shared with specific followers, or can be scoped through channel and community tags. If you leave tags empty, the event stays out of Public and lives in Personal instead.'
                    : 'Public events can be untagged or tagged. Tags help them appear inside channels, communities, and the broader Public feed instead of floating on their own.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCommunityPage extends StatefulWidget {
  const _CreateCommunityPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<_CreateCommunityPage> {
  String name = 'East Market Retrofit Circle';
  String openness = 'Open';
  String description =
      'Residents, installers, and planners connecting retrofit work across the east side.';

  @override
  Widget build(BuildContext context) {
    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Community',
      subtitle:
          'Communities are discoverable social spaces that connect people to projects and thread discussion without being tied to one channel.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Community setup',
          description:
              'Shape the public social space first, then refine norms and membership controls later.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Community name'),
                onChanged: (value) => setState(() => name = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: openness,
                decoration: const InputDecoration(labelText: 'Openness'),
                items: const [
                  DropdownMenuItem(value: 'Open', child: Text('Open')),
                  DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => openness = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Community'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description: 'How the new community row will read in discovery.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _appSurfaceSoft(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(
                      '$openness community',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Discovery note',
              description:
                  'What this surface is meant to do in the product model.',
              child: const Text(
                'Communities connect people to projects and thread discussion without forcing every topic into one shared channel feed.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateChannelPage extends StatefulWidget {
  const _CreateChannelPage({
    required this.repository,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_CreateChannelPage> createState() => _CreateChannelPageState();
}

class _CreateChannelPageState extends State<_CreateChannelPage> {
  String name = 'Energy Retrofit';
  String description =
      'Discussion and discovery for retrofit planning, installation, and maintenance work.';

  @override
  Widget build(BuildContext context) {
    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Create Channel',
      subtitle:
          'Channels are topic-based discovery surfaces. They host threads and project activity without defining community membership.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: _FlowSplit(
        primary: _FlowPanel(
          title: 'Channel setup',
          description:
              'Define the topic surface first. Communities can overlap with it later without replacing it.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Channel name'),
                onChanged: (value) => setState(() => name = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => setState(() => description = value),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Create Channel'),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Save Draft')),
                ],
              ),
            ],
          ),
        ),
        secondary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowPanel(
              title: 'Live preview',
              description: 'How the new topic surface will appear in lists.',
              surface: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _appSurfaceSoft(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(
                      'Topic channel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _FlowPanel(
              title: 'Discovery note',
              description: 'What makes a channel different from a community.',
              child: const Text(
                'Channels stay topic-based. They gather related threads and project activity without defining who belongs together socially.',
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.plan, required this.onTap});

  final MockPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      hoverColor: _rowHoverOverlay(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _appSurfaceSoft(
            context,
          ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(plan.summary),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  plan.approved ? 'Approved' : 'Up for vote',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (plan.estimatedExecutionLabel != null)
                  Text(
                    '· ${plan.estimatedExecutionLabel}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (plan.assetNeeds.isNotEmpty)
                  Text(
                    '· ${plan.assetNeeds.length} asset needs',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (plan.costLines.isNotEmpty)
                  Text(
                    '· ${plan.costLines.length} cost lines',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                _ApprovalSummaryRow(
                  approvalCount: plan.yes,
                  rejectionCount: plan.no,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTable extends StatelessWidget {
  const _MetaTable({required this.rows, this.title});

  final List<(String, String)> rows;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
        ],
        for (final row in rows) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  row.$1,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: Text(
                  row.$2,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LinkedTile extends StatefulWidget {
  const _LinkedTile({
    required this.title,
    required this.body,
    required this.onTap,
    this.badges = const <String>[],
  });

  final String title;
  final String body;
  final VoidCallback onTap;
  final List<String> badges;

  @override
  State<_LinkedTile> createState() => _LinkedTileState();
}

class _LinkedTileState extends State<_LinkedTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) {
          if (_hovered != value) {
            setState(() => _hovered = value);
          }
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 220,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                (_hovered
                        ? _appSurfaceStrong(context)
                        : _appSurfaceSoft(context))
                    .withValues(alpha: _isDarkTheme(context) ? 0.52 : 0.34),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovered ? _paneDivider(context) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.badges.isNotEmpty) ...[
                _TagWrap(labels: widget.badges),
                const SizedBox(height: 8),
              ],
              Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(widget.body, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _GovernanceCard extends StatelessWidget {
  const _GovernanceCard({
    required this.user,
    required this.roleLabel,
    required this.approveCount,
    required this.rejectCount,
    required this.activeVote,
    required this.onVote,
    required this.onOpenProfile,
  });

  final MockUser user;
  final String roleLabel;
  final int approveCount;
  final int rejectCount;
  final int activeVote;
  final ValueChanged<int> onVote;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final resolvedApprove = approveCount + (activeVote == 1 ? 1 : 0);
    final resolvedReject = rejectCount + (activeVote == -1 ? 1 : 0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenProfile,
        borderRadius: BorderRadius.circular(6),
        hoverColor: _rowHoverOverlay(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _appSurfaceSoft(
              context,
            ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserAvatar(user),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userHandle(user),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.location,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TagWrap(labels: [roleLabel]),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _ApprovalSummaryRow(
                approvalCount: resolvedApprove,
                rejectionCount: resolvedReject,
                activeVote: activeVote,
                onVote: onVote,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _approvalPercentFromCounts({
  required int approval,
  required int rejection,
  int abstain = 0,
}) {
  final total = approval + rejection + abstain;
  if (total <= 0) {
    return 0;
  }
  return ((approval / total) * 100).round();
}

class _ApprovalSummaryRow extends StatelessWidget {
  const _ApprovalSummaryRow({
    required this.approvalCount,
    required this.rejectionCount,
    this.abstainCount = 0,
    this.compact = false,
    this.activeVote = 0,
    this.onVote,
  });

  final int approvalCount;
  final int rejectionCount;
  final int abstainCount;
  final bool compact;
  final int activeVote;
  final ValueChanged<int>? onVote;

  @override
  Widget build(BuildContext context) {
    final labelStyle = compact
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.labelLarge;
    final canVote = onVote != null;

    return Wrap(
      spacing: compact ? 8 : 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${_approvalPercentFromCounts(approval: approvalCount, rejection: rejectionCount, abstain: abstainCount)}% approval',
          style: labelStyle,
        ),
        Text('·', style: labelStyle?.copyWith(color: _appMuted(context))),
        _VoteCountBadge(
          icon: Icons.keyboard_arrow_up_rounded,
          count: approvalCount,
          color: activeVote == 1
              ? _positiveVoteColor(context)
              : _appMuted(context),
          compact: compact,
          onTap: canVote ? () => onVote!(1) : null,
        ),
        Text('·', style: labelStyle?.copyWith(color: _appMuted(context))),
        _VoteCountBadge(
          icon: Icons.keyboard_arrow_down_rounded,
          count: rejectionCount,
          color: activeVote == -1
              ? _negativeVoteColor(context)
              : _appMuted(context),
          compact: compact,
          onTap: canVote ? () => onVote!(-1) : null,
        ),
      ],
    );
  }
}

class _VoteCountBadge extends StatelessWidget {
  const _VoteCountBadge({
    required this.icon,
    required this.count,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = compact
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.labelLarge;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 14 : 16, color: color),
        const SizedBox(width: 2),
        Text('$count', style: textStyle),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      hoverColor: _rowHoverOverlay(context),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 2 : 4,
          vertical: compact ? 2 : 3,
        ),
        child: content,
      ),
    );
  }
}

class _TypeOptionCard extends StatelessWidget {
  const _TypeOptionCard({
    required this.title,
    required this.body,
    required this.active,
    required this.accent,
    required this.soft,
    required this.border,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool active;
  final Color accent;
  final Color soft;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? soft : _appSurface(context),
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(
              color: active ? border : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: active
                    ? accent
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _AccentChoiceCard extends StatelessWidget {
  const _AccentChoiceCard({
    required this.label,
    required this.tone,
    required this.active,
    required this.onTap,
  });

  final String label;
  final MockAccentTheme tone;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      hoverColor: _rowHoverOverlay(context),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? tone.soft : _appSurfaceSoft(context),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? tone.primary : _appBorder(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: tone.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: active ? tone.title : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              active ? 'Active shell accent' : 'Available accent',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
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
          ),
          if (_desktopWindowControlsEnabled)
            const DragToMoveArea(
              child: SizedBox(width: 72, height: double.infinity),
            ),
          if (_desktopWindowControlsEnabled)
            _WindowToolbarButtons(brightness: Theme.of(context).brightness),
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

class _WindowToolbarButtons extends StatefulWidget {
  const _WindowToolbarButtons({required this.brightness});

  final Brightness brightness;

  @override
  State<_WindowToolbarButtons> createState() => _WindowToolbarButtonsState();
}

class _WindowToolbarButtonsState extends State<_WindowToolbarButtons>
    with WindowListener {
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    if (_desktopWindowControlsEnabled) {
      windowManager.addListener(this);
      _loadWindowState();
    }
  }

  @override
  void dispose() {
    if (_desktopWindowControlsEnabled) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  Future<void> _loadWindowState() async {
    final maximized = await windowManager.isMaximized();
    if (!mounted) {
      return;
    }
    setState(() {
      isMaximized = maximized;
    });
  }

  @override
  void onWindowMaximize() {
    setState(() {
      isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WindowCaptionButton.minimize(
          brightness: widget.brightness,
          onPressed: () {
            windowManager.minimize();
          },
        ),
        isMaximized
            ? WindowCaptionButton.unmaximize(
                brightness: widget.brightness,
                onPressed: () {
                  windowManager.unmaximize();
                },
              )
            : WindowCaptionButton.maximize(
                brightness: widget.brightness,
                onPressed: () {
                  windowManager.maximize();
                },
              ),
        WindowCaptionButton.close(
          brightness: widget.brightness,
          onPressed: () {
            windowManager.close();
          },
        ),
      ],
    );
  }
}

class _OnboardingStepData {
  const _OnboardingStepData({
    required this.id,
    required this.title,
    required this.body,
    required this.ctaCopy,
  });

  final String id;
  final String title;
  final String body;
  final String ctaCopy;
}

const List<_OnboardingStepData> _onboardingSteps = [
  _OnboardingStepData(
    id: 'welcome',
    title: 'Welcome',
    body:
        'Orient the user, explain the platform, and set expectations that this is a local-first collaborative app rather than a simple social feed.',
    ctaCopy:
        'Frame the product as a coordination space first, then let the user continue into identity and node setup basics.',
  ),
  _OnboardingStepData(
    id: 'identity',
    title: 'Identity And Keys',
    body:
        'Create or restore a persistent user identity without confusing it with the device or node identity.',
    ctaCopy:
        'Keep the language plain: restore an existing identity or create a new one tied to the person, not the current machine.',
  ),
  _OnboardingStepData(
    id: 'node',
    title: 'Node Setup Basics',
    body:
        'Choose the initial device participation mode in plain language and explain that sync may continue after entry.',
    ctaCopy:
        'Treat node mode as a plain-English setup choice and avoid implying that the app is blocked until perfect sync completes.',
  ),
  _OnboardingStepData(
    id: 'profile',
    title: 'Profile Setup',
    body:
        'Capture a public-facing profile summary, avatar, and the minimum information needed for discovery and coordination.',
    ctaCopy:
        'Ask only for the information needed to help people find and work with each other, then allow refinement later from settings.',
  ),
  _OnboardingStepData(
    id: 'interests',
    title: 'Interest Selection',
    body:
        'Give the user a lightweight way to shape early discovery without locking them into a rigid preference system.',
    ctaCopy:
        'Seed the first search and feed surfaces with suggested channels and communities, but keep everything editable after entry.',
  ),
  _OnboardingStepData(
    id: 'ready',
    title: 'Sync And Ready',
    body:
        'Show the app-ready checklist, communicate sync status, and let the user enter the product without waiting for perfect completeness.',
    ctaCopy:
        'End with a clear handoff into the feed, plus a reminder that search, notifications, settings, and profile remain available immediately.',
  ),
];

enum _OnboardingIdentityMode { create, restore }

class _OnboardingResult {
  const _OnboardingResult({
    required this.username,
    required this.location,
    required this.bio,
    required this.nodeMode,
    required this.showLocation,
    required this.publicAcknowledgement,
    required this.selectedChannelIds,
    required this.selectedCommunityIds,
  });

  final String username;
  final String location;
  final String bio;
  final String nodeMode;
  final bool showLocation;
  final bool publicAcknowledgement;
  final Set<String> selectedChannelIds;
  final Set<String> selectedCommunityIds;
}

class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({
    required this.repository,
    required this.initialUsername,
    required this.initialLocation,
    required this.initialBio,
    required this.initialNodeMode,
    required this.initialShowLocation,
    required this.initialPublicAcknowledgement,
    required this.initialSubscribedChannelIds,
    required this.initialJoinedCommunityIds,
    required this.topNav,
  });

  final MockRepository repository;
  final String initialUsername;
  final String initialLocation;
  final String initialBio;
  final String initialNodeMode;
  final bool initialShowLocation;
  final bool initialPublicAcknowledgement;
  final Set<String> initialSubscribedChannelIds;
  final Set<String> initialJoinedCommunityIds;
  final Widget topNav;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage> {
  int stepIndex = 0;
  late _OnboardingIdentityMode identityMode;
  late String username;
  late String location;
  late String bio;
  late String nodeMode;
  late bool showLocation;
  late bool publicAcknowledgement;
  late bool continueWhileSync;
  late String recoveryWords;
  late Set<String> selectedChannelIds;
  late Set<String> selectedCommunityIds;

  @override
  void initState() {
    super.initState();
    identityMode = _OnboardingIdentityMode.create;
    username = widget.initialUsername;
    location = widget.initialLocation;
    bio = widget.initialBio;
    nodeMode = widget.initialNodeMode;
    showLocation = widget.initialShowLocation;
    publicAcknowledgement = widget.initialPublicAcknowledgement;
    continueWhileSync = true;
    recoveryWords = '';
    selectedChannelIds = {...widget.initialSubscribedChannelIds};
    selectedCommunityIds = {...widget.initialJoinedCommunityIds};
  }

  _OnboardingStepData get _currentStep => _onboardingSteps[stepIndex];

  bool get _isLastStep => stepIndex == _onboardingSteps.length - 1;

  String get _normalizedUsername {
    final normalized = username.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_-]'),
      '',
    );
    return normalized;
  }

  String get _identityFingerprint {
    final seed = (_normalizedUsername.isEmpty ? 'builder' : _normalizedUsername)
        .padRight(8, 'x');
    return 'sp-${seed.substring(0, 8)}-local';
  }

  bool get _allRequiredStepsValid =>
      _identityStepValid && _profileStepValid && _interestStepValid;

  bool get _identityStepValid =>
      _normalizedUsername.length >= 3 &&
      (identityMode == _OnboardingIdentityMode.create ||
          recoveryWords.trim().length >= 12);

  bool get _profileStepValid =>
      location.trim().isNotEmpty && bio.trim().length >= 12;

  bool get _interestStepValid =>
      selectedChannelIds.isNotEmpty || selectedCommunityIds.isNotEmpty;

  String? get _validationMessage {
    switch (_currentStep.id) {
      case 'identity':
        if (_normalizedUsername.length < 3) {
          return 'Choose a username with at least 3 letters or numbers.';
        }
        if (identityMode == _OnboardingIdentityMode.restore &&
            recoveryWords.trim().length < 12) {
          return 'Add recovery words or a backup code to continue.';
        }
        return null;
      case 'profile':
        if (location.trim().isEmpty) {
          return 'Add a location label so nearby work is easier to read.';
        }
        if (bio.trim().length < 12) {
          return 'Write a short profile note so people know how to work with you.';
        }
        return null;
      case 'interests':
        if (!_interestStepValid) {
          return 'Pick at least one channel or community to seed discovery.';
        }
        return null;
      case 'ready':
        if (!_allRequiredStepsValid) {
          return 'Finish the earlier setup steps before entering the feed.';
        }
        return null;
      default:
        return null;
    }
  }

  bool get _canContinue => _validationMessage == null;

  void _toggleChannel(String channelId) {
    setState(() {
      if (!selectedChannelIds.add(channelId)) {
        selectedChannelIds.remove(channelId);
      }
    });
  }

  void _toggleCommunity(String communityId) {
    setState(() {
      if (!selectedCommunityIds.add(communityId)) {
        selectedCommunityIds.remove(communityId);
      }
    });
  }

  void _finishOnboarding() {
    Navigator.of(context).pop(
      _OnboardingResult(
        username: _normalizedUsername,
        location: location.trim(),
        bio: bio.trim(),
        nodeMode: nodeMode,
        showLocation: showLocation,
        publicAcknowledgement: publicAcknowledgement,
        selectedChannelIds: selectedChannelIds,
        selectedCommunityIds: selectedCommunityIds,
      ),
    );
  }

  Widget _buildStepPrimary(BuildContext context, _OnboardingStepData step) {
    switch (step.id) {
      case 'welcome':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how this account starts on this device.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SetupChoiceCard(
                  title: 'Create A New Identity',
                  description:
                      'Use this when you are starting fresh and want a new local account identity.',
                  active: identityMode == _OnboardingIdentityMode.create,
                  badge: 'New account',
                  onTap: () => setState(
                    () => identityMode = _OnboardingIdentityMode.create,
                  ),
                ),
                _SetupChoiceCard(
                  title: 'Restore Existing Identity',
                  description:
                      'Use recovery words or a backup code to bring an existing person-level identity onto this device.',
                  active: identityMode == _OnboardingIdentityMode.restore,
                  badge: 'Recovery',
                  onTap: () => setState(
                    () => identityMode = _OnboardingIdentityMode.restore,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MetaTable(
              rows: const [
                ('What gets set up', 'Identity, node mode, profile, discovery'),
                ('Editable later', 'Everything from settings and profile'),
                ('Entry rule', 'You can enter while sync keeps running'),
              ],
            ),
          ],
        );
      case 'identity':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: username,
              decoration: const InputDecoration(
                labelText: 'Username',
                helperText:
                    'This is how people search for you in the mock app.',
              ),
              onChanged: (value) => setState(() => username = value),
            ),
            const SizedBox(height: 12),
            if (identityMode == _OnboardingIdentityMode.restore)
              TextFormField(
                initialValue: recoveryWords,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Recovery words or backup code',
                  helperText:
                      'Mock input only. Restoring keeps the account tied to the person, not the device.',
                ),
                onChanged: (value) => setState(() => recoveryWords = value),
              )
            else
              _MetaTable(
                rows: [
                  ('Identity mode', 'Create new local identity'),
                  ('Key fingerprint', _identityFingerprint),
                  ('Recovery', 'Add a backup later from settings'),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              'Public username preview: ${_normalizedUsername.isEmpty ? 'choose-a-username' : _normalizedUsername}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        );
      case 'node':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SetupChoiceCard(
                  title: 'Light',
                  description:
                      'Fastest way to get started. Good for browsing, messaging, and planning while sync stays thin.',
                  active: nodeMode == 'light',
                  badge: 'Recommended',
                  onTap: () => setState(() => nodeMode = 'light'),
                ),
                _SetupChoiceCard(
                  title: 'Hybrid',
                  description:
                      'Keeps more local coordination data ready while still feeling like a normal desktop app.',
                  active: nodeMode == 'hybrid',
                  badge: 'Balanced',
                  onTap: () => setState(() => nodeMode = 'hybrid'),
                ),
                _SetupChoiceCard(
                  title: 'Full',
                  description:
                      'Best for operators who want the heaviest local participation footprint from the start.',
                  active: nodeMode == 'full',
                  badge: 'Heavy local mode',
                  onTap: () => setState(() => nodeMode = 'full'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enter the app while sync keeps running'),
              subtitle: const Text(
                'The mock keeps setup moving instead of blocking on a perfect first sync.',
              ),
              value: continueWhileSync,
              onChanged: (value) => setState(() => continueWhileSync = value),
            ),
          ],
        );
      case 'profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: location,
              decoration: const InputDecoration(
                labelText: 'Approximate location',
                helperText: 'Keep it human-readable rather than exact.',
              ),
              onChanged: (value) => setState(() => location = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: bio,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Short bio',
                helperText:
                    'What kind of work do you want people to contact you about?',
              ),
              onChanged: (value) => setState(() => bio = value),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show approximate location on profile'),
              value: showLocation,
              onChanged: (value) => setState(() => showLocation = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Public contributor acknowledgement'),
              subtitle: const Text(
                'Keeps your participation visible on public-facing project history where appropriate.',
              ),
              value: publicAcknowledgement,
              onChanged: (value) =>
                  setState(() => publicAcknowledgement = value),
            ),
          ],
        );
      case 'interests':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick the spaces you want to see first.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Channels seed the day-to-day work stream.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final channel in widget.repository.channels)
                  _SetupChoiceCard(
                    title: channel.name,
                    description: channel.description,
                    active: selectedChannelIds.contains(channel.id),
                    badge: 'Channel',
                    onTap: () => _toggleChannel(channel.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Communities shape people-centered discovery.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final community in widget.repository.communities)
                  _SetupChoiceCard(
                    title: community.name,
                    description: community.description,
                    active: selectedCommunityIds.contains(community.id),
                    badge: community.openness,
                    onTap: () => _toggleCommunity(community.id),
                  ),
              ],
            ),
          ],
        );
      case 'ready':
        final selectedLabels = [
          ...selectedChannelIds
              .map(widget.repository.channelById)
              .whereType<MockChannel>()
              .map((item) => item.name),
          ...selectedCommunityIds
              .map(widget.repository.communityById)
              .whereType<MockCommunity>()
              .map((item) => item.name),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetaTable(
              rows: [
                ('Username', _normalizedUsername),
                ('Node mode', _capitalize(nodeMode)),
                ('Profile location', showLocation ? location.trim() : 'Hidden'),
                (
                  'Sync handoff',
                  continueWhileSync ? 'Enter immediately' : 'Wait for sync cue',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Selected starting spaces',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            if (selectedLabels.isEmpty)
              const Text('No spaces selected yet.')
            else
              _TagWrap(labels: selectedLabels),
            const SizedBox(height: 14),
            Text(
              'You can keep adjusting profile, discovery picks, and visibility settings after entry.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepSecondary(BuildContext context, _OnboardingStepData step) {
    switch (step.id) {
      case 'welcome':
        return _MetaTable(
          rows: const [
            ('Feed', 'Available as soon as setup is done'),
            ('Search', 'Projects, threads, spaces, and people'),
            ('Messages', 'Direct conversations stay private'),
          ],
        );
      case 'identity':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _normalizedUsername.isEmpty
                  ? 'choose-a-username'
                  : _normalizedUsername,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              identityMode == _OnboardingIdentityMode.create
                  ? 'New local identity prepared for first entry.'
                  : 'Existing identity will be restored onto this device.',
            ),
            const SizedBox(height: 12),
            _MetaTable(
              rows: [
                (
                  'Mode',
                  identityMode == _OnboardingIdentityMode.create
                      ? 'Create'
                      : 'Restore',
                ),
                ('Fingerprint', _identityFingerprint),
                (
                  'People will see',
                  _normalizedUsername.isEmpty
                      ? 'Username pending'
                      : _normalizedUsername,
                ),
              ],
            ),
          ],
        );
      case 'node':
        return _MetaTable(
          rows: [
            ('Current mode', _capitalize(nodeMode)),
            ('Peers visible', '6 mock peers'),
            (
              'Entry behavior',
              continueWhileSync
                  ? 'Enter while sync continues'
                  : 'Wait for sync cue',
            ),
          ],
        );
      case 'profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: MockPalette.greenSoft,
                  foregroundColor: MockPalette.greenDark,
                  child: Text(
                    (_normalizedUsername.isEmpty
                            ? 'U'
                            : _normalizedUsername.characters.first)
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _normalizedUsername.isEmpty
                            ? 'choose-a-username'
                            : _normalizedUsername,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(showLocation ? location.trim() : 'Location hidden'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bio.trim().isEmpty ? 'Bio preview will appear here.' : bio.trim(),
            ),
            const SizedBox(height: 12),
            _TagWrap(
              labels: [
                if (showLocation) 'Location visible' else 'Location hidden',
                if (publicAcknowledgement) 'Public acknowledgement on',
              ],
            ),
          ],
        );
      case 'interests':
        final selectedLabels = [
          ...selectedChannelIds
              .map(widget.repository.channelById)
              .whereType<MockChannel>()
              .map((item) => item.name),
          ...selectedCommunityIds
              .map(widget.repository.communityById)
              .whereType<MockCommunity>()
              .map((item) => item.name),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discovery preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            if (selectedLabels.isEmpty)
              const Text(
                'Pick a few spaces to seed the first search and feed views.',
              )
            else
              _TagWrap(labels: selectedLabels),
          ],
        );
      case 'ready':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetaTable(
              rows: [
                ('Feed entry', 'Immediate'),
                ('Notifications', 'Ready after setup'),
                ('Settings edits', 'Available immediately'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This handoff keeps the app usable even if sync and discovery refinement continue after first entry.',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _currentStep;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            widget.topNav,
            Expanded(
              child: Container(
                color: _centerPaneSurface(context),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 940),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final intro = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/brand/logo.png',
                                    height: 72,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Account Start',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: _appMuted(context),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.title,
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(fontSize: 32),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    step.body,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: _appMuted(context),
                                    ),
                                  ),
                                ],
                              );

                              final summary = Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _appSurfaceSoft(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Step',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: _appMuted(context)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${stepIndex + 1} of ${_onboardingSteps.length}',
                                      style: theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      step.id.toUpperCase(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: _appMuted(context),
                                            letterSpacing: 1.0,
                                          ),
                                    ),
                                  ],
                                ),
                              );

                              if (constraints.maxWidth >= 760) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: intro),
                                    const SizedBox(width: 20),
                                    SizedBox(width: 180, child: summary),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  intro,
                                  const SizedBox(height: 16),
                                  summary,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          Divider(color: _paneDivider(context), height: 1),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Close'),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (
                                var index = 0;
                                index < _onboardingSteps.length;
                                index++
                              )
                                ChoiceChip(
                                  label: Text(
                                    '${index + 1}. ${_onboardingSteps[index].title}',
                                  ),
                                  selected: index == stepIndex,
                                  onSelected: (_) =>
                                      setState(() => stepIndex = index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _FlowSplit(
                            primary: _FlowPanel(
                              title: 'Do This Now',
                              description:
                                  'This step updates real mock setup state instead of just explaining it.',
                              child: _buildStepPrimary(context, step),
                            ),
                            secondary: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FlowPanel(
                                  title: 'Step Guidance',
                                  description:
                                      'Plain-language guidance for the current account-start moment.',
                                  child: Text(step.ctaCopy),
                                ),
                                const SizedBox(height: 12),
                                _FlowPanel(
                                  title: 'Current Preview',
                                  description:
                                      'How the current setup choices will look when the user enters the app.',
                                  child: _buildStepSecondary(context, step),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_validationMessage != null) ...[
                            Text(
                              _validationMessage!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _negativeVoteColor(context),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            children: [
                              TextButton(
                                onPressed: stepIndex == 0
                                    ? null
                                    : () => setState(() => stepIndex -= 1),
                                child: const Text('Back'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: !_canContinue
                                    ? null
                                    : _isLastStep
                                    ? _finishOnboarding
                                    : () => setState(() => stepIndex += 1),
                                child: Text(
                                  _isLastStep ? 'Enter The Feed' : 'Continue',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupChoiceCard extends StatelessWidget {
  const _SetupChoiceCard({
    required this.title,
    required this.description,
    required this.active,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String description;
  final bool active;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      hoverColor: _rowHoverOverlay(context),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? _appSurfaceStrong(context) : _appSurfaceSoft(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? _interactionAccent(context) : _appBorder(context),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null) ...[
              _TagWrap(labels: [badge!]),
              const SizedBox(height: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}

enum _TaggedFeedFilter { all, threads, events, taggedProjects }

enum _ScopedPeoplePanel { feed, members, moderators }

enum _ScopedCreateAction { thread, project, event }

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

class _SearchPage extends StatefulWidget {
  const _SearchPage({
    required this.repository,
    required this.initialQuery,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenThread,
    required this.onOpenStandaloneEvent,
    required this.onOpenChannel,
    required this.onOpenCommunity,
    required this.onOpenProfile,
    required this.topNav,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final String initialQuery;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockThread thread) onOpenThread;
  final void Function(MockEvent event) onOpenStandaloneEvent;
  final ValueChanged<MockChannel> onOpenChannel;
  final ValueChanged<MockCommunity> onOpenCommunity;
  final void Function(MockUser user) onOpenProfile;
  final Widget topNav;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  late String query;

  @override
  void initState() {
    super.initState();
    query = widget.initialQuery;
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.repository.search(query);

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Search',
      subtitle:
          'Search keeps projects, threads, one-off events, and social surfaces visible without collapsing them into one result type.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: TextFormField(
              initialValue: query,
              decoration: const InputDecoration(
                labelText:
                    'Search projects, threads, events, communities, channels, and people',
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          const SizedBox(height: 16),
          _SearchSection(
            title: 'Projects',
            children: [
              for (final item in results.projects)
                _SearchRow(
                  title: item.title,
                  body: item.summary,
                  meta: item.locationLabel,
                  onTap: () => widget.onOpenProject(item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchSection(
            title: 'Threads',
            children: [
              for (final item in results.threads)
                _SearchRow(
                  title: item.title,
                  body: item.body,
                  meta: _userHandle(widget.repository.userById(item.authorId)),
                  onTap: () => widget.onOpenThread(item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchSection(
            title: 'Events',
            children: [
              for (final item in results.events)
                _SearchRow(
                  title: item.title,
                  body: item.description,
                  meta: '${item.timeLabel} · ${item.location}',
                  onTap: () => widget.onOpenStandaloneEvent(item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchSection(
            title: 'Channels',
            children: [
              for (final item in results.channels)
                _SearchRow(
                  title: item.name,
                  body: item.description,
                  meta: '${item.memberIds.length} members',
                  onTap: () => widget.onOpenChannel(item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchSection(
            title: 'Communities',
            children: [
              for (final item in results.communities)
                _SearchRow(
                  title: item.name,
                  body: item.description,
                  meta: item.openness,
                  onTap: () => widget.onOpenCommunity(item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchSection(
            title: 'People',
            children: [
              for (final item in results.users)
                _SearchRow(
                  title: _userHandle(item),
                  body: item.bio,
                  meta: item.location,
                  onTap: () => widget.onOpenProfile(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoundationPage extends StatefulWidget {
  const _FoundationPage({
    required this.repository,
    required this.leftRail,
    required this.topNav,
    required this.onOpenProject,
    required this.onOpenAsset,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final Widget leftRail;
  final Widget topNav;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockFoundationAsset asset) onOpenAsset;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_FoundationPage> createState() => _FoundationPageState();
}

class _FoundationPageState extends State<_FoundationPage> {
  @override
  Widget build(BuildContext context) {
    final landAssets = widget.repository.standaloneLandAssets();
    final linkedProjectsCount = landAssets.fold<int>(
      0,
      (sum, item) =>
          sum + widget.repository.linkedProjectsForLandAsset(item).length,
    );
    final directAssetCount = landAssets.fold<int>(
      0,
      (sum, item) =>
          sum + widget.repository.directAssetsForLandAsset(item.id).length,
    );

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Assets',
      subtitle:
          'Land assets are the physical anchor for everything in the mock. Open a land asset to see linked projects, land-management services, storage services, and any assets tied directly to the land asset itself.',
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: '${landAssets.length} land assets',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                    ),
                    _InfoChip(
                      label: '$linkedProjectsCount linked projects',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                    ),
                    _InfoChip(
                      label: '$directAssetCount tied-to-land assets',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                    ),
                    _InfoChip(
                      label: 'Land-first physical model',
                      background: MockPalette.greenSoft,
                      foreground: MockPalette.greenDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Each row opens a land asset page. That page shows the projects linked to the land, including land-management and storage services, and keeps any tied-to-land assets separate when no storage service or building sits between them and the land asset.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (landAssets.isEmpty)
            const _SectionCard(child: Text('No land assets are listed yet.'))
          else ...[
            Text('Land Assets', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final asset in landAssets)
              _StandaloneLandAssetCard(
                repository: widget.repository,
                asset: asset,
                onOpenAsset: widget.onOpenAsset,
              ),
          ],
        ],
      ),
    );
  }
}

class _AssetStockRow extends StatelessWidget {
  const _AssetStockRow({
    required this.item,
    required this.asset,
    required this.onOpenAsset,
    this.onRequestAsProject,
  });

  final MockAssetStockItem item;
  final MockFoundationAsset asset;
  final VoidCallback onOpenAsset;
  final VoidCallback? onRequestAsProject;

  @override
  Widget build(BuildContext context) {
    final requestabilityLabel = _requestabilityLabel(item.requestability);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenAsset,
        borderRadius: BorderRadius.circular(6),
        hoverColor: _rowHoverOverlay(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _appSurfaceSoft(
              context,
            ).withValues(alpha: _isDarkTheme(context) ? 0.5 : 0.34),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Opens ${asset.name}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.quantityLabel,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: _appMuted(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(item.statusLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    label: requestabilityLabel,
                    background: _requestabilityBackground(
                      context,
                      item.requestability,
                    ),
                    foreground: _requestabilityForeground(
                      context,
                      item.requestability,
                    ),
                    border: _requestabilityBorder(context, item.requestability),
                  ),
                  if (asset.buildingId != null)
                    _InfoChip(
                      label: 'Building-tied asset',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                    ),
                ],
              ),
              if (item.note != null) ...[
                const SizedBox(height: 6),
                Text(item.note!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: onOpenAsset,
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('Open Asset'),
                  ),
                  if (onRequestAsProject != null &&
                      item.requestability !=
                          MockAssetRequestability.unavailable)
                    FilledButton.tonal(
                      onPressed: onRequestAsProject,
                      child: const Text('Request As Project'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandaloneLandAssetCard extends StatelessWidget {
  const _StandaloneLandAssetCard({
    required this.repository,
    required this.asset,
    required this.onOpenAsset,
  });

  final MockRepository repository;
  final MockFoundationAsset asset;
  final void Function(MockFoundationAsset asset) onOpenAsset;

  @override
  Widget build(BuildContext context) {
    final chipStyle = _landAssetChipStyle(context);
    final linkedProjects = repository.linkedProjectsForLandAsset(asset);
    final storageServiceCount = linkedProjects
        .where(
          (item) =>
              item.type == MockProjectType.service &&
              item.serviceKind == MockServiceKind.storage,
        )
        .length;
    final landManagementCount = linkedProjects
        .where((item) => item.serviceKind == MockServiceKind.landManagement)
        .length;
    final directAssets = repository.directAssetsForLandAsset(asset.id);

    return _InteractiveFeedRow(
      background: _threadSurface(context),
      onTap: () => onOpenAsset(asset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: chipStyle.label,
                background: chipStyle.background,
                foreground: chipStyle.foreground,
                border: Colors.transparent,
              ),
              _InfoChip(
                label: '${linkedProjects.length} linked projects',
                background: MockPalette.panelSoft,
                foreground: MockPalette.text,
                border: MockPalette.border,
              ),
              if (landManagementCount > 0)
                _InfoChip(
                  label: '$landManagementCount land-management services',
                  background: MockPalette.panelSoft,
                  foreground: MockPalette.text,
                  border: MockPalette.border,
                ),
              if (storageServiceCount > 0)
                _InfoChip(
                  label: '$storageServiceCount storage services',
                  background: MockPalette.panelSoft,
                  foreground: MockPalette.text,
                  border: MockPalette.border,
                ),
              if (directAssets.isNotEmpty)
                _InfoChip(
                  label: '${directAssets.length} tied-to-land assets',
                  background: MockPalette.panelSoft,
                  foreground: MockPalette.text,
                  border: MockPalette.border,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(asset.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(asset.summary),
          const SizedBox(height: 10),
          Text(
            '${asset.locationLabel} · ${asset.availabilityLabel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AssetDetailPage extends StatelessWidget {
  const _AssetDetailPage({
    required this.repository,
    required this.asset,
    required this.topNav,
    required this.leftRail,
    required this.onOpenProject,
    required this.onOpenAsset,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockFoundationAsset asset;
  final Widget topNav;
  final Widget leftRail;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockFoundationAsset asset) onOpenAsset;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  Widget build(BuildContext context) {
    final isLandAsset = asset.groupLabel == 'Land';
    final zone = repository.foundationZoneById(asset.zoneId);
    final linkedProjects = isLandAsset
        ? repository.linkedProjectsForLandAsset(asset)
        : repository.linkedProjectsForAsset(asset);
    final storageServices = linkedProjects
        .where(
          (project) =>
              project.type == MockProjectType.service &&
              project.serviceKind == MockServiceKind.storage,
        )
        .toList();
    final landManagementServices = linkedProjects
        .where(
          (project) => project.serviceKind == MockServiceKind.landManagement,
        )
        .toList();
    final directAssets = isLandAsset
        ? repository.directAssetsForLandAsset(asset.id)
        : repository.linkedAssetsForAsset(asset);
    final assetHistory = repository.assetHistoryForAsset(asset.id);
    final stewardProject = repository.stewardProjectForAsset(asset);
    final chipStyle = _landAssetChipStyle(context);
    final chipLabel = isLandAsset ? chipStyle.label : 'Asset';

    return _DetailShell(
      repository: repository,
      topNav: topNav,
      leftRail: leftRail,
      title: asset.name,
      subtitle: isLandAsset
          ? 'Land asset detail keeps the physical land base separate from the linked projects, land-management services, storage services, buildings, and tied-to-land assets around it.'
          : 'Asset detail keeps current location, steward links, and asset history on one surface.',
      onOpenProject: onOpenProject,
      onOpenPlan: onOpenPlan,
      onOpenEvent: onOpenEvent,
      showHeaderText: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: chipLabel,
                      background: chipStyle.background,
                      foreground: chipStyle.foreground,
                      border: Colors.transparent,
                    ),
                    _InfoChip(
                      label: '${linkedProjects.length} linked projects',
                      background: MockPalette.panelSoft,
                      foreground: MockPalette.text,
                      border: MockPalette.border,
                    ),
                    if (landManagementServices.isNotEmpty)
                      _InfoChip(
                        label:
                            '${landManagementServices.length} land-management services',
                        background: MockPalette.panelSoft,
                        foreground: MockPalette.text,
                        border: MockPalette.border,
                      ),
                    if (storageServices.isNotEmpty)
                      _InfoChip(
                        label: '${storageServices.length} storage services',
                        background: MockPalette.panelSoft,
                        foreground: MockPalette.text,
                        border: MockPalette.border,
                      ),
                    if (directAssets.isNotEmpty)
                      _InfoChip(
                        label: '${directAssets.length} tied-to-land assets',
                        background: MockPalette.panelSoft,
                        foreground: MockPalette.text,
                        border: MockPalette.border,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  asset.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  asset.summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                _MetaTable(
                  rows: [
                    ('Location', asset.locationLabel),
                    ('Zone', zone?.name ?? 'Not set'),
                    ('Availability', asset.availabilityLabel),
                    if (stewardProject != null)
                      (
                        stewardProject.serviceKind ==
                                MockServiceKind.landManagement
                            ? 'Managing land service'
                            : 'Steward project',
                        stewardProject.title,
                      ),
                    (
                      isLandAsset ? 'Physical model' : 'Asset history',
                      isLandAsset
                          ? 'Land is the physical anchor. Other assets link through buildings, storage services, or directly as tied-to-land assets.'
                          : 'This asset keeps a visible land-and-storage trail so users can trace where it sits and how custody has moved.',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (linkedProjects.isEmpty && directAssets.isEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Text(
                isLandAsset
                    ? 'No linked projects or tied-to-land assets are listed for this land asset yet.'
                    : 'No linked projects or related assets are listed for this asset yet.',
              ),
            ),
          ],
          if (linkedProjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linked Projects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final project in linkedProjects)
                        Builder(
                          builder: (context) {
                            final buildingCount = repository
                                .storageBuildingsForProject(project.id)
                                .length;
                            final managedAssetCount = repository
                                .foundationAssetsForProject(project.id)
                                .length;

                            return _LinkedTile(
                              title: project.title,
                              body: project.summary,
                              badges: [
                                stageStyleForMode(
                                  project.stage,
                                  isDarkMode: _isDarkTheme(context),
                                ).label,
                                if (project.type == MockProjectType.service &&
                                    project.serviceKind ==
                                        MockServiceKind.landManagement)
                                  'Land-management service',
                                if (project.type == MockProjectType.service &&
                                    project.serviceKind ==
                                        MockServiceKind.storage)
                                  'Storage service',
                                if (buildingCount > 0)
                                  '$buildingCount buildings',
                                if (buildingCount == 0 && managedAssetCount > 0)
                                  '$managedAssetCount asset records',
                              ],
                              onTap: () => onOpenProject(
                                project,
                                initialTab:
                                    project.type == MockProjectType.service &&
                                        project.serviceKind ==
                                            MockServiceKind.storage
                                    ? MockProjectTab.overview
                                    : project.isCollectiveAssetProject
                                    ? MockProjectTab.inventory
                                    : MockProjectTab.overview,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (directAssets.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLandAsset ? 'Tied-To-Land Assets' : 'Linked Assets',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isLandAsset
                        ? 'These assets are tied directly to the land asset because no storage service or building is acting as the more precise physical location yet.'
                        : 'These linked assets help show where this item sits in the broader storage and custody chain.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final linkedAsset in directAssets) ...[
                    _MiniRow(
                      title: linkedAsset.name,
                      body:
                          'Asset · ${linkedAsset.availabilityLabel} · ${linkedAsset.locationLabel}',
                      onTap: () => onOpenAsset(linkedAsset),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asset History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This history shows how the asset stays tied to land, storage, and steward-controlled handoffs over time.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                if (assetHistory.isEmpty)
                  const Text(
                    'No origin or transfer history is recorded for this asset yet.',
                  )
                else
                  for (final entry in assetHistory) ...[
                    _SearchRow(
                      title: entry.title,
                      body: entry.body,
                      meta:
                          '${entry.categoryLabel} · ${entry.locationLabel} · ${_relativeTime(entry.time)}',
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

class _LandManagementRequestCard extends StatelessWidget {
  const _LandManagementRequestCard({
    required this.repository,
    required this.request,
    required this.currentProject,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenAsset,
    required this.onOpenProfile,
    this.onAccept,
    this.onRefuse,
    this.managerActions = false,
  });

  final MockRepository repository;
  final MockLandManagementRequest request;
  final MockProject currentProject;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockFoundationAsset asset) onOpenAsset;
  final void Function(MockUser user) onOpenProfile;
  final VoidCallback? onAccept;
  final VoidCallback? onRefuse;
  final bool managerActions;

  @override
  Widget build(BuildContext context) {
    final requester = repository.userById(request.requesterId)!;
    final sourceProject = repository.projectById(request.requestingProjectId)!;
    final targetProject = repository.projectById(request.targetProjectId)!;
    final plan = repository.planById(request.planId);
    final landAsset = request.landAssetId == null
        ? null
        : repository.foundationAssetById(request.landAssetId!);
    final isIncoming = request.targetProjectId == currentProject.id;
    final canDecide =
        managerActions &&
        isIncoming &&
        request.status == MockLandManagementRequestStatus.pending;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: isIncoming ? 'Incoming' : 'Outgoing',
                background: MockPalette.panelSoft,
                foreground: MockPalette.text,
                border: MockPalette.border,
              ),
              _InfoChip(
                label: _landManagementRequestStatusLabel(request.status),
                background: _landManagementStatusBackground(
                  context,
                  request.status,
                ),
                foreground: _landManagementStatusForeground(
                  context,
                  request.status,
                ),
              ),
              _InfoChip(
                label: request.action == MockLandPlanAction.purchase
                    ? 'Land purchase'
                    : 'Land attachment',
                background: MockPalette.panelSoft,
                foreground: MockPalette.text,
                border: MockPalette.border,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan?.title ?? 'Land-management request',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            request.note ??
                'A plan is waiting on land-management acceptance before the route is fully settled.',
          ),
          const SizedBox(height: 10),
          Text(
            'Requester ${_userHandle(requester)} · Source ${sourceProject.title} · Service ${targetProject.title}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (landAsset != null) ...[
            const SizedBox(height: 6),
            Text(
              'Selected land asset: ${landAsset.name}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (canDecide)
                ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Accept Management'),
                ),
              if (canDecide)
                OutlinedButton(
                  onPressed: onRefuse,
                  child: const Text('Refuse Management'),
                ),
              OutlinedButton.icon(
                onPressed: () => onOpenProfile(requester),
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Open Requester'),
              ),
              if (plan != null)
                TextButton.icon(
                  onPressed: () => onOpenPlan(plan),
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Open Plan'),
                ),
              TextButton.icon(
                onPressed: () => onOpenProject(sourceProject),
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text('Open Source Project'),
              ),
              if (landAsset != null)
                TextButton.icon(
                  onPressed: () => onOpenAsset(landAsset),
                  icon: const Icon(Icons.terrain_outlined),
                  label: const Text('Open Land Asset'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftwareChangeRequestCard extends StatelessWidget {
  const _SoftwareChangeRequestCard({
    required this.repository,
    required this.request,
    required this.managerActions,
    required this.onOpenProfile,
    this.onMoveToReview,
    this.onRequestChanges,
    this.onMerge,
    this.onReject,
  });

  final MockRepository repository;
  final MockSoftwareChangeRequest request;
  final bool managerActions;
  final void Function(MockUser user) onOpenProfile;
  final VoidCallback? onMoveToReview;
  final VoidCallback? onRequestChanges;
  final VoidCallback? onMerge;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final requester = repository.userById(request.requesterId)!;
    final status = request.status;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: _softwareChangeRequestStatusLabel(status),
                background: _softwareChangeStatusBackground(context, status),
                foreground: _softwareChangeStatusForeground(context, status),
              ),
              _InfoChip(
                label: request.repoTarget,
                background: MockPalette.panelSoft,
                foreground: MockPalette.text,
                border: MockPalette.border,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.diffSummary,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          if ((request.note ?? '').isNotEmpty) Text(request.note!),
          const SizedBox(height: 10),
          Text(
            'Submitted by ${_userHandle(requester)} · ${_relativeTime(request.createdAt)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if ((request.reviewNote ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Review note: ${request.reviewNote!}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (managerActions &&
                  status == MockSoftwareChangeRequestStatus.proposed)
                ElevatedButton(
                  onPressed: onMoveToReview,
                  child: const Text('Start Review'),
                ),
              if (managerActions &&
                  status == MockSoftwareChangeRequestStatus.underReview)
                ElevatedButton(onPressed: onMerge, child: const Text('Merge')),
              if (managerActions &&
                  status == MockSoftwareChangeRequestStatus.underReview)
                OutlinedButton(
                  onPressed: onRequestChanges,
                  child: const Text('Request Changes'),
                ),
              if (managerActions &&
                  status == MockSoftwareChangeRequestStatus.changesRequested)
                ElevatedButton(
                  onPressed: onMoveToReview,
                  child: const Text('Re-open Review'),
                ),
              if (managerActions &&
                  status != MockSoftwareChangeRequestStatus.merged &&
                  status != MockSoftwareChangeRequestStatus.rejected)
                OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
              TextButton.icon(
                onPressed: () => onOpenProfile(requester),
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Open Requester'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _TransferVisualTone { requested, incoming, outgoing }

class _FoundationRequestCard extends StatelessWidget {
  const _FoundationRequestCard({
    required this.repository,
    required this.request,
    required this.currentProject,
    required this.onOpenProject,
    required this.onOpenAsset,
    required this.onOpenProfile,
    this.onConfirmDispatch,
    this.onConfirmReceipt,
    this.managerActions = false,
  });

  final MockRepository repository;
  final MockFoundationRequest request;
  final MockProject currentProject;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockFoundationAsset asset) onOpenAsset;
  final void Function(MockUser user) onOpenProfile;
  final VoidCallback? onConfirmDispatch;
  final VoidCallback? onConfirmReceipt;
  final bool managerActions;

  @override
  Widget build(BuildContext context) {
    final asset = repository.foundationAssetById(request.assetId)!;
    final requester = repository.userById(request.requesterId)!;
    final project = request.projectId == null
        ? null
        : repository.projectById(request.projectId!);
    final assignedProject = request.assignedProjectId == null
        ? repository.stewardProjectForAsset(asset)
        : repository.projectById(request.assignedProjectId!);
    final tone = _transferVisualToneForRequest(
      repository: repository,
      currentProject: currentProject,
      request: request,
    );
    final statusLabel = _effectiveFoundationRequestStatusLabel(
      repository: repository,
      request: request,
    );
    final status = statusLabel.toLowerCase();
    final dispatchBlockedByAcquisition =
        request.dispatchBlockedByAcquisition &&
        project != null &&
        !repository.acquisitionReadyForProject(project.id);
    final canConfirmReceipt =
        managerActions &&
        project?.id == currentProject.id &&
        !status.contains('received') &&
        (status.contains('dispatch') || status.contains('ready'));
    final canConfirmDispatch =
        managerActions &&
        !canConfirmReceipt &&
        assignedProject?.id == currentProject.id &&
        !status.contains('received') &&
        !status.contains('dispatch') &&
        !status.contains('ready for pickup') &&
        !dispatchBlockedByAcquisition;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: request.scopeLabel,
                background: MockPalette.panelSoft,
                foreground: MockPalette.text,
                border: MockPalette.border,
              ),
              _InfoChip(
                label: _transferVisualToneLabel(tone),
                background: _transferVisualToneBackground(context, tone),
                foreground: _transferVisualToneForeground(context, tone),
              ),
              _InfoChip(
                label: statusLabel,
                background: _foundationStatusBackground(context, statusLabel),
                foreground: _foundationStatusForeground(context, statusLabel),
              ),
              _InfoChip(
                label: request.needByLabel,
                background: MockPalette.panelSoft,
                foreground: MockPalette.text,
                border: MockPalette.border,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(asset.name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(request.note),
          const SizedBox(height: 10),
          Text(
            'Requested by ${_userHandle(requester)} · ${asset.locationLabel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (project != null) ...[
            const SizedBox(height: 6),
            Text(
              'Receiving project: ${project.title}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (assignedProject != null) ...[
            const SizedBox(height: 6),
            Text(
              'Steward project: ${assignedProject.title}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (dispatchBlockedByAcquisition) ...[
            const SizedBox(height: 8),
            Text(
              'Dispatch stays locked until ${project.title} reaches its acquisition goal.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (canConfirmDispatch)
                ElevatedButton(
                  onPressed: onConfirmDispatch,
                  child: const Text('Confirm & Dispatch'),
                ),
              if (canConfirmReceipt)
                ElevatedButton(
                  onPressed: onConfirmReceipt,
                  child: const Text('Confirm Receipt'),
                ),
              OutlinedButton.icon(
                onPressed: () => onOpenProfile(requester),
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Open Requester'),
              ),
              TextButton.icon(
                onPressed: () => onOpenAsset(asset),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Open Asset'),
              ),
              if (project != null)
                TextButton.icon(
                  onPressed: () => onOpenProject(project),
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('Open Project'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

_TransferVisualTone _transferVisualToneForRequest({
  required MockRepository repository,
  required MockProject currentProject,
  required MockFoundationRequest request,
}) {
  final status = _effectiveFoundationRequestStatusLabel(
    repository: repository,
    request: request,
  ).toLowerCase();
  final isReceivingProject = request.projectId == currentProject.id;
  final isStewardProject = request.assignedProjectId == currentProject.id;

  if (isReceivingProject) {
    if (status.contains('dispatch') ||
        status.contains('ready') ||
        status.contains('received') ||
        status.contains('scheduled')) {
      return _TransferVisualTone.incoming;
    }
    return _TransferVisualTone.requested;
  }
  if (isStewardProject) {
    return _TransferVisualTone.outgoing;
  }
  return _TransferVisualTone.requested;
}

String _effectiveFoundationRequestStatusLabel({
  required MockRepository repository,
  required MockFoundationRequest request,
}) {
  if (!request.dispatchBlockedByAcquisition || request.projectId == null) {
    return request.statusLabel;
  }
  if (!repository.acquisitionReadyForProject(request.projectId!)) {
    return 'Requested · waiting on acquisition';
  }
  if (request.statusLabel.toLowerCase().contains('requested') ||
      request.statusLabel.toLowerCase().contains('acquisition')) {
    return 'Requested';
  }
  return request.statusLabel;
}

String _landManagementRequestStatusLabel(
  MockLandManagementRequestStatus status,
) {
  switch (status) {
    case MockLandManagementRequestStatus.pending:
      return 'Pending';
    case MockLandManagementRequestStatus.accepted:
      return 'Accepted';
    case MockLandManagementRequestStatus.refused:
      return 'Refused';
  }
}

Color _landManagementStatusBackground(
  BuildContext context,
  MockLandManagementRequestStatus status,
) {
  switch (status) {
    case MockLandManagementRequestStatus.pending:
      return _isDarkTheme(context)
          ? const Color(0xFF3A301D)
          : const Color(0xFFFFF1DB);
    case MockLandManagementRequestStatus.accepted:
      return _isDarkTheme(context)
          ? const Color(0xFF203728)
          : const Color(0xFFDFF1E5);
    case MockLandManagementRequestStatus.refused:
      return _isDarkTheme(context)
          ? const Color(0xFF3B2323)
          : const Color(0xFFFDE2E2);
  }
}

Color _landManagementStatusForeground(
  BuildContext context,
  MockLandManagementRequestStatus status,
) {
  switch (status) {
    case MockLandManagementRequestStatus.pending:
      return _isDarkTheme(context)
          ? _serviceAccent(context)
          : const Color(0xFFB45309);
    case MockLandManagementRequestStatus.accepted:
      return _isDarkTheme(context)
          ? _communityAccent(context)
          : const Color(0xFF0F3F20);
    case MockLandManagementRequestStatus.refused:
      return _isDarkTheme(context)
          ? const Color(0xFFFFB4B4)
          : const Color(0xFF9F1239);
  }
}

String _softwareChangeRequestStatusLabel(
  MockSoftwareChangeRequestStatus status,
) {
  switch (status) {
    case MockSoftwareChangeRequestStatus.proposed:
      return 'Proposed';
    case MockSoftwareChangeRequestStatus.underReview:
      return 'Under Review';
    case MockSoftwareChangeRequestStatus.changesRequested:
      return 'Changes Requested';
    case MockSoftwareChangeRequestStatus.merged:
      return 'Merged';
    case MockSoftwareChangeRequestStatus.rejected:
      return 'Rejected';
  }
}

Color _softwareChangeStatusBackground(
  BuildContext context,
  MockSoftwareChangeRequestStatus status,
) {
  switch (status) {
    case MockSoftwareChangeRequestStatus.proposed:
      return _isDarkTheme(context)
          ? const Color(0xFF203447)
          : const Color(0xFFE1EFFA);
    case MockSoftwareChangeRequestStatus.underReview:
      return _isDarkTheme(context)
          ? const Color(0xFF3A301D)
          : const Color(0xFFFFF1DB);
    case MockSoftwareChangeRequestStatus.changesRequested:
      return _isDarkTheme(context)
          ? const Color(0xFF47311F)
          : const Color(0xFFFFE8D0);
    case MockSoftwareChangeRequestStatus.merged:
      return _isDarkTheme(context)
          ? const Color(0xFF203728)
          : const Color(0xFFDFF1E5);
    case MockSoftwareChangeRequestStatus.rejected:
      return _isDarkTheme(context)
          ? const Color(0xFF3B2323)
          : const Color(0xFFFDE2E2);
  }
}

Color _softwareChangeStatusForeground(
  BuildContext context,
  MockSoftwareChangeRequestStatus status,
) {
  switch (status) {
    case MockSoftwareChangeRequestStatus.proposed:
      return _isDarkTheme(context)
          ? const Color(0xFFA9CBFF)
          : const Color(0xFF16406D);
    case MockSoftwareChangeRequestStatus.underReview:
      return _isDarkTheme(context)
          ? _serviceAccent(context)
          : const Color(0xFFB45309);
    case MockSoftwareChangeRequestStatus.changesRequested:
      return _isDarkTheme(context)
          ? const Color(0xFFF1C389)
          : const Color(0xFF9A4A16);
    case MockSoftwareChangeRequestStatus.merged:
      return _isDarkTheme(context)
          ? _communityAccent(context)
          : const Color(0xFF0F3F20);
    case MockSoftwareChangeRequestStatus.rejected:
      return _isDarkTheme(context)
          ? const Color(0xFFFFB4B4)
          : const Color(0xFF9F1239);
  }
}

String _transferVisualToneLabel(_TransferVisualTone tone) {
  switch (tone) {
    case _TransferVisualTone.requested:
      return 'Requested';
    case _TransferVisualTone.incoming:
      return 'Incoming';
    case _TransferVisualTone.outgoing:
      return 'Outgoing';
  }
}

Color _transferVisualToneBackground(
  BuildContext context,
  _TransferVisualTone tone,
) {
  switch (tone) {
    case _TransferVisualTone.requested:
      return _isDarkTheme(context)
          ? const Color(0xFF3A301D)
          : const Color(0xFFFFF1DB);
    case _TransferVisualTone.incoming:
      return _isDarkTheme(context)
          ? const Color(0xFF203728)
          : const Color(0xFFDFF1E5);
    case _TransferVisualTone.outgoing:
      return _isDarkTheme(context)
          ? const Color(0xFF3B2323)
          : const Color(0xFFFDE2E2);
  }
}

Color _transferVisualToneForeground(
  BuildContext context,
  _TransferVisualTone tone,
) {
  switch (tone) {
    case _TransferVisualTone.requested:
      return _isDarkTheme(context)
          ? _serviceAccent(context)
          : const Color(0xFFB45309);
    case _TransferVisualTone.incoming:
      return _isDarkTheme(context)
          ? _communityAccent(context)
          : const Color(0xFF0F3F20);
    case _TransferVisualTone.outgoing:
      return _isDarkTheme(context)
          ? const Color(0xFFFFB4B4)
          : const Color(0xFF9F1239);
  }
}

Color _foundationStatusBackground(BuildContext context, String label) {
  final value = label.toLowerCase();
  if (value.contains('ready')) {
    return _isDarkTheme(context)
        ? const Color(0xFF203728)
        : const Color(0xFFDFF1E5);
  }
  if (value.contains('review') ||
      value.contains('pending') ||
      value.contains('requested') ||
      value.contains('acquisition')) {
    return _isDarkTheme(context)
        ? const Color(0xFF3A301D)
        : const Color(0xFFFFF1DB);
  }
  return _isDarkTheme(context)
      ? const Color(0xFF1C3140)
      : const Color(0xFFE7F0FF);
}

Color _foundationStatusForeground(BuildContext context, String label) {
  final value = label.toLowerCase();
  if (value.contains('ready')) {
    return _isDarkTheme(context)
        ? _communityAccent(context)
        : const Color(0xFF0F3F20);
  }
  if (value.contains('review') ||
      value.contains('pending') ||
      value.contains('requested') ||
      value.contains('acquisition')) {
    return _isDarkTheme(context)
        ? _serviceAccent(context)
        : const Color(0xFFB45309);
  }
  return _isDarkTheme(context)
      ? _threadAccent(context)
      : const Color(0xFF2563EB);
}

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

enum _SettingsPageTab { appearance, profile, node, feed }

String _settingsPageTabLabel(_SettingsPageTab value) {
  switch (value) {
    case _SettingsPageTab.appearance:
      return 'Appearance';
    case _SettingsPageTab.profile:
      return 'Profile';
    case _SettingsPageTab.node:
      return 'Node';
    case _SettingsPageTab.feed:
      return 'Feed';
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({
    required this.repository,
    required this.currentUser,
    required this.currentAvatarLabel,
    required this.sharePublicCommentsInPersonal,
    required this.leftRail,
    required this.themeModeListenable,
    required this.accentListenable,
    required this.fontListenable,
    required this.nodeMode,
    required this.showLocation,
    required this.publicAcknowledgement,
    required this.onUsernameChanged,
    required this.onLocationChanged,
    required this.onBioChanged,
    required this.onNodeModeChanged,
    required this.onShowLocationChanged,
    required this.onPublicAcknowledgementChanged,
    required this.onAvatarLabelChanged,
    required this.onSharePublicCommentsInPersonalChanged,
    required this.onOpenProfile,
    required this.topNav,
    required this.onOpenProject,
    required this.onOpenPlan,
    required this.onOpenEvent,
  });

  final MockRepository repository;
  final MockUser currentUser;
  final String? currentAvatarLabel;
  final bool sharePublicCommentsInPersonal;
  final Widget leftRail;
  final ValueNotifier<bool> themeModeListenable;
  final ValueNotifier<MockAccentKind> accentListenable;
  final ValueNotifier<MockFontKind> fontListenable;
  final String nodeMode;
  final bool showLocation;
  final bool publicAcknowledgement;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onBioChanged;
  final ValueChanged<String> onNodeModeChanged;
  final ValueChanged<bool> onShowLocationChanged;
  final ValueChanged<bool> onPublicAcknowledgementChanged;
  final ValueChanged<String?> onAvatarLabelChanged;
  final ValueChanged<bool> onSharePublicCommentsInPersonalChanged;
  final VoidCallback onOpenProfile;
  final Widget topNav;
  final void Function(MockProject project, {MockProjectTab initialTab})
  onOpenProject;
  final void Function(MockPlan plan) onOpenPlan;
  final void Function(MockProject project, MockEvent event) onOpenEvent;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  _SettingsPageTab selectedTab = _SettingsPageTab.appearance;
  late String? _localAvatarLabel;
  late bool _localShowLocation;
  late bool _localPublicAcknowledgement;
  late bool _localSharePublicCommentsInPersonal;
  late String _localNodeMode;

  @override
  void initState() {
    super.initState();
    _localAvatarLabel = widget.currentAvatarLabel;
    _localShowLocation = widget.showLocation;
    _localPublicAcknowledgement = widget.publicAcknowledgement;
    _localSharePublicCommentsInPersonal = widget.sharePublicCommentsInPersonal;
    _localNodeMode = widget.nodeMode;
  }

  @override
  Widget build(BuildContext context) {
    final previewUser = MockUser(
      id: widget.currentUser.id,
      username: widget.currentUser.username,
      name: widget.currentUser.name,
      location: widget.currentUser.location,
      bio: widget.currentUser.bio,
      avatarLabel: _localAvatarLabel,
    );

    return _DetailShell(
      repository: widget.repository,
      topNav: widget.topNav,
      leftRail: widget.leftRail,
      title: 'Settings',
      subtitle:
          'Appearance, profile, node, and feed controls stay grouped here without pretending any real backend control exists yet.',
      onOpenProject: widget.onOpenProject,
      onOpenPlan: widget.onOpenPlan,
      onOpenEvent: widget.onOpenEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final value in _SettingsPageTab.values)
                  _PageTabChip(
                    label: _settingsPageTabLabel(value),
                    selected: selectedTab == value,
                    onSelected: () => setState(() => selectedTab = value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (selectedTab == _SettingsPageTab.appearance)
            ValueListenableBuilder<bool>(
              valueListenable: widget.themeModeListenable,
              builder: (context, isDarkMode, _) {
                return ValueListenableBuilder<MockAccentKind>(
                  valueListenable: widget.accentListenable,
                  builder: (context, accentKind, _) {
                    return ValueListenableBuilder<MockFontKind>(
                      valueListenable: widget.fontListenable,
                      builder: (context, fontKind, _) {
                        return _SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appearance',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Dark shell mode'),
                                subtitle: Text(
                                  isDarkMode
                                      ? 'Dark mode keeps the shell charcoal-grey, subtitles muted, and body copy bright while the accent drives shell highlights.'
                                      : 'Light mode keeps the shell neutral grey, body copy black, and the accent limited to shell highlights.',
                                ),
                                value: isDarkMode,
                                onChanged: (value) =>
                                    widget.themeModeListenable.value = value,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Accent',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Choose the colour used for major shell titles, active navigation, and toolbar highlights.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final item in MockAccentKind.values)
                                    _AccentChoiceCard(
                                      label: mockAccentLabel(item),
                                      tone: accentThemeForMode(
                                        item,
                                        isDarkMode: isDarkMode,
                                      ),
                                      active: item == accentKind,
                                      onTap: () =>
                                          widget.accentListenable.value = item,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Font',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pick from ten UI fonts. Inter is the default, and each option previews itself directly in the menu.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 280,
                                child: DropdownButtonFormField<MockFontKind>(
                                  initialValue: fontKind,
                                  decoration: const InputDecoration(
                                    labelText: 'Interface font',
                                  ),
                                  items: [
                                    for (final item in MockFontKind.values)
                                      DropdownMenuItem<MockFontKind>(
                                        value: item,
                                        child: Text(
                                          mockFontLabel(item),
                                          style: GoogleFonts.getFont(
                                            mockFontLabel(item),
                                            textStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                          ),
                                        ),
                                      ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      widget.fontListenable.value = value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            )
          else if (selectedTab == _SettingsPageTab.profile) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserAvatar(previewUser, radius: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile picture',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose a mock avatar preset for your profile surface.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final value in const <String?>[
                                  null,
                                  '🌿',
                                  '🛠',
                                  '📦',
                                  '🚲',
                                  '🧵',
                                ])
                                  _PageTabChip(
                                    label: value ?? 'Initials',
                                    selected: _localAvatarLabel == value,
                                    onSelected: () {
                                      setState(() => _localAvatarLabel = value);
                                      widget.onAvatarLabelChanged(value);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: widget.currentUser.username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: widget.onUsernameChanged,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: widget.currentUser.location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    onChanged: widget.onLocationChanged,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: widget.currentUser.bio,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    onChanged: widget.onBioChanged,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show approximate location on profile'),
                    value: _localShowLocation,
                    onChanged: (value) {
                      setState(() => _localShowLocation = value);
                      widget.onShowLocationChanged(value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Public contributor acknowledgement'),
                    value: _localPublicAcknowledgement,
                    onChanged: (value) {
                      setState(() => _localPublicAcknowledgement = value);
                      widget.onPublicAcknowledgementChanged(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton(
                        onPressed: widget.onOpenProfile,
                        child: const Text('Open My Profile'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (selectedTab == _SettingsPageTab.node) ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Node', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _localNodeMode,
                    decoration: const InputDecoration(
                      labelText: 'Current mock mode',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'full', child: Text('Full')),
                      DropdownMenuItem(value: 'gossip', child: Text('Gossip')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _localNodeMode = value);
                        widget.onNodeModeChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current mock mode is ${_capitalize(_localNodeMode)}. This changes UI state only and does not affect any real local node.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: _MetaTable(
                title: 'Diagnostics Snapshot',
                rows: const [
                  ('Sync freshness', 'Healthy'),
                  ('Peers visible', '6'),
                  ('Last local contact', '2m ago'),
                ],
              ),
            ),
          ] else ...[
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Feed', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Let public comments appear in followers\' Personal feeds',
                    ),
                    subtitle: const Text(
                      'Turning this off hides the Show In Personal action and clears your existing shared public-comment cards from Personal.',
                    ),
                    value: _localSharePublicCommentsInPersonal,
                    onChanged: (value) {
                      setState(
                        () => _localSharePublicCommentsInPersonal = value,
                      );
                      widget.onSharePublicCommentsInPersonalChanged(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (children.isEmpty)
            const Text('No matches in this group.')
          else
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index < children.length - 1) const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.title,
    required this.body,
    required this.meta,
    this.onTap,
  });

  final String title;
  final String body;
  final String meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _appSurfaceSoft(
          context,
        ).withValues(alpha: _isDarkTheme(context) ? 0.42 : 0.52),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body),
          const SizedBox(height: 8),
          Text(meta, style: Theme.of(context).textTheme.labelSmall),
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
        borderRadius: BorderRadius.circular(4),
        hoverColor: _rowHoverOverlay(context),
        child: row,
      ),
    );
  }
}

class _PeopleHeaderRow extends StatelessWidget {
  const _PeopleHeaderRow({
    required this.title,
    required this.actions,
    required this.description,
    this.note,
  });

  final String title;
  final Widget actions;
  final String description;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Text(description, style: Theme.of(context).textTheme.bodyLarge),
        if (note != null) ...[
          const SizedBox(height: 12),
          Text(note!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
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

bool _isAssetModeProject(MockProject project) =>
    project.isCollectiveAssetProject || project.assetRequestPolicy != null;

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

List<MockAssetStockItem> _orderedInventoryItems(
  Iterable<MockAssetStockItem> items,
) => [
  ...items.where((item) => item.isSiteAsset),
  ...items.where((item) => !item.isSiteAsset),
];

bool _productionInventoryAvailable(
  MockProject project,
  MockRepository repository,
) {
  if (project.type != MockProjectType.production ||
      project.inventoryItems.isEmpty) {
    return false;
  }

  switch (project.stage) {
    case MockProjectStage.proposal:
    case MockProjectStage.planning:
    case MockProjectStage.cancelled:
      return false;
    case MockProjectStage.funding:
      final approvedProduction = repository
          .plansForProject(project.id, MockPlanKind.production)
          .any((item) => item.approved);
      final approvedDistribution = repository
          .plansForProject(project.id, MockPlanKind.distribution)
          .any((item) => item.approved);
      return approvedProduction && approvedDistribution;
    case MockProjectStage.ongoing:
    case MockProjectStage.completed:
      return true;
  }
}

List<MockProjectTab> _projectTabsFor(
  MockProject project, {
  required String currentUserId,
  required MockRepository repository,
}) {
  return [
    MockProjectTab.overview,
    MockProjectTab.inventory,
    MockProjectTab.discussion,
    MockProjectTab.updates,
    MockProjectTab.tasks,
    MockProjectTab.plans,
    MockProjectTab.fund,
    MockProjectTab.events,
    MockProjectTab.history,
    MockProjectTab.managers,
    MockProjectTab.requests,
  ];
}

String _projectTabLabel(MockProjectTab value) {
  switch (value) {
    case MockProjectTab.overview:
      return 'Overview';
    case MockProjectTab.inventory:
      return 'Inventory';
    case MockProjectTab.discussion:
      return 'Discussion';
    case MockProjectTab.updates:
      return 'Updates';
    case MockProjectTab.tasks:
      return 'Tasks';
    case MockProjectTab.plans:
      return 'Plans';
    case MockProjectTab.fund:
      return 'Acquisition';
    case MockProjectTab.events:
      return 'Activity';
    case MockProjectTab.history:
      return 'History';
    case MockProjectTab.managers:
      return 'Managers';
    case MockProjectTab.requests:
      return 'Requests';
  }
}

String _planKindLabel(MockPlanKind value) {
  switch (value) {
    case MockPlanKind.production:
      return 'Production Plan';
    case MockPlanKind.distribution:
      return 'Distribution Plan';
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
