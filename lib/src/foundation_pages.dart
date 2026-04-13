part of '../main.dart';

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
