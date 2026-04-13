part of '../main.dart';

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
