part of '../main.dart';

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
