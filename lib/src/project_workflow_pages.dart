part of '../main.dart';

bool _isAssetModeProject(MockProject project) =>
    project.isCollectiveAssetProject || project.assetRequestPolicy != null;

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

class _ProjectPage extends StatefulWidget {
  const _ProjectPage({
    required this.repository,
    required this.currentUser,
    required this.sharePublicCommentsInPersonal,
    required this.topNav,
    required this.leftRail,
    required this.project,
    required this.initialTab,
    this.initialEventId,
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
  final String? initialEventId;
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
  String? _selectedEventId;
  String? _selectedCommentId;
  String? _acquisitionProjectId;
  String? _planDraftProjectId;
  String _draftNeedAssetId = '';
  String _draftLandAssetId = '';
  String _draftExistingLandManagementProjectId = '';
  bool _isPlanComposerOpen = false;
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
    _selectedEventId = widget.initialEventId;
    _selectedCommentId = widget.repository.takePendingProjectCommentTarget(
      widget.project.id,
    );
    selectedTab = _selectedUpdateId != null
        ? MockProjectTab.updates
        : _selectedEventId != null
        ? MockProjectTab.events
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

  void _openActivityDetail(String eventId) {
    setState(() {
      selectedTab = MockProjectTab.events;
      _selectedEventId = eventId;
    });
  }

  void _closeActivityDetail() {
    setState(() => _selectedEventId = null);
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
              ? '${assetRequests.length} visible - manager actions enabled'
              : '${assetRequests.length} visible - manager actions required',
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
            : '${project.events.first.title} - ${project.events.first.timeLabel}',
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
                  '${_money(project.fund!.raised)} of ${_money(project.fund!.goal)} - ${project.fund!.deadlineLabel}',
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
                        '${building.kindLabel} - ${widget.repository.foundationAssetsForBuilding(building.id).length} asset records - ${building.summary}',
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
                        '${asset.groupLabel} - ${asset.availabilityLabel} - ${asset.locationLabel}',
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
                                '${building.kindLabel} - ${building.summary}',
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
                        '${_userHandle(widget.repository.userById(update.authorId))} - ${_relativeTime(update.time)} - ${widget.repository.commentsForUpdate(update.id).length} comments',
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
              if (isMember) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(
                      () => _isPlanComposerOpen = !_isPlanComposerOpen,
                    ),
                    icon: Icon(
                      _isPlanComposerOpen
                          ? Icons.close_rounded
                          : Icons.add_rounded,
                    ),
                    label: Text(
                      _isPlanComposerOpen ? 'Hide Plan Form' : 'Plan',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isMember && _isPlanComposerOpen) ...[
          const SizedBox(height: 16),
          _buildPlanComposer(
            project: project,
            isAssetProject: isAssetProject,
            isServiceProject: isServiceProject,
            distributionUnlocked: approvedProduction,
          ),
        ],
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
                            '${_draftPlanAssetNeeds[index].label} - ${_draftPlanAssetNeeds[index].quantityLabel}',
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
                            '${_draftPlanCostLines[index].label} - ${_money(_draftPlanCostLines[index].cost)}',
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
                      _isPlanComposerOpen = false;
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
                    '${entry.categoryLabel} - ${actorLabelFor(entry)} - ${_relativeTime(entry.time)}',
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
                '${_money(fund.raised)} of ${_money(fund.goal)} - ${fund.deadlineLabel}',
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
    final selectedEvent = _selectedEventId == null
        ? null
        : project.events
              .where((item) => item.id == _selectedEventId)
              .cast<MockEvent?>()
              .firstWhere((item) => item != null, orElse: () => null);

    if (selectedEvent != null) {
      final comments = selectedEvent.discussion;
      final author = widget.repository.userById(
        selectedEvent.creatorId ?? widget.currentUser.id,
      );
      final goingCount =
          selectedEvent.going +
          ((widget.rsvpEvents[selectedEvent.id] ?? false) ? 1 : 0);
      final lastTouched =
          selectedEvent.lastActivity ?? selectedEvent.createdAt ?? prototypeNow;

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
                      onPressed: _closeActivityDetail,
                      child: const Text('All Activity'),
                    ),
                    const Spacer(),
                    Text(
                      _relativeTime(lastTouched),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  selectedEvent.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(selectedEvent.description),
                const SizedBox(height: 16),
                _MetaTable(
                  rows: [
                    ('Time', selectedEvent.timeLabel),
                    ('Location', selectedEvent.location),
                    ('Host', _userHandle(author)),
                    ('Going', '$goingCount'),
                    if (selectedEvent.outcome.trim().isNotEmpty)
                      ('Outcome', selectedEvent.outcome),
                  ],
                ),
                if (selectedEvent.rolesNeeded.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Roles Needed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final role in selectedEvent.rolesNeeded) ...[
                    Text('- $role'),
                    const SizedBox(height: 6),
                  ],
                ],
                if (selectedEvent.materials.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Materials',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (final material in selectedEvent.materials) ...[
                    Text('- $material'),
                    const SizedBox(height: 6),
                  ],
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _refresh(() => widget.onToggleRsvp(selectedEvent.id)),
                      child: Text(
                        (widget.rsvpEvents[selectedEvent.id] ?? false)
                            ? 'Going'
                            : 'RSVP',
                      ),
                    ),
                    if (selectedEvent.rolesNeeded.isNotEmpty)
                      _InfoChip(
                        label:
                            '${selectedEvent.rolesNeeded.length} labor roles',
                        background: MockPalette.panelSoft,
                        foreground: MockPalette.text,
                        border: MockPalette.border,
                      ),
                    if (selectedEvent.materials.isNotEmpty)
                      _InfoChip(
                        label: '${selectedEvent.materials.length} materials',
                        background: MockPalette.panelSoft,
                        foreground: MockPalette.text,
                        border: MockPalette.border,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (selectedEvent.updates.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These notes stay attached to this activity instead of opening a separate surface.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  for (final update in selectedEvent.updates) ...[
                    _SearchRow(
                      title: update.title,
                      body: update.body,
                      meta:
                          '${_userHandle(widget.repository.userById(update.authorId))} - ${_relativeTime(update.time)}',
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
                  'Activity Discussion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _MentionComposerField(
                  repository: widget.repository,
                  hintText: 'Reply to this activity...',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Activity comments stay inside the project context in this mock.',
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
                  const Text('No activity discussion yet.')
                else
                  for (final comment in comments) ...[
                    _CommentNode(
                      repository: widget.repository,
                      comment: comment,
                      currentUserId: widget.currentUser.id,
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
                onTap: () => _openActivityDetail(event.id),
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
                                Text('${event.timeLabel} - ${event.location}'),
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
                      '${_userHandle(author)} - ${_relativeTime(thread.lastActivity)}',
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
                        '${plan.closesLabel} - ${plan.threshold}',
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
                      title: '${need.label} - ${need.quantityLabel}',
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
                    Text('- $item'),
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
                      meta: '${request.statusLabel} - ${request.needByLabel}',
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
                          '${_landManagementRequestStatusLabel(request.status)} - ${request.action == MockLandPlanAction.purchase ? 'Land purchase' : 'Land attachment'}',
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
