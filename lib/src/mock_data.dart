enum MockProjectType { production, service }

enum MockProjectStage {
  proposal,
  planning,
  funding,
  ongoing,
  completed,
  cancelled,
}

enum MockServiceKind { storage, landManagement }

enum MockGovernanceProjectKind { software, collectiveFunds }

enum MockLandPlanAction { purchase, attachExisting }

enum MockLandManagementSelection { existingService, createNewService }

enum MockLandManagementRequestStatus { pending, accepted, refused }

enum MockSoftwareChangeRequestStatus {
  proposed,
  underReview,
  changesRequested,
  merged,
  rejected,
}

enum MockAssetRequestability { both, personalOnly, projectOnly, unavailable }

enum MockFeedScope { home, mine, local }

enum MockFeedFilter { all, projects, threads, events }

enum MockFeedSort { latest, votes, comments }

enum MockProjectTab {
  overview,
  inventory,
  discussion,
  updates,
  tasks,
  plans,
  fund,
  events,
  history,
  managers,
  requests,
}

enum MockPlanKind { production, distribution }

enum MockCreateKind { project, thread, event, community, channel }

enum MockFeedEntryKind { project, thread, event }

enum MockCommentShareSourceKind { project, thread }

enum MockPersonalTimelineEntryKind { post, sharedComment, event }

const String mockCurrentUserId = 'anika-shaw';
const String mockLocalDistrict = 'Downtown District';
final DateTime prototypeNow = DateTime.parse('2026-04-02T18:00:00Z');

class MockUser {
  const MockUser({
    required this.id,
    required this.username,
    required this.name,
    required this.location,
    required this.bio,
    this.avatarLabel,
  });

  final String id;
  final String username;
  final String name;
  final String location;
  final String bio;
  final String? avatarLabel;
}

class MockChannel {
  const MockChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.memberIds,
    required this.moderatorSeats,
  });

  final String id;
  final String name;
  final String description;
  final List<String> memberIds;
  final List<MockGovernanceSeat> moderatorSeats;
}

class MockCommunity {
  const MockCommunity({
    required this.id,
    required this.name,
    required this.openness,
    required this.description,
    required this.memberIds,
    required this.linkedProjectIds,
    required this.discussionThreadIds,
    required this.moderatorSeats,
    this.membershipRequests = const [],
  });

  final String id;
  final String name;
  final String openness;
  final String description;
  final List<String> memberIds;
  final List<String> linkedProjectIds;
  final List<String> discussionThreadIds;
  final List<MockGovernanceSeat> moderatorSeats;
  final List<MockGovernanceSeat> membershipRequests;
}

class MockComment {
  const MockComment({
    required this.id,
    required this.authorId,
    required this.body,
    required this.time,
    required this.score,
    this.replies = const [],
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime time;
  final int score;
  final List<MockComment> replies;

  MockComment copyWith({
    String? id,
    String? authorId,
    String? body,
    DateTime? time,
    int? score,
    List<MockComment>? replies,
  }) {
    return MockComment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      time: time ?? this.time,
      score: score ?? this.score,
      replies: replies ?? this.replies,
    );
  }
}

class MockDirectConversation {
  const MockDirectConversation({
    required this.id,
    required this.participantIds,
    required this.lastActivity,
    this.unreadCount = 0,
  });

  final String id;
  final List<String> participantIds;
  final DateTime lastActivity;
  final int unreadCount;

  MockDirectConversation copyWith({
    String? id,
    List<String>? participantIds,
    DateTime? lastActivity,
    int? unreadCount,
  }) {
    return MockDirectConversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class MockDirectMessage {
  const MockDirectMessage({
    required this.id,
    required this.authorId,
    required this.body,
    required this.time,
    this.reactions = const {},
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime time;
  final Map<String, int> reactions;

  MockDirectMessage copyWith({
    String? id,
    String? authorId,
    String? body,
    DateTime? time,
    Map<String, int>? reactions,
  }) {
    return MockDirectMessage(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      time: time ?? this.time,
      reactions: reactions ?? this.reactions,
    );
  }
}

class MockUpdate {
  const MockUpdate({
    required this.id,
    required this.authorId,
    required this.title,
    required this.body,
    required this.time,
  });

  final String id;
  final String authorId;
  final String title;
  final String body;
  final DateTime time;

  MockUpdate copyWith({
    String? id,
    String? authorId,
    String? title,
    String? body,
    DateTime? time,
  }) {
    return MockUpdate(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
    );
  }
}

class MockEvent {
  const MockEvent({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.location,
    required this.going,
    required this.description,
    required this.rolesNeeded,
    required this.materials,
    required this.outcome,
    this.managerIds = const [],
    this.discussion = const [],
    this.updates = const [],
    this.creatorId,
    this.channelIds = const [],
    this.communityIds = const [],
    this.invitedUserIds = const [],
    this.isPrivate = false,
    this.createdAt,
    this.lastActivity,
  });

  final String id;
  final String title;
  final String timeLabel;
  final String location;
  final int going;
  final String description;
  final List<String> rolesNeeded;
  final List<String> materials;
  final String outcome;
  final List<String> managerIds;
  final List<MockComment> discussion;
  final List<MockUpdate> updates;
  final String? creatorId;
  final List<String> channelIds;
  final List<String> communityIds;
  final List<String> invitedUserIds;
  final bool isPrivate;
  final DateTime? createdAt;
  final DateTime? lastActivity;

  MockEvent copyWith({
    String? id,
    String? title,
    String? timeLabel,
    String? location,
    int? going,
    String? description,
    List<String>? rolesNeeded,
    List<String>? materials,
    String? outcome,
    List<String>? managerIds,
    List<MockComment>? discussion,
    List<MockUpdate>? updates,
    String? creatorId,
    List<String>? channelIds,
    List<String>? communityIds,
    List<String>? invitedUserIds,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? lastActivity,
  }) {
    return MockEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      timeLabel: timeLabel ?? this.timeLabel,
      location: location ?? this.location,
      going: going ?? this.going,
      description: description ?? this.description,
      rolesNeeded: rolesNeeded ?? this.rolesNeeded,
      materials: materials ?? this.materials,
      outcome: outcome ?? this.outcome,
      managerIds: managerIds ?? this.managerIds,
      discussion: discussion ?? this.discussion,
      updates: updates ?? this.updates,
      creatorId: creatorId ?? this.creatorId,
      channelIds: channelIds ?? this.channelIds,
      communityIds: communityIds ?? this.communityIds,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}

class MockGovernanceSeat {
  const MockGovernanceSeat({
    required this.userId,
    required this.approveCount,
    required this.rejectCount,
  });

  final String userId;
  final int approveCount;
  final int rejectCount;

  MockGovernanceSeat copyWith({
    String? userId,
    int? approveCount,
    int? rejectCount,
  }) {
    return MockGovernanceSeat(
      userId: userId ?? this.userId,
      approveCount: approveCount ?? this.approveCount,
      rejectCount: rejectCount ?? this.rejectCount,
    );
  }
}

class MockTaskCheckpoint {
  const MockTaskCheckpoint({required this.label, this.done = false});

  final String label;
  final bool done;

  MockTaskCheckpoint copyWith({String? label, bool? done}) {
    return MockTaskCheckpoint(
      label: label ?? this.label,
      done: done ?? this.done,
    );
  }
}

class MockTask {
  const MockTask({
    required this.id,
    required this.title,
    required this.status,
    this.checkpoints = const [],
  });

  final String id;
  final String title;
  final String status;
  final List<MockTaskCheckpoint> checkpoints;

  MockTask copyWith({
    String? id,
    String? title,
    String? status,
    List<MockTaskCheckpoint>? checkpoints,
  }) {
    return MockTask(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      checkpoints: checkpoints ?? this.checkpoints,
    );
  }
}

class MockFundItem {
  const MockFundItem({required this.label, required this.cost});

  final String label;
  final int cost;

  MockFundItem copyWith({String? label, int? cost}) {
    return MockFundItem(label: label ?? this.label, cost: cost ?? this.cost);
  }
}

class MockFund {
  const MockFund({
    required this.title,
    required this.raised,
    required this.goal,
    required this.deadlineLabel,
    required this.contributorCount,
    required this.purchaseItems,
  });

  final String title;
  final int raised;
  final int goal;
  final String deadlineLabel;
  final int contributorCount;
  final List<MockFundItem> purchaseItems;

  MockFund copyWith({
    String? title,
    int? raised,
    int? goal,
    String? deadlineLabel,
    int? contributorCount,
    List<MockFundItem>? purchaseItems,
  }) {
    return MockFund(
      title: title ?? this.title,
      raised: raised ?? this.raised,
      goal: goal ?? this.goal,
      deadlineLabel: deadlineLabel ?? this.deadlineLabel,
      contributorCount: contributorCount ?? this.contributorCount,
      purchaseItems: purchaseItems ?? this.purchaseItems,
    );
  }
}

class MockProjectHistoryEntry {
  const MockProjectHistoryEntry({
    required this.id,
    required this.projectId,
    required this.categoryLabel,
    required this.title,
    required this.body,
    required this.time,
    this.actorId,
    this.actorLabel,
    this.assetId,
    this.requestId,
  });

  final String id;
  final String projectId;
  final String categoryLabel;
  final String title;
  final String body;
  final DateTime time;
  final String? actorId;
  final String? actorLabel;
  final String? assetId;
  final String? requestId;
}

class MockAssetHistoryEntry {
  const MockAssetHistoryEntry({
    required this.id,
    required this.assetId,
    required this.categoryLabel,
    required this.title,
    required this.body,
    required this.time,
    required this.locationLabel,
    this.actorId,
    this.actorLabel,
    this.projectId,
    this.requestId,
  });

  final String id;
  final String assetId;
  final String categoryLabel;
  final String title;
  final String body;
  final DateTime time;
  final String locationLabel;
  final String? actorId;
  final String? actorLabel;
  final String? projectId;
  final String? requestId;
}

class MockProject {
  const MockProject({
    required this.id,
    required this.title,
    required this.type,
    required this.stage,
    required this.authorId,
    required this.managerIds,
    required this.managerSeats,
    required this.memberIds,
    required this.channelIds,
    required this.communityIds,
    required this.locationLabel,
    required this.locationDistrict,
    required this.summary,
    required this.body,
    required this.demandCount,
    required this.awarenessCount,
    required this.comments,
    required this.createdAt,
    required this.lastActivity,
    required this.updates,
    required this.events,
    required this.tasks,
    required this.linkedProjectIds,
    required this.productionPlanIds,
    required this.distributionPlanIds,
    this.fund,
    this.availability,
    this.serviceKind,
    this.serviceMode,
    this.serviceCadence,
    this.assetRequestPolicy,
    this.inventoryItems = const [],
    this.isCollectiveAssetProject = false,
    this.governanceKind,
  });

  final String id;
  final String title;
  final MockProjectType type;
  final MockProjectStage stage;
  final String authorId;
  final List<String> managerIds;
  final List<MockGovernanceSeat> managerSeats;
  final List<String> memberIds;
  final List<String> channelIds;
  final List<String> communityIds;
  final String locationLabel;
  final String locationDistrict;
  final String summary;
  final String body;
  final int demandCount;
  final int awarenessCount;
  final int comments;
  final DateTime createdAt;
  final DateTime lastActivity;
  final List<MockUpdate> updates;
  final List<MockEvent> events;
  final List<MockTask> tasks;
  final List<String> linkedProjectIds;
  final List<String> productionPlanIds;
  final List<String> distributionPlanIds;
  final MockFund? fund;
  final String? availability;
  final MockServiceKind? serviceKind;
  final String? serviceMode;
  final String? serviceCadence;
  final String? assetRequestPolicy;
  final List<MockAssetStockItem> inventoryItems;
  final bool isCollectiveAssetProject;
  final MockGovernanceProjectKind? governanceKind;

  MockProject copyWith({
    String? id,
    String? title,
    MockProjectType? type,
    MockProjectStage? stage,
    String? authorId,
    List<String>? managerIds,
    List<MockGovernanceSeat>? managerSeats,
    List<String>? memberIds,
    List<String>? channelIds,
    List<String>? communityIds,
    String? locationLabel,
    String? locationDistrict,
    String? summary,
    String? body,
    int? demandCount,
    int? awarenessCount,
    int? comments,
    DateTime? createdAt,
    DateTime? lastActivity,
    List<MockUpdate>? updates,
    List<MockEvent>? events,
    List<MockTask>? tasks,
    List<String>? linkedProjectIds,
    List<String>? productionPlanIds,
    List<String>? distributionPlanIds,
    MockFund? fund,
    bool clearFund = false,
    String? availability,
    MockServiceKind? serviceKind,
    String? serviceMode,
    String? serviceCadence,
    String? assetRequestPolicy,
    List<MockAssetStockItem>? inventoryItems,
    bool? isCollectiveAssetProject,
    MockGovernanceProjectKind? governanceKind,
  }) {
    return MockProject(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      stage: stage ?? this.stage,
      authorId: authorId ?? this.authorId,
      managerIds: managerIds ?? this.managerIds,
      managerSeats: managerSeats ?? this.managerSeats,
      memberIds: memberIds ?? this.memberIds,
      channelIds: channelIds ?? this.channelIds,
      communityIds: communityIds ?? this.communityIds,
      locationLabel: locationLabel ?? this.locationLabel,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      demandCount: demandCount ?? this.demandCount,
      awarenessCount: awarenessCount ?? this.awarenessCount,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      updates: updates ?? this.updates,
      events: events ?? this.events,
      tasks: tasks ?? this.tasks,
      linkedProjectIds: linkedProjectIds ?? this.linkedProjectIds,
      productionPlanIds: productionPlanIds ?? this.productionPlanIds,
      distributionPlanIds: distributionPlanIds ?? this.distributionPlanIds,
      fund: clearFund ? null : (fund ?? this.fund),
      availability: availability ?? this.availability,
      serviceKind: serviceKind ?? this.serviceKind,
      serviceMode: serviceMode ?? this.serviceMode,
      serviceCadence: serviceCadence ?? this.serviceCadence,
      assetRequestPolicy: assetRequestPolicy ?? this.assetRequestPolicy,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      isCollectiveAssetProject:
          isCollectiveAssetProject ?? this.isCollectiveAssetProject,
      governanceKind: governanceKind ?? this.governanceKind,
    );
  }
}

class MockThread {
  const MockThread({
    required this.id,
    required this.title,
    required this.authorId,
    required this.channelIds,
    required this.communityIds,
    required this.linkedThreadIds,
    required this.body,
    required this.awarenessCount,
    required this.replyCount,
    required this.createdAt,
    required this.lastActivity,
  });

  final String id;
  final String title;
  final String authorId;
  final List<String> channelIds;
  final List<String> communityIds;
  final List<String> linkedThreadIds;
  final String body;
  final int awarenessCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime lastActivity;
}

class MockPlanAssetNeed {
  const MockPlanAssetNeed({
    required this.label,
    required this.quantityLabel,
    this.linkedAssetId,
    this.note,
    this.estimatedCost,
  });

  final String label;
  final String quantityLabel;
  final String? linkedAssetId;
  final String? note;
  final int? estimatedCost;
}

class MockPlanCostLine {
  const MockPlanCostLine({required this.label, required this.cost, this.note});

  final String label;
  final int cost;
  final String? note;
}

class MockPlan {
  const MockPlan({
    required this.id,
    required this.projectId,
    required this.kind,
    required this.title,
    required this.summary,
    required this.status,
    required this.approved,
    required this.version,
    required this.proposerId,
    required this.yes,
    required this.no,
    required this.abstain,
    required this.threshold,
    required this.closesLabel,
    required this.createdAt,
    required this.body,
    required this.discussion,
    this.checklist = const [],
    this.estimatedExecutionLabel,
    this.assetNeeds = const [],
    this.costLines = const [],
    this.landRouting,
  });

  final String id;
  final String projectId;
  final MockPlanKind kind;
  final String title;
  final String summary;
  final String status;
  final bool approved;
  final String version;
  final String proposerId;
  final int yes;
  final int no;
  final int abstain;
  final String threshold;
  final String closesLabel;
  final DateTime createdAt;
  final String body;
  final List<String> checklist;
  final List<MockComment> discussion;
  final String? estimatedExecutionLabel;
  final List<MockPlanAssetNeed> assetNeeds;
  final List<MockPlanCostLine> costLines;
  final MockPlanLandRouting? landRouting;

  MockPlan copyWith({
    String? id,
    String? projectId,
    MockPlanKind? kind,
    String? title,
    String? summary,
    String? status,
    bool? approved,
    String? version,
    String? proposerId,
    int? yes,
    int? no,
    int? abstain,
    String? threshold,
    String? closesLabel,
    DateTime? createdAt,
    String? body,
    List<String>? checklist,
    List<MockComment>? discussion,
    String? estimatedExecutionLabel,
    List<MockPlanAssetNeed>? assetNeeds,
    List<MockPlanCostLine>? costLines,
    MockPlanLandRouting? landRouting,
  }) {
    return MockPlan(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      approved: approved ?? this.approved,
      version: version ?? this.version,
      proposerId: proposerId ?? this.proposerId,
      yes: yes ?? this.yes,
      no: no ?? this.no,
      abstain: abstain ?? this.abstain,
      threshold: threshold ?? this.threshold,
      closesLabel: closesLabel ?? this.closesLabel,
      createdAt: createdAt ?? this.createdAt,
      body: body ?? this.body,
      checklist: checklist ?? this.checklist,
      discussion: discussion ?? this.discussion,
      estimatedExecutionLabel:
          estimatedExecutionLabel ?? this.estimatedExecutionLabel,
      assetNeeds: assetNeeds ?? this.assetNeeds,
      costLines: costLines ?? this.costLines,
      landRouting: landRouting ?? this.landRouting,
    );
  }
}

class MockPlanLandRouting {
  const MockPlanLandRouting({
    required this.action,
    required this.managementSelection,
    this.landAssetId,
    this.existingProjectId,
    this.newServiceTitle,
    this.newServiceSummary,
    this.statusLabel,
    this.requestId,
    this.resolvedProjectId,
  });

  final MockLandPlanAction action;
  final MockLandManagementSelection managementSelection;
  final String? landAssetId;
  final String? existingProjectId;
  final String? newServiceTitle;
  final String? newServiceSummary;
  final String? statusLabel;
  final String? requestId;
  final String? resolvedProjectId;

  MockPlanLandRouting copyWith({
    MockLandPlanAction? action,
    MockLandManagementSelection? managementSelection,
    String? landAssetId,
    String? existingProjectId,
    String? newServiceTitle,
    String? newServiceSummary,
    String? statusLabel,
    String? requestId,
    String? resolvedProjectId,
  }) {
    return MockPlanLandRouting(
      action: action ?? this.action,
      managementSelection: managementSelection ?? this.managementSelection,
      landAssetId: landAssetId ?? this.landAssetId,
      existingProjectId: existingProjectId ?? this.existingProjectId,
      newServiceTitle: newServiceTitle ?? this.newServiceTitle,
      newServiceSummary: newServiceSummary ?? this.newServiceSummary,
      statusLabel: statusLabel ?? this.statusLabel,
      requestId: requestId ?? this.requestId,
      resolvedProjectId: resolvedProjectId ?? this.resolvedProjectId,
    );
  }
}

class MockNotificationItem {
  const MockNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.targetKind,
    required this.targetId,
    this.targetProjectTab,
    this.targetUpdateId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime time;
  final String targetKind;
  final String targetId;
  final MockProjectTab? targetProjectTab;
  final String? targetUpdateId;
}

class MockFeedEntry {
  const MockFeedEntry.project({required this.id, required this.lastActivity})
    : kind = MockFeedEntryKind.project;
  const MockFeedEntry.thread({required this.id, required this.lastActivity})
    : kind = MockFeedEntryKind.thread;
  const MockFeedEntry.event({required this.id, required this.lastActivity})
    : kind = MockFeedEntryKind.event;

  final MockFeedEntryKind kind;
  final String id;
  final DateTime lastActivity;
}

class MockUpcomingEvent {
  const MockUpcomingEvent({required this.project, required this.event});

  final MockProject project;
  final MockEvent event;
}

class MockFoundationAsset {
  const MockFoundationAsset({
    required this.id,
    required this.name,
    required this.groupLabel,
    required this.kindLabel,
    required this.summary,
    required this.locationLabel,
    required this.zoneId,
    required this.availabilityLabel,
    required this.requestPolicyLabel,
    this.stewardProjectId,
    this.landAssetId,
    this.buildingId,
    this.linkedAssetIds = const [],
    this.linkedProjectIds = const [],
  });

  final String id;
  final String name;
  final String groupLabel;
  final String kindLabel;
  final String summary;
  final String locationLabel;
  final String zoneId;
  final String availabilityLabel;
  final String requestPolicyLabel;
  final String? stewardProjectId;
  final String? landAssetId;
  final String? buildingId;
  final List<String> linkedAssetIds;
  final List<String> linkedProjectIds;

  MockFoundationAsset copyWith({
    String? id,
    String? name,
    String? groupLabel,
    String? kindLabel,
    String? summary,
    String? locationLabel,
    String? zoneId,
    String? availabilityLabel,
    String? requestPolicyLabel,
    String? stewardProjectId,
    String? landAssetId,
    String? buildingId,
    List<String>? linkedAssetIds,
    List<String>? linkedProjectIds,
  }) {
    return MockFoundationAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      groupLabel: groupLabel ?? this.groupLabel,
      kindLabel: kindLabel ?? this.kindLabel,
      summary: summary ?? this.summary,
      locationLabel: locationLabel ?? this.locationLabel,
      zoneId: zoneId ?? this.zoneId,
      availabilityLabel: availabilityLabel ?? this.availabilityLabel,
      requestPolicyLabel: requestPolicyLabel ?? this.requestPolicyLabel,
      stewardProjectId: stewardProjectId ?? this.stewardProjectId,
      landAssetId: landAssetId ?? this.landAssetId,
      buildingId: buildingId ?? this.buildingId,
      linkedAssetIds: linkedAssetIds ?? this.linkedAssetIds,
      linkedProjectIds: linkedProjectIds ?? this.linkedProjectIds,
    );
  }
}

class MockFoundationRequest {
  const MockFoundationRequest({
    required this.id,
    required this.assetId,
    required this.requesterId,
    required this.scopeLabel,
    required this.statusLabel,
    required this.needByLabel,
    required this.note,
    this.assignedProjectId,
    this.projectId,
    this.createdByPlanId,
    this.dispatchBlockedByAcquisition = false,
  });

  final String id;
  final String assetId;
  final String requesterId;
  final String scopeLabel;
  final String statusLabel;
  final String needByLabel;
  final String note;
  final String? assignedProjectId;
  final String? projectId;
  final String? createdByPlanId;
  final bool dispatchBlockedByAcquisition;

  MockFoundationRequest copyWith({
    String? id,
    String? assetId,
    String? requesterId,
    String? scopeLabel,
    String? statusLabel,
    String? needByLabel,
    String? note,
    String? assignedProjectId,
    String? projectId,
    String? createdByPlanId,
    bool? dispatchBlockedByAcquisition,
  }) {
    return MockFoundationRequest(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      requesterId: requesterId ?? this.requesterId,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      statusLabel: statusLabel ?? this.statusLabel,
      needByLabel: needByLabel ?? this.needByLabel,
      note: note ?? this.note,
      assignedProjectId: assignedProjectId ?? this.assignedProjectId,
      projectId: projectId ?? this.projectId,
      createdByPlanId: createdByPlanId ?? this.createdByPlanId,
      dispatchBlockedByAcquisition:
          dispatchBlockedByAcquisition ?? this.dispatchBlockedByAcquisition,
    );
  }
}

class MockLandManagementRequest {
  const MockLandManagementRequest({
    required this.id,
    required this.planId,
    required this.requestingProjectId,
    required this.targetProjectId,
    required this.requesterId,
    required this.action,
    required this.status,
    required this.createdAt,
    this.landAssetId,
    this.note,
  });

  final String id;
  final String planId;
  final String requestingProjectId;
  final String targetProjectId;
  final String requesterId;
  final MockLandPlanAction action;
  final MockLandManagementRequestStatus status;
  final DateTime createdAt;
  final String? landAssetId;
  final String? note;

  MockLandManagementRequest copyWith({
    String? id,
    String? planId,
    String? requestingProjectId,
    String? targetProjectId,
    String? requesterId,
    MockLandPlanAction? action,
    MockLandManagementRequestStatus? status,
    DateTime? createdAt,
    String? landAssetId,
    String? note,
  }) {
    return MockLandManagementRequest(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      requestingProjectId: requestingProjectId ?? this.requestingProjectId,
      targetProjectId: targetProjectId ?? this.targetProjectId,
      requesterId: requesterId ?? this.requesterId,
      action: action ?? this.action,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      landAssetId: landAssetId ?? this.landAssetId,
      note: note ?? this.note,
    );
  }
}

class MockSoftwareChangeRequest {
  const MockSoftwareChangeRequest({
    required this.id,
    required this.projectId,
    required this.requesterId,
    required this.repoTarget,
    required this.diffSummary,
    required this.status,
    required this.createdAt,
    this.note,
    this.reviewNote,
  });

  final String id;
  final String projectId;
  final String requesterId;
  final String repoTarget;
  final String diffSummary;
  final MockSoftwareChangeRequestStatus status;
  final DateTime createdAt;
  final String? note;
  final String? reviewNote;

  MockSoftwareChangeRequest copyWith({
    String? id,
    String? projectId,
    String? requesterId,
    String? repoTarget,
    String? diffSummary,
    MockSoftwareChangeRequestStatus? status,
    DateTime? createdAt,
    String? note,
    String? reviewNote,
  }) {
    return MockSoftwareChangeRequest(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      requesterId: requesterId ?? this.requesterId,
      repoTarget: repoTarget ?? this.repoTarget,
      diffSummary: diffSummary ?? this.diffSummary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }
}

class MockFoundationZone {
  const MockFoundationZone({
    required this.id,
    required this.name,
    required this.locationLabel,
    required this.summary,
    required this.assetIds,
  });

  final String id;
  final String name;
  final String locationLabel;
  final String summary;
  final List<String> assetIds;
}

class MockStorageBuilding {
  const MockStorageBuilding({
    required this.id,
    required this.projectId,
    required this.landAssetId,
    required this.name,
    required this.kindLabel,
    required this.summary,
  });

  final String id;
  final String projectId;
  final String landAssetId;
  final String name;
  final String kindLabel;
  final String summary;
}

class MockAssetStockItem {
  const MockAssetStockItem({
    required this.name,
    required this.quantityLabel,
    required this.statusLabel,
    this.note,
    this.assetId,
    this.buildingId,
    this.isSiteAsset = false,
    this.requestability = MockAssetRequestability.both,
  });

  final String name;
  final String quantityLabel;
  final String statusLabel;
  final String? note;
  final String? assetId;
  final String? buildingId;
  final bool isSiteAsset;
  final MockAssetRequestability requestability;
}

class MockSearchResults {
  const MockSearchResults({
    required this.projects,
    required this.threads,
    required this.events,
    required this.channels,
    required this.communities,
    required this.users,
  });

  final List<MockProject> projects;
  final List<MockThread> threads;
  final List<MockEvent> events;
  final List<MockChannel> channels;
  final List<MockCommunity> communities;
  final List<MockUser> users;
}

class MockPersonalPost {
  const MockPersonalPost({
    required this.id,
    required this.authorId,
    required this.body,
    required this.createdAt,
    this.signalCount = 0,
    this.imageLabel,
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime createdAt;
  final int signalCount;
  final String? imageLabel;

  MockPersonalPost copyWith({
    String? id,
    String? authorId,
    String? body,
    DateTime? createdAt,
    int? signalCount,
    String? imageLabel,
  }) {
    return MockPersonalPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      signalCount: signalCount ?? this.signalCount,
      imageLabel: imageLabel ?? this.imageLabel,
    );
  }
}

class MockPersonalCommentShare {
  const MockPersonalCommentShare({
    required this.id,
    required this.authorId,
    required this.sourceKind,
    required this.sourceId,
    required this.commentId,
    required this.sharedAt,
    this.caption = '',
  });

  final String id;
  final String authorId;
  final MockCommentShareSourceKind sourceKind;
  final String sourceId;
  final String commentId;
  final DateTime sharedAt;
  final String caption;
}

class MockPersonalTimelineEntry {
  const MockPersonalTimelineEntry.post({
    required this.post,
    required this.lastActivity,
  }) : kind = MockPersonalTimelineEntryKind.post,
       share = null,
       event = null;

  const MockPersonalTimelineEntry.sharedComment({
    required this.share,
    required this.lastActivity,
  }) : kind = MockPersonalTimelineEntryKind.sharedComment,
       post = null,
       event = null;

  const MockPersonalTimelineEntry.event({
    required this.event,
    required this.lastActivity,
  }) : kind = MockPersonalTimelineEntryKind.event,
       post = null,
       share = null;

  final MockPersonalTimelineEntryKind kind;
  final DateTime lastActivity;
  final MockPersonalPost? post;
  final MockPersonalCommentShare? share;
  final MockEvent? event;
}

class MockRepository {
  MockRepository()
    : users = const [
        MockUser(
          id: 'anika-shaw',
          username: 'anika',
          name: 'Anika',
          location: 'Downtown District',
          bio:
              'Works across local growing, retrofit, and distribution work as a participating member and organizer.',
        ),
        MockUser(
          id: 'carlos-rivera',
          username: 'carlos',
          name: 'Carlos',
          location: 'South Rail Yard',
          bio:
              'Helps turn rough production ideas into repeatable build plans, site logistics, and handoff routines.',
        ),
        MockUser(
          id: 'mara-holt',
          username: 'mara',
          name: 'Mara',
          location: 'Riverside',
          bio:
              'Runs community repair nights and keeps the intake flow and follow-up work legible.',
        ),
        MockUser(
          id: 'devon-lee',
          username: 'devon',
          name: 'Devon',
          location: 'Warehouse Three',
          bio:
              'Builds out the shared tool library, storage readiness, and warehouse intake process.',
        ),
        MockUser(
          id: 'iya-ford',
          username: 'iya',
          name: 'Iya',
          location: 'North Commons',
          bio:
              'Focuses on queue rules, readiness confirmation, and fair distribution workflows.',
        ),
        MockUser(
          id: 'leo-park',
          username: 'leo',
          name: 'Leo',
          location: 'Market Corridor',
          bio:
              'Works across channels and communities to connect people to practical projects and public discussions.',
        ),
        MockUser(
          id: 'nina-patel',
          username: 'nina',
          name: 'Nina',
          location: 'West Garden',
          bio:
              'Focuses on seed saving, soil care, and the practical routines that keep small growing projects alive.',
        ),
        MockUser(
          id: 'omar-nguyen',
          username: 'omar',
          name: 'Omar',
          location: 'East Market',
          bio:
              'Tracks inventory movement, cargo-bike routing, and field logistics for shared equipment.',
        ),
        MockUser(
          id: 'rina-ortiz',
          username: 'rina',
          name: 'Rina',
          location: 'East Market',
          bio:
              'Works on retrofit buildouts, public-space upkeep, and land stewardship across the east side.',
        ),
        MockUser(
          id: 'joel-morris',
          username: 'joel',
          name: 'Joel',
          location: 'Warehouse District',
          bio:
              'Handles shelving builds, pickup windows, and the boring maintenance work that keeps spaces usable.',
        ),
        MockUser(
          id: 'sarah-kim',
          username: 'sarah',
          name: 'Sarah',
          location: 'Riverside',
          bio:
              'Helps with repair training, public documentation, and member-facing support across service projects.',
        ),
        MockUser(
          id: 'talia-brooks',
          username: 'talia',
          name: 'Talia',
          location: 'North Commons',
          bio:
              'Coordinates kitchen labor, packaging flow, and neighborhood check-ins tied to food distribution work.',
        ),
      ],
      channels = const [
        MockChannel(
          id: 'stewardship',
          name: 'Stewardship',
          description:
              'Public governance for platform software and collective-fund execution. All platform users can read and post threads here, while current moderators serve as the board.',
          memberIds: [
            'anika-shaw',
            'devon-lee',
            'leo-park',
            'carlos-rivera',
            'rina-ortiz',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 27,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 24,
              rejectCount: 4,
            ),
            MockGovernanceSeat(
              userId: 'leo-park',
              approveCount: 25,
              rejectCount: 4,
            ),
          ],
        ),
        MockChannel(
          id: 'food-agriculture',
          name: 'Food & Agriculture',
          description:
              'Growing, kitchens, food processing, and neighborhood supply chains.',
          memberIds: [
            'anika-shaw',
            'iya-ford',
            'leo-park',
            'nina-patel',
            'talia-brooks',
            'carlos-rivera',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 20,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'leo-park',
              approveCount: 22,
              rejectCount: 4,
            ),
            MockGovernanceSeat(
              userId: 'nina-patel',
              approveCount: 19,
              rejectCount: 3,
            ),
          ],
        ),
        MockChannel(
          id: 'mutual-aid',
          name: 'Mutual Aid',
          description:
              'Rapid local coordination for practical help, care work, and response.',
          memberIds: [
            'anika-shaw',
            'mara-holt',
            'leo-park',
            'omar-nguyen',
            'sarah-kim',
            'talia-brooks',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'mara-holt',
              approveCount: 18,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'omar-nguyen',
              approveCount: 17,
              rejectCount: 4,
            ),
          ],
        ),
        MockChannel(
          id: 'repair-maintenance',
          name: 'Repair & Maintenance',
          description:
              'Fixing, maintaining, and extending the life of shared tools and goods.',
          memberIds: [
            'mara-holt',
            'devon-lee',
            'carlos-rivera',
            'joel-morris',
            'sarah-kim',
            'anika-shaw',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'mara-holt',
              approveCount: 21,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 16,
              rejectCount: 4,
            ),
          ],
        ),
        MockChannel(
          id: 'housing-build',
          name: 'Housing & Build',
          description:
              'Construction, retrofit, insulation, and site preparation work.',
          memberIds: [
            'carlos-rivera',
            'devon-lee',
            'joel-morris',
            'rina-ortiz',
            'omar-nguyen',
            'anika-shaw',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 20,
              rejectCount: 5,
            ),
            MockGovernanceSeat(
              userId: 'rina-ortiz',
              approveCount: 18,
              rejectCount: 3,
            ),
          ],
        ),
        MockChannel(
          id: 'energy-retrofit',
          name: 'Energy & Retrofit',
          description:
              'Insulation, electrification, heat systems, and retrofit coordination.',
          memberIds: [
            'anika-shaw',
            'carlos-rivera',
            'rina-ortiz',
            'omar-nguyen',
            'joel-morris',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'rina-ortiz',
              approveCount: 17,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'omar-nguyen',
              approveCount: 15,
              rejectCount: 4,
            ),
          ],
        ),
      ],
      communities = const [
        MockCommunity(
          id: 'downtown-growers',
          name: 'Downtown Growers',
          openness: 'Open',
          description:
              'Gardeners, kitchen teams, and local coordinators connecting food work across three blocks.',
          memberIds: [
            'anika-shaw',
            'iya-ford',
            'leo-park',
            'nina-patel',
            'talia-brooks',
          ],
          linkedProjectIds: [
            'community-garden-network',
            'meal-kit-round',
            'shared-seed-bank',
          ],
          discussionThreadIds: [
            'thread-farmers-market',
            'thread-watering-rotation',
            'thread-seed-saving-shelf',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 19,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'leo-park',
              approveCount: 18,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'nina-patel',
              approveCount: 17,
              rejectCount: 3,
            ),
          ],
        ),
        MockCommunity(
          id: 'riverside-repair-club',
          name: 'Riverside Repair Club',
          openness: 'Closed',
          description:
              'Volunteer repair hosts sharing shift schedules, intake rules, and spare-parts coordination.',
          memberIds: [
            'mara-holt',
            'devon-lee',
            'carlos-rivera',
            'sarah-kim',
            'joel-morris',
          ],
          linkedProjectIds: ['repair-circle', 'cooperative-tool-library'],
          discussionThreadIds: [
            'thread-tool-return-reminder',
            'thread-repair-intake-signage',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'mara-holt',
              approveCount: 16,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 15,
              rejectCount: 5,
            ),
          ],
          membershipRequests: [
            MockGovernanceSeat(
              userId: 'omar-nguyen',
              approveCount: 6,
              rejectCount: 2,
            ),
          ],
        ),
        MockCommunity(
          id: 'east-market-retrofit-circle',
          name: 'East Market Retrofit Circle',
          openness: 'Closed',
          description:
              'Residents, builders, and coordinators working through retrofit, storage, and shared equipment questions on the east side.',
          memberIds: [
            'anika-shaw',
            'carlos-rivera',
            'rina-ortiz',
            'omar-nguyen',
            'joel-morris',
          ],
          linkedProjectIds: ['east-market-retrofit-pilot', 'cargo-bike-pool'],
          discussionThreadIds: [
            'thread-retrofit-scouting',
            'thread-insulation-tool-checklist',
          ],
          moderatorSeats: [
            MockGovernanceSeat(
              userId: 'rina-ortiz',
              approveCount: 14,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 13,
              rejectCount: 3,
            ),
          ],
          membershipRequests: [
            MockGovernanceSeat(
              userId: 'sarah-kim',
              approveCount: 5,
              rejectCount: 1,
            ),
            MockGovernanceSeat(
              userId: 'nina-patel',
              approveCount: 4,
              rejectCount: 2,
            ),
          ],
        ),
      ],
      projects = [
        MockProject(
          id: 'platform-network-maintenance',
          title: 'Platform And Network Maintenance',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'devon-lee',
          managerIds: const ['anika-shaw', 'devon-lee', 'leo-park'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 27,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 24,
              rejectCount: 4,
            ),
            MockGovernanceSeat(
              userId: 'leo-park',
              approveCount: 25,
              rejectCount: 4,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'devon-lee',
            'leo-park',
            'carlos-rivera',
            'sarah-kim',
          ],
          channelIds: const ['stewardship'],
          communityIds: const [],
          locationLabel: 'Platform-wide governance workspace',
          locationDistrict: 'Distributed',
          summary:
              'Ongoing maintenance of the platform and network software, including public change review and moderator-only merge authority.',
          body:
              'This stewardship-tagged service keeps platform releases, policy fixes, and infrastructure maintenance legible without pretending the mock app is a full code host. Anyone can propose changes here. Only the board can merge them.',
          demandCount: 31,
          awarenessCount: 92,
          comments: 16,
          createdAt: DateTime.parse('2026-03-12T12:00:00Z'),
          lastActivity: DateTime.parse('2026-04-02T16:20:00Z'),
          updates: [
            MockUpdate(
              id: 'u-pnm-1',
              authorId: 'devon-lee',
              title: 'Desktop sync triage lane published',
              body:
                  'The board agreed on a lighter review lane for UI and sync fixes so public requests do not disappear into ad hoc chats.',
              time: DateTime.parse('2026-04-02T14:40:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-pnm-1',
              title: 'Weekly release review',
              timeLabel: 'Apr 9, 3:00 PM',
              location: 'Stewardship channel call',
              going: 7,
              description:
                  'Review proposed software changes, move ready items into merge, and publish anything that needs more work before the next release window.',
              rolesNeeded: ['3 board reviewers', '1 release note editor'],
              materials: ['Open change-request list', 'Release checklist'],
              outcome:
                  'Leave with a clear set of merged, deferred, and changes-requested items for the public feed.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-pnm-1',
              title: 'Review offline compose draft changes',
              status: 'In progress',
            ),
            MockTask(
              id: 't-pnm-2',
              title: 'Publish sync health note for contributors',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const ['collective-funds-execution'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability:
              'Open public proposal queue with scheduled board review',
          serviceMode: 'Public software review and board-managed release flow',
          serviceCadence: 'Continuous review with weekly merge windows',
          governanceKind: MockGovernanceProjectKind.software,
        ),
        MockProject(
          id: 'collective-funds-execution',
          title: 'Collective Funds Execution',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'anika-shaw',
          managerIds: const ['anika-shaw', 'devon-lee', 'leo-park'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 27,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 24,
              rejectCount: 4,
            ),
            MockGovernanceSeat(
              userId: 'leo-park',
              approveCount: 25,
              rejectCount: 4,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'devon-lee',
            'leo-park',
            'iya-ford',
            'rina-ortiz',
          ],
          channelIds: const ['stewardship'],
          communityIds: const [],
          locationLabel: 'Platform-wide stewardship ledger',
          locationDistrict: 'Distributed',
          summary:
              'Board-managed execution of collective fund decisions once public approval has already happened elsewhere in the network.',
          body:
              'This project exists so stewardship keeps software governance separate from the practical work of paying invoices, releasing collectively approved funds, and publishing execution notes back into the public channel.',
          demandCount: 14,
          awarenessCount: 61,
          comments: 9,
          createdAt: DateTime.parse('2026-03-14T10:30:00Z'),
          lastActivity: DateTime.parse('2026-04-02T15:55:00Z'),
          updates: [
            MockUpdate(
              id: 'u-cfe-1',
              authorId: 'anika-shaw',
              title: 'Published April disbursement checklist',
              body:
                  'The current execution list now separates software hosting bills, approved reimbursements, and upcoming collective purchases into one public queue.',
              time: DateTime.parse('2026-04-02T13:50:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-cfe-1',
              title: 'Disbursement and invoice review',
              timeLabel: 'Apr 11, 2:00 PM',
              location: 'Stewardship channel call',
              going: 5,
              description:
                  'Confirm what has already been publicly approved, match invoices to the queue, and publish the next execution note.',
              rolesNeeded: ['2 board reviewers', '1 documentation lead'],
              materials: ['Approved purchase list', 'Invoice packet'],
              outcome:
                  'Keep fund execution legible without mixing it into the software review queue.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-cfe-1',
              title: 'Confirm current hosting invoice total',
              status: 'In progress',
            ),
          ],
          linkedProjectIds: const ['platform-network-maintenance'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Board-managed execution windows with public notes',
          serviceMode: 'Collective-fund execution and reporting',
          serviceCadence: 'Weekly public execution updates',
          governanceKind: MockGovernanceProjectKind.collectiveFunds,
        ),
        MockProject(
          id: 'community-garden-network',
          title: 'Community Garden Network',
          type: MockProjectType.production,
          stage: MockProjectStage.proposal,
          authorId: 'anika-shaw',
          managerIds: const ['anika-shaw', 'nina-patel', 'carlos-rivera'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 24,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'nina-patel',
              approveCount: 21,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 19,
              rejectCount: 5,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'carlos-rivera',
            'iya-ford',
            'leo-park',
            'nina-patel',
            'talia-brooks',
          ],
          channelIds: const ['food-agriculture', 'mutual-aid'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'Maple and 4th Lots, Downtown District, Riverbend',
          locationDistrict: 'Downtown District',
          summary:
              'Turn vacant lots into a linked neighborhood food-growing and pickup network.',
          body:
              'This project is mapping three small plots, shared watering capacity, and volunteer kitchen partners so the district can pilot a local growing network before the next planting season.',
          demandCount: 84,
          awarenessCount: 126,
          comments: 34,
          createdAt: DateTime.parse('2026-03-24T11:00:00Z'),
          lastActivity: DateTime.parse('2026-04-02T12:45:00Z'),
          updates: [
            MockUpdate(
              id: 'u-cgn-1',
              authorId: 'anika-shaw',
              title: 'Initial lot survey complete',
              body:
                  'Two vacant lots look immediately usable. The third needs water-line work before planning can proceed.',
              time: DateTime.parse('2026-04-02T09:00:00Z'),
            ),
            MockUpdate(
              id: 'u-cgn-2',
              authorId: 'anika-shaw',
              title: 'Kitchen partner conversations started',
              body:
                  'Three community kitchens are interested in receiving overflow produce if the pilot moves into planning.',
              time: DateTime.parse('2026-03-31T16:00:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-cgn-1',
              title: 'Block soil walk',
              timeLabel: 'Apr 5, 10:00 AM',
              location: 'Maple and 4th',
              going: 23,
              description:
                  'Walk the three pilot lots, inspect drainage and sun exposure, and record what would block the first shared planting round.',
              rolesNeeded: ['2 note-takers', '1 soil tester', '3 lot stewards'],
              materials: [
                'Printed lot maps',
                'Soil sample bags',
                'Phone camera coverage',
              ],
              outcome:
                  'Leave with a shared readiness list and a ranked order for which lot can move into planning first.',
            ),
            MockEvent(
              id: 'ev-cgn-2',
              title: 'Seed sourcing session',
              timeLabel: 'Apr 8, 6:30 PM',
              location: 'Neighborhood Library',
              going: 14,
              description:
                  'Compare seed sources, pricing, and likely planting mixes before the garden network commits to a first-round budget.',
              rolesNeeded: [
                '1 sourcing lead',
                '2 price check volunteers',
                '1 kitchen liaison',
              ],
              materials: [
                'Seed catalog shortlist',
                'Budget worksheet',
                'Projected crop demand notes',
              ],
              outcome:
                  'Produce a purchasing shortlist and identify which crops align with kitchen partner capacity.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-cgn-1',
              title: 'Confirm water access',
              status: 'In progress',
            ),
            MockTask(
              id: 't-cgn-2',
              title: 'Map likely pickup points',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const ['meal-kit-round'],
          productionPlanIds: const [
            'plan-garden-rotation',
            'plan-garden-bed-layout',
          ],
          distributionPlanIds: const [],
        ),
        MockProject(
          id: 'repair-circle',
          title: 'Neighborhood Repair Circle',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'mara-holt',
          managerIds: const ['mara-holt'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'mara-holt',
              approveCount: 47,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'mara-holt',
            'carlos-rivera',
            'leo-park',
            'sarah-kim',
          ],
          channelIds: const ['repair-maintenance', 'mutual-aid'],
          communityIds: const ['riverside-repair-club'],
          locationLabel: 'Riverside Hall, Riverside, Riverbend',
          locationDistrict: 'Riverside',
          summary:
              'A recurring service project for device, appliance, and tool repair nights.',
          body:
              'The repair circle keeps service coordination lightweight, but it is still part of the project family. This version focuses on recurring weekly intake, triage, and shared documentation for fixes that can be repeated elsewhere.',
          demandCount: 18,
          awarenessCount: 89,
          comments: 18,
          createdAt: DateTime.parse('2026-03-22T14:15:00Z'),
          lastActivity: DateTime.parse('2026-04-02T15:20:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rc-1',
              authorId: 'mara-holt',
              title: 'Intake checklist draft shared',
              body:
                  'We now have a first pass at intake categories so the weekly queue is easier to sort and route.',
              time: DateTime.parse('2026-04-01T18:10:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rc-1',
              title: 'Repair night shift',
              timeLabel: 'Apr 4, 7:00 PM',
              location: 'Riverside Hall',
              going: 17,
              description:
                  'Open intake, triage incoming items, and route each job to a quick fix, deeper repair queue, or parts lookup follow-up.',
              rolesNeeded: [
                '2 intake volunteers',
                '3 repair leads',
                '1 parts runner',
              ],
              materials: [
                'Repair intake forms',
                'Bench tool kits',
                'Common spare parts bins',
              ],
              outcome:
                  'Finish the evening with a visible queue summary and documented repeat fixes for the next session.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rc-1',
              title: 'Finalize triage categories',
              status: 'In progress',
            ),
            MockTask(
              id: 't-rc-2',
              title: 'Confirm volunteer shift rotation',
              status: 'Done',
            ),
          ],
          linkedProjectIds: const ['cooperative-tool-library'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Every Tuesday and Thursday · 6:00 PM to 9:00 PM',
          assetRequestPolicy:
              'Personal and project requests. Repair stewards approve intake-bay holds and bench access before each repair night.',
          serviceMode: 'Offer and request',
          serviceCadence: 'Scheduled weekly',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'Riverside Hall workshop site',
              quantityLabel: '1 shared workshop floor',
              statusLabel: 'Booked for weekly repair nights',
              note:
                  'The repair circle operates from a fixed collective site rather than lending the space out item by item.',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Intake benches',
              quantityLabel: '3 benches listed',
              statusLabel: '2 ready · 1 in active use',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Bench tool kits',
              quantityLabel: '5 kits listed',
              statusLabel: '4 ready · 1 being restocked',
            ),
            MockAssetStockItem(
              name: 'Common spare-parts bins',
              quantityLabel: '8 bins listed',
              statusLabel: '6 stocked · 2 low',
              requestability: MockAssetRequestability.projectOnly,
            ),
          ],
        ),
        MockProject(
          id: 'cooperative-tool-library',
          title: 'Cooperative Tool Library',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'devon-lee',
          managerIds: const ['devon-lee', 'joel-morris'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 20,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'joel-morris',
              approveCount: 17,
              rejectCount: 4,
            ),
          ],
          memberIds: const [
            'devon-lee',
            'joel-morris',
            'carlos-rivera',
            'sarah-kim',
          ],
          channelIds: const ['repair-maintenance', 'housing-build'],
          communityIds: const ['riverside-repair-club'],
          locationLabel: 'Warehouse Three, Warehouse District, Riverbend',
          locationDistrict: 'Warehouse District',
          summary:
              'A shared tool library project for borrowing, return flows, and neighborhood equipment access.',
          body:
              'This project now runs in library mode rather than a generic ongoing state. The operational focus is visible stock, approved borrowing rules, and a manager-reviewed request queue for personal and project access.',
          demandCount: 22,
          awarenessCount: 74,
          comments: 12,
          createdAt: DateTime.parse('2026-03-10T09:45:00Z'),
          lastActivity: DateTime.parse('2026-04-02T11:05:00Z'),
          updates: [
            MockUpdate(
              id: 'u-ctl-1',
              authorId: 'devon-lee',
              title: 'New pickup confirmation rule live',
              body:
                  'Borrowers now confirm readiness within 48 hours so scarce tools cycle more smoothly.',
              time: DateTime.parse('2026-04-02T08:30:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-ctl-1',
              title: 'Inventory review shift',
              timeLabel: 'Apr 6, 9:30 AM',
              location: 'Warehouse Three',
              going: 8,
              description:
                  'Check high-turnover tools, confirm return status, and relabel the most crowded shelving areas before the next loan wave.',
              rolesNeeded: [
                '2 inventory auditors',
                '1 shelf relabeling runner',
                '1 queue-status recorder',
              ],
              materials: [
                'Checkout ledger export',
                'Label printer',
                'Missing-item exception list',
              ],
              outcome:
                  'Update inventory accuracy, clear stale queue holds, and publish a cleaner ready-for-borrow list.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-ctl-1',
              title: 'Audit battery tool checkout history',
              status: 'To do',
            ),
            MockTask(
              id: 't-ctl-2',
              title: 'Label new shelving zones',
              status: 'Done',
            ),
          ],
          linkedProjectIds: const ['repair-circle'],
          productionPlanIds: const [],
          distributionPlanIds: const ['plan-library-queue'],
          serviceKind: MockServiceKind.storage,
          assetRequestPolicy:
              'Personal and project requests. Library managers approve or flag each request before pickup.',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'Warehouse Three site and loading bay',
              quantityLabel: '1 shared site',
              statusLabel: 'Open for stewarded pickup windows',
              note:
                  'The site itself anchors the library workflow and is not requestable as a separate item.',
              buildingId: 'warehouse-three-main',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Cordless drill kits',
              quantityLabel: '6 kits listed',
              statusLabel: '4 ready · 2 on loan',
              note: 'Each kit includes two batteries and one charger.',
              buildingId: 'warehouse-three-main',
            ),
            MockAssetStockItem(
              name: 'Moisture meters',
              quantityLabel: '3 meters listed',
              statusLabel: '2 ready · 1 due tomorrow',
              buildingId: 'warehouse-three-main',
            ),
            MockAssetStockItem(
              name: 'Insulation staplers',
              quantityLabel: '4 staplers listed',
              statusLabel: '3 ready · 1 under repair',
              buildingId: 'warehouse-three-main',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Extension reels',
              quantityLabel: '5 reels listed',
              statusLabel: 'All ready',
              buildingId: 'warehouse-three-main',
            ),
          ],
        ),
        MockProject(
          id: 'meal-kit-round',
          title: 'Neighborhood Meal Kit Round',
          type: MockProjectType.production,
          stage: MockProjectStage.funding,
          authorId: 'iya-ford',
          managerIds: const ['iya-ford', 'talia-brooks'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'iya-ford',
              approveCount: 24,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'talia-brooks',
              approveCount: 18,
              rejectCount: 4,
            ),
          ],
          memberIds: const [
            'iya-ford',
            'anika-shaw',
            'leo-park',
            'talia-brooks',
          ],
          channelIds: const ['food-agriculture', 'mutual-aid'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'North Commons Kitchen, North Commons, Riverbend',
          locationDistrict: 'North Commons',
          summary:
              'Pilot a short meal-kit production round with public demand, escrowed acquisition, and a visible waitlist.',
          body:
              'This project has moved past researching and planning. It now needs ingredients, packaging, and refrigeration support before the first short round can be packed and distributed.',
          demandCount: 142,
          awarenessCount: 173,
          comments: 27,
          createdAt: DateTime.parse('2026-03-14T13:20:00Z'),
          lastActivity: DateTime.parse('2026-04-02T16:10:00Z'),
          updates: [
            MockUpdate(
              id: 'u-mkr-1',
              authorId: 'iya-ford',
              title: 'Cold storage quote received',
              body:
                  'The team now has a firm quote for temporary cold storage, which closes the last major budget unknown.',
              time: DateTime.parse('2026-04-02T15:50:00Z'),
            ),
            MockUpdate(
              id: 'u-mkr-2',
              authorId: 'anika-shaw',
              title: 'Acquisition crossed 62 percent',
              body:
                  'Visibility was already high, but the last contributor round moved the escrow goal much closer to launch.',
              time: DateTime.parse('2026-04-01T12:00:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-mkr-1',
              title: 'Kitchen packing walkthrough',
              timeLabel: 'Apr 7, 5:00 PM',
              location: 'North Commons Kitchen',
              going: 12,
              description:
                  'Walk through the full packing line, confirm where each labor handoff happens, and test the cold-storage timing against the approved production plan.',
              rolesNeeded: [
                '2 packing leads',
                '1 cold-chain timer',
                '2 distribution checkers',
              ],
              materials: [
                'Packing line map',
                'Container count sheet',
                'Cold storage access log',
              ],
              outcome:
                  'Leave with an executable staffing chart and a final packing sequence ready for the first live run.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-mkr-1',
              title: 'Confirm final ingredient pricing',
              status: 'In progress',
              checkpoints: [
                MockTaskCheckpoint(label: 'Compare cooperative supplier sheet'),
                MockTaskCheckpoint(
                  label: 'Lock cold-chain surcharge',
                  done: true,
                ),
              ],
            ),
            MockTask(
              id: 't-mkr-2',
              title: 'Finalize first-round waitlist size',
              status: 'Done',
              checkpoints: [
                MockTaskCheckpoint(
                  label: 'Review neighborhood signups',
                  done: true,
                ),
                MockTaskCheckpoint(
                  label: 'Publish first-round cap',
                  done: true,
                ),
              ],
            ),
          ],
          linkedProjectIds: const ['community-garden-network'],
          productionPlanIds: const ['plan-meal-kit-production'],
          distributionPlanIds: const ['plan-meal-kit-distribution'],
          fund: const MockFund(
            title: 'Cold storage and starter ingredients',
            raised: 6200,
            goal: 10000,
            deadlineLabel: 'Apr 18',
            contributorCount: 39,
            purchaseItems: [
              MockFundItem(label: 'Cold storage rental', cost: 2800),
              MockFundItem(label: 'Starter ingredient stock', cost: 4700),
              MockFundItem(label: 'Reusable containers', cost: 2500),
            ],
          ),
        ),
        MockProject(
          id: 'east-market-retrofit-pilot',
          title: 'East Market Retrofit Pilot',
          type: MockProjectType.production,
          stage: MockProjectStage.planning,
          authorId: 'carlos-rivera',
          managerIds: const ['anika-shaw', 'carlos-rivera', 'rina-ortiz'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 18,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 18,
              rejectCount: 4,
            ),
            MockGovernanceSeat(
              userId: 'rina-ortiz',
              approveCount: 16,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'carlos-rivera',
            'rina-ortiz',
            'omar-nguyen',
            'joel-morris',
          ],
          channelIds: const ['energy-retrofit', 'housing-build'],
          communityIds: const ['east-market-retrofit-circle'],
          locationLabel: 'East Market Blocks 6-9, Riverbend',
          locationDistrict: 'East Market',
          summary:
              'Coordinate a first retrofit cluster with shared labor planning, insulation prep, and building-by-building sequencing.',
          body:
              'This pilot is testing whether the east side can coordinate retrofit work in block-sized clusters instead of isolated one-off jobs. The focus is on labor scheduling, site access, and shared material handling.',
          demandCount: 59,
          awarenessCount: 101,
          comments: 16,
          createdAt: DateTime.parse('2026-03-25T10:30:00Z'),
          lastActivity: DateTime.parse('2026-04-02T17:20:00Z'),
          updates: [
            MockUpdate(
              id: 'u-emr-1',
              authorId: 'carlos-rivera',
              title: 'Three-building survey pack drafted',
              body:
                  'We now have a single survey checklist that can be reused for each building in the first cluster.',
              time: DateTime.parse('2026-04-02T14:40:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-emr-1',
              title: 'Retrofit scouting walk',
              timeLabel: 'Apr 9, 4:30 PM',
              location: 'East Market Corridor',
              going: 11,
              description:
                  'Walk the first three buildings, confirm access constraints, and note which tasks can be batched across the cluster.',
              rolesNeeded: [
                '2 survey note-takers',
                '1 building access lead',
                '2 labor coordinators',
              ],
              materials: [
                'Survey packet',
                'Building access list',
                'Thermal photo checklist',
              ],
              outcome:
                  'Produce a first-pass sequence for insulation, sealing, and electrical prep across the pilot cluster.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-emr-1',
              title: 'Confirm access windows for all three buildings',
              status: 'In progress',
            ),
            MockTask(
              id: 't-emr-2',
              title: 'Group materials by building envelope type',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const ['community-garden-network'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
        ),
        MockProject(
          id: 'shared-seed-bank',
          title: 'Shared Seed Bank',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'nina-patel',
          managerIds: const ['nina-patel', 'leo-park'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'nina-patel',
              approveCount: 17,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'leo-park',
              approveCount: 15,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'nina-patel',
            'talia-brooks',
            'iya-ford',
          ],
          channelIds: const ['food-agriculture'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'West Garden Shed, Riverbend',
          locationDistrict: 'West Garden',
          summary:
              'Keep a shared seed library ready for neighborhood growing rounds, reserve stock, and learning kits.',
          body:
              'The seed bank now acts as a library-mode project. It keeps collectively held seed visible, rotates reserve stock, and lets people request packets personally or on behalf of another project without hiding the steward workflow.',
          demandCount: 27,
          awarenessCount: 64,
          comments: 11,
          createdAt: DateTime.parse('2026-03-28T09:20:00Z'),
          lastActivity: DateTime.parse('2026-04-02T10:10:00Z'),
          updates: [
            MockUpdate(
              id: 'u-ssb-1',
              authorId: 'nina-patel',
              title: 'Seed catalog categories drafted',
              body:
                  'The first pass splits the catalog into staple crops, quick greens, and seed-saving trials.',
              time: DateTime.parse('2026-04-01T10:45:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-ssb-1',
              title: 'Seed sorting session',
              timeLabel: 'Apr 10, 6:00 PM',
              location: 'West Garden Shed',
              going: 9,
              description:
                  'Sort existing stock, test labeling rules, and decide what should be treated as reserve seed versus project-ready seed.',
              rolesNeeded: [
                '2 catalog keepers',
                '2 labeling volunteers',
                '1 moisture-control check',
              ],
              materials: [
                'Seed envelopes',
                'Storage bin labels',
                'Spreadsheet printout',
              ],
              outcome:
                  'Leave with a first catalog structure and a storage routine the next growing round can rely on.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-ssb-1',
              title: 'Count current seed stock by crop group',
              status: 'In progress',
            ),
            MockTask(
              id: 't-ssb-2',
              title: 'Define reserve vs project-ready bins',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const ['community-garden-network'],
          productionPlanIds: const [],
          distributionPlanIds: const ['plan-seed-bank-circulation'],
          serviceKind: MockServiceKind.storage,
          assetRequestPolicy:
              'Personal and project requests. Seed stewards review packet holds and reserve-stock exceptions.',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'West Garden seed shed site',
              quantityLabel: '1 shed and lot',
              statusLabel: 'Active storage and sorting site',
              note:
                  'The site keeps reserve stock in one place and is not separately requestable.',
              buildingId: 'west-garden-shed',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Quick greens packets',
              quantityLabel: '36 packets listed',
              statusLabel: '28 ready · 8 reserved',
              buildingId: 'west-garden-shed',
            ),
            MockAssetStockItem(
              name: 'Staple crop reserve',
              quantityLabel: '24 reserve packets',
              statusLabel: 'Reserve only',
              note: 'Released only through an approved project request.',
              buildingId: 'west-garden-shed',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Learning-kit herb mix',
              quantityLabel: '18 kits listed',
              statusLabel: '14 ready · 4 pending refill',
              buildingId: 'west-garden-shed',
            ),
          ],
        ),
        MockProject(
          id: 'shared-sites-land-service',
          title: 'Shared Sites Land Service',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'carlos-rivera',
          managerIds: const ['carlos-rivera', 'sarah-kim'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 18,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'sarah-kim',
              approveCount: 16,
              rejectCount: 2,
            ),
          ],
          memberIds: const [
            'carlos-rivera',
            'sarah-kim',
            'devon-lee',
            'omar-nguyen',
          ],
          channelIds: const ['housing-build', 'repair-maintenance'],
          communityIds: const [],
          locationLabel: 'Warehouse District, East Market, and Riverside sites',
          locationDistrict: 'Multi-site',
          summary:
              'One land-management service keeping smaller shared sites, workshops, and logistics yards routed through an explicit management surface.',
          body:
              'This service keeps land-management separate from storage operations. It handles site-use acceptance, tied-to-land-asset routing, and maintenance coordination for the smaller logistics and workshop sites that do not need their own independent board channel.',
          demandCount: 11,
          awarenessCount: 36,
          comments: 4,
          createdAt: DateTime.parse('2026-03-18T09:00:00Z'),
          lastActivity: DateTime.parse('2026-04-02T14:10:00Z'),
          updates: [
            MockUpdate(
              id: 'u-ssls-1',
              authorId: 'carlos-rivera',
              title: 'Shared-site maintenance route published',
              body:
                  'Warehouse Three, Warehouse Seven, East Market Depot, the Riverside Workshop, and West Garden now all point to one explicit land-management service instead of relying on asset fallback rules.',
              time: DateTime.parse('2026-04-02T12:40:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-ssls-1',
              title: 'Shared-site routing review',
              timeLabel: 'Apr 12, 11:00 AM',
              location: 'Warehouse Three',
              going: 4,
              description:
                  'Review site-use requests, maintenance notes, and tied-to-land-asset issues across the smaller managed sites.',
              rolesNeeded: ['1 site-routing lead', '1 maintenance recorder'],
              materials: ['Site request queue', 'Maintenance route sheet'],
              outcome:
                  'Keep management acceptance and site routing explicit for every land asset in this service.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-ssls-1',
              title: 'Confirm workshop access notes for next week',
              status: 'In progress',
            ),
          ],
          linkedProjectIds: const [
            'cooperative-tool-library',
            'shared-seed-bank',
            'cargo-bike-pool',
            'central-resource-storage-facility',
            'repair-circle',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability:
              'Daily site-response windows across smaller shared sites',
          serviceKind: MockServiceKind.landManagement,
          serviceMode: 'Land management and site-use routing',
          serviceCadence: 'Continuous weekly service',
          assetRequestPolicy:
              'Tied-to-land-asset requests route here when no storage-service queue is the more precise operational surface.',
        ),
        MockProject(
          id: 'riverbend-land-stewards',
          title: 'Riverbend Land Stewards',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'rina-ortiz',
          managerIds: const ['rina-ortiz', 'anika-shaw'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'rina-ortiz',
              approveCount: 15,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 17,
              rejectCount: 2,
            ),
          ],
          memberIds: const [
            'rina-ortiz',
            'anika-shaw',
            'nina-patel',
            'talia-brooks',
          ],
          channelIds: const ['food-agriculture', 'housing-build'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'Maple and 4th, North Commons, and South Field',
          locationDistrict: 'Multi-site',
          summary:
              'One service project coordinating land stewardship across several collective food and kitchen sites.',
          body:
              'This steward team does not own every movable asset. It keeps the land bases legible, routes site usage, and anchors requests for assets that sit directly on those lands or their attached storage spaces.',
          demandCount: 12,
          awarenessCount: 52,
          comments: 7,
          createdAt: DateTime.parse('2026-03-16T09:40:00Z'),
          lastActivity: DateTime.parse('2026-04-02T15:10:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rls-1',
              authorId: 'rina-ortiz',
              title: 'Multi-site land stewardship queue is live',
              body:
                  'Maple and 4th, South Field, and North Commons now route site-use questions and land-linked asset requests through one visible steward service.',
              time: DateTime.parse('2026-04-02T14:20:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rls-1',
              title: 'Site stewardship coordination walk',
              timeLabel: 'Apr 13, 10:30 AM',
              location: 'Maple and 4th, then North Commons',
              going: 6,
              description:
                  'Walk the currently active land bases, confirm who is stewarding each physical constraint, and keep the request-routing rules aligned across sites.',
              rolesNeeded: [
                '1 route recorder',
                '2 site stewards',
                '1 maintenance note-taker',
              ],
              materials: [
                'Site routing sheet',
                'Constraint log',
                'Current request queue',
              ],
              outcome:
                  'Leave with one public list of site constraints and who is currently stewarding each land-linked request surface.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rls-1',
              title: 'Publish current land stewardship map',
              status: 'In progress',
            ),
          ],
          linkedProjectIds: const [
            'community-garden-network',
            'riverbend-collective-farm',
            'tuesday-thursday-community-kitchen',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Daily steward response windows across active sites',
          serviceKind: MockServiceKind.landManagement,
          serviceMode: 'Land stewardship and site-use routing',
          serviceCadence: 'Continuous weekly service',
          assetRequestPolicy:
              'Project requests route through linked land assets or attached storage spaces. The steward team approves site usage and land-anchored handoffs.',
        ),
        MockProject(
          id: 'riverbend-collective-farm',
          title: 'Riverbend Collective Farm',
          type: MockProjectType.production,
          stage: MockProjectStage.ongoing,
          authorId: 'anika-shaw',
          managerIds: const ['anika-shaw', 'talia-brooks'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 23,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'talia-brooks',
              approveCount: 19,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'talia-brooks',
            'iya-ford',
            'leo-park',
            'nina-patel',
          ],
          channelIds: const ['food-agriculture', 'mutual-aid'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'South Field Cooperative Farm, Riverbend',
          locationDistrict: 'South Field',
          summary:
              'Collective farm land has been purchased and the first planting lanes, irrigation runs, and shared work sheds are being set up.',
          body:
              'This farm is already in active setup. Irrigation runs are being laid, greenhouse frames are going up, and the first planting cycles are being organized around a continuing shared labor rhythm rather than a one-off build.',
          demandCount: 118,
          awarenessCount: 164,
          comments: 21,
          createdAt: DateTime.parse('2026-03-08T08:30:00Z'),
          lastActivity: DateTime.parse('2026-04-02T16:35:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rcf-1',
              authorId: 'anika-shaw',
              title: 'First irrigation loop marked out',
              body:
                  'The main irrigation line route is now staked so trenching and hose runs can happen in one coordinated shift.',
              time: DateTime.parse('2026-04-02T15:40:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rcf-1',
              title: 'Planting lane setup shift',
              timeLabel: 'Apr 8, 8:30 AM',
              location: 'South Field Cooperative Farm',
              going: 18,
              description:
                  'Set up the first planting lanes, check irrigation spacing, and assign the initial greenhouse-frame tasks before seedlings arrive.',
              rolesNeeded: [
                '3 bed layout leads',
                '2 irrigation runners',
                '4 general setup hands',
              ],
              materials: [
                'Line markers',
                'Irrigation hose reels',
                'Seedling table hardware',
              ],
              outcome:
                  'Finish the first shared field layout and publish the next setup cycle with realistic labor needs.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rcf-1',
              title: 'Install first irrigation trunk line',
              status: 'In progress',
            ),
            MockTask(
              id: 't-rcf-2',
              title: 'Assemble greenhouse starter tables',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const [
            'community-garden-network',
            'tuesday-thursday-community-kitchen',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          inventoryItems: const [
            MockAssetStockItem(
              name: 'South Field collective land',
              quantityLabel: '1 farm site',
              statusLabel: 'In active cultivation and setup',
              note:
                  'The land base stays visible here but is not requestable as a movable item.',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Compact field tractor',
              quantityLabel: '1 machine',
              statusLabel: 'Operational',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Irrigation reels',
              quantityLabel: '8 reels listed',
              statusLabel: '6 installed · 2 spare',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Greenhouse starter frames',
              quantityLabel: '3 frame sets',
              statusLabel: '2 assembled · 1 pending build',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Shared tool shed benches',
              quantityLabel: '4 benches',
              statusLabel: 'Installed',
              requestability: MockAssetRequestability.unavailable,
            ),
          ],
        ),
        MockProject(
          id: 'tuesday-thursday-community-kitchen',
          title: 'Tuesday And Thursday Community Kitchen',
          type: MockProjectType.production,
          stage: MockProjectStage.ongoing,
          authorId: 'iya-ford',
          managerIds: const ['iya-ford', 'anika-shaw'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'iya-ford',
              approveCount: 26,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'anika-shaw',
              approveCount: 21,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'iya-ford',
            'anika-shaw',
            'leo-park',
            'talia-brooks',
            'sarah-kim',
          ],
          channelIds: const ['food-agriculture', 'mutual-aid'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'North Commons Community Kitchen, Riverbend',
          locationDistrict: 'North Commons',
          summary:
              'A shared kitchen operation producing community meals every Tuesday and Thursday using collectively owned kitchen infrastructure.',
          body:
              'The kitchen is already operational and cycles through two meal days each week. What matters here is keeping the durable base visible: ranges, mixers, prep benches, carriers, and cold-hold equipment that were all bought through collective acquisition.',
          demandCount: 96,
          awarenessCount: 148,
          comments: 17,
          createdAt: DateTime.parse('2026-03-05T10:15:00Z'),
          lastActivity: DateTime.parse('2026-04-02T17:50:00Z'),
          updates: [
            MockUpdate(
              id: 'u-ttck-1',
              authorId: 'iya-ford',
              title: 'Tuesday meal line now uses the second prep table',
              body:
                  'The second prep table is finally in steady use, which cut the backup during chopping and packing by almost half.',
              time: DateTime.parse('2026-04-02T17:20:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-ttck-1',
              title: 'Thursday meal prep shift',
              timeLabel: 'Apr 9, 2:00 PM',
              location: 'North Commons Community Kitchen',
              going: 14,
              description:
                  'Prep ingredients, run the shared cook line, and stage insulated carriers before the Thursday meal handoff starts.',
              rolesNeeded: [
                '2 prep leads',
                '2 line cooks',
                '2 handoff coordinators',
              ],
              materials: [
                'Kitchen prep list',
                'Carrier labels',
                'Cold-hold bins',
              ],
              outcome:
                  'Finish the full Thursday meal cycle and publish any kitchen-equipment issues before the next Tuesday round.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-ttck-1',
              title: 'Replace one insulated carrier latch',
              status: 'In progress',
            ),
            MockTask(
              id: 't-ttck-2',
              title: 'Deep clean the backup stock-pot rack',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const [
            'riverbend-collective-farm',
            'central-resource-storage-facility',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Every Tuesday and Thursday · meal prep and handoff',
          serviceMode: 'Recurring meal production and pickup service',
          serviceCadence: 'Twice weekly',
          inventoryItems: const [
            MockAssetStockItem(
              name: 'North Commons kitchen site',
              quantityLabel: '1 kitchen site',
              statusLabel: 'In steady production use',
              note:
                  'The kitchen site anchors the operation and is not available as a requestable item.',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Six-burner range line',
              quantityLabel: '2 ranges',
              statusLabel: 'Operational',
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: '120L mixing bowl rig',
              quantityLabel: '1 mixer',
              statusLabel: 'Operational',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Insulated carrier stack',
              quantityLabel: '12 carriers',
              statusLabel: '10 ready · 2 under clean-down',
            ),
            MockAssetStockItem(
              name: 'Prep benches',
              quantityLabel: '5 benches',
              statusLabel: 'In daily use',
              requestability: MockAssetRequestability.unavailable,
            ),
          ],
        ),
        MockProject(
          id: 'central-resource-storage-facility',
          title: 'Central Resource Storage Facility',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'carlos-rivera',
          managerIds: const ['carlos-rivera', 'omar-nguyen'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 22,
              rejectCount: 4,
            ),
            MockGovernanceSeat(
              userId: 'omar-nguyen',
              approveCount: 18,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'carlos-rivera',
            'omar-nguyen',
            'joel-morris',
            'rina-ortiz',
          ],
          channelIds: const ['housing-build', 'mutual-aid'],
          communityIds: const ['east-market-retrofit-circle'],
          locationLabel: 'Warehouse Seven, East Market, Riverbend',
          locationDistrict: 'East Market',
          summary:
              'A large shared storage service holding food overflow, mechanical stock, industrial oils, lumber, and reusable materials for other projects.',
          body:
              'This facility has already been built and now operates as a storage service. It exists to hold collectively owned surplus and durable stock so other projects can request what they need without private side channels.',
          demandCount: 53,
          awarenessCount: 112,
          comments: 13,
          createdAt: DateTime.parse('2026-03-11T09:10:00Z'),
          lastActivity: DateTime.parse('2026-04-02T16:05:00Z'),
          updates: [
            MockUpdate(
              id: 'u-crsf-1',
              authorId: 'carlos-rivera',
              title: 'Cold shelf block and lumber bay both re-labeled',
              body:
                  'The storage map is simpler now, which should reduce misroutes between food overflow, lumber, and equipment stock.',
              time: DateTime.parse('2026-04-02T15:30:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-crsf-1',
              title: 'Storage audit and redistribution shift',
              timeLabel: 'Apr 10, 9:30 AM',
              location: 'Warehouse Seven',
              going: 9,
              description:
                  'Audit current storage lanes, clear stale holds, and prepare outgoing bundles for projects collecting reserved stock this week.',
              rolesNeeded: [
                '2 audit leads',
                '2 forklift spotters',
                '1 outgoing requests recorder',
              ],
              materials: [
                'Shelf ledger printout',
                'Pallet tags',
                'Cold-lane checklist',
              ],
              outcome:
                  'Finish the weekly storage reconciliation and publish what is ready for redistribution.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-crsf-1',
              title: 'Count lumber bay reserve stock',
              status: 'In progress',
            ),
            MockTask(
              id: 't-crsf-2',
              title: 'Replace one cold shelf relay',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const [
            'riverbend-collective-farm',
            'tuesday-thursday-community-kitchen',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const ['plan-central-storage-circulation'],
          serviceKind: MockServiceKind.storage,
          assetRequestPolicy:
              'Personal and project requests. Storage managers approve, flag, and schedule outgoing pickups.',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'Warehouse Seven site',
              quantityLabel: '1 warehouse site',
              statusLabel: 'Active storage and loading yard',
              note:
                  'The site itself is collectively held but not requestable as a separate item.',
              buildingId: 'warehouse-seven-main',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Cold shelf lanes',
              quantityLabel: '12 lanes',
              statusLabel: '8 occupied · 4 open',
              buildingId: 'warehouse-seven-main',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Lumber reserve bays',
              quantityLabel: '5 bays',
              statusLabel: '3 active · 2 open',
              buildingId: 'warehouse-seven-main',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Industrial oil drums zone',
              quantityLabel: '9 drum positions',
              statusLabel: '7 occupied · 2 open',
              buildingId: 'warehouse-seven-main',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Shared pallet jacks',
              quantityLabel: '3 jacks',
              statusLabel: '2 ready · 1 under maintenance',
              buildingId: 'warehouse-seven-main',
            ),
          ],
        ),
        MockProject(
          id: 'riverside-storage',
          title: 'Riverside Storage',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'devon-lee',
          managerIds: const ['devon-lee', 'joel-morris'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'devon-lee',
              approveCount: 16,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'joel-morris',
              approveCount: 13,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'devon-lee',
            'joel-morris',
            'mara-holt',
            'omar-nguyen',
          ],
          channelIds: const ['housing-build', 'repair-maintenance'],
          communityIds: const ['riverside-repair-club'],
          locationLabel: 'Riverside Industrial Block, Riverbend',
          locationDistrict: 'Riverside',
          summary:
              'One storage service managing multiple buildings across the block for heavy equipment, general supplies, and small tools.',
          body:
              'This service demonstrates the single-project model for one land asset. Warehouse A, Warehouse B, and the Equipment Shed all route through the same steward team and request queue.',
          demandCount: 17,
          awarenessCount: 43,
          comments: 6,
          createdAt: DateTime.parse('2026-03-18T08:10:00Z'),
          lastActivity: DateTime.parse('2026-04-02T14:45:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rs-1',
              authorId: 'devon-lee',
              title:
                  'Building labels finalized for Warehouse A, B, and the shed',
              body:
                  'The block now has one shared storage map, with each building called out separately so requests can route to the right steward area.',
              time: DateTime.parse('2026-04-02T14:10:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rs-1',
              title: 'Block storage handoff shift',
              timeLabel: 'Apr 11, 10:00 AM',
              location: 'Riverside Industrial Block',
              going: 6,
              description:
                  'Check outgoing holds across all three buildings, confirm pickup windows, and rebalance overflow stock before the weekend.',
              rolesNeeded: [
                '1 yard lead',
                '2 shelf coordinators',
                '1 outgoing queue recorder',
              ],
              materials: [
                'Building map',
                'Pickup ledger',
                'Overflow pallet tags',
              ],
              outcome:
                  'Keep the whole block legible as one stewarded service while preserving building-level location detail.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rs-1',
              title: 'Relabel Warehouse B consumables lanes',
              status: 'In progress',
            ),
            MockTask(
              id: 't-rs-2',
              title: 'Publish shared block pickup windows',
              status: 'Done',
            ),
          ],
          linkedProjectIds: const [
            'riverside-heavy-equipment-warehouse',
            'riverside-supplies-warehouse',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Daily stewarded pickup windows',
          serviceKind: MockServiceKind.storage,
          serviceMode: 'Multi-building storage stewardship',
          serviceCadence: 'Continuous weekly service',
          assetRequestPolicy:
              'Personal and project requests. One steward team manages requests across all three Riverside buildings.',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'Riverside Industrial Block yard access',
              quantityLabel: '1 block-wide yard route',
              statusLabel: 'Shared loading access active',
              note:
                  'The land base stays visible, but individual requests route through the specific building and steward area rather than through the yard itself.',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Heavy equipment attachment sets',
              quantityLabel: '9 sets listed',
              statusLabel: '6 ready · 3 checked out',
              buildingId: 'riverside-warehouse-a',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'General repair consumables pallets',
              quantityLabel: '11 pallet positions',
              statusLabel: '8 active · 3 open',
              buildingId: 'riverside-warehouse-b',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Small tools reserve',
              quantityLabel: '22 kits listed',
              statusLabel: '18 ready · 4 due back',
              buildingId: 'riverside-equipment-shed',
            ),
          ],
        ),
        MockProject(
          id: 'riverside-industrial-land-service',
          title: 'Riverside Industrial Land Service',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'rina-ortiz',
          managerIds: const ['rina-ortiz', 'joel-morris'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'rina-ortiz',
              approveCount: 19,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'joel-morris',
              approveCount: 15,
              rejectCount: 3,
            ),
          ],
          memberIds: const [
            'rina-ortiz',
            'joel-morris',
            'devon-lee',
            'omar-nguyen',
          ],
          channelIds: const ['housing-build', 'repair-maintenance'],
          communityIds: const ['east-market-retrofit-circle'],
          locationLabel: 'Riverside Industrial Block, Riverbend',
          locationDistrict: 'Riverside',
          summary:
              'A dedicated land-management service for the Riverside Industrial Block so site governance stays separate from the three storage services operating on the block.',
          body:
              'This service handles the land base itself: yard access, shared infrastructure, management acceptance, and tied-to-land-asset routing. The storage projects still manage their own building stock, but the land underneath them now has its own explicit service surface.',
          demandCount: 9,
          awarenessCount: 29,
          comments: 3,
          createdAt: DateTime.parse('2026-03-19T09:15:00Z'),
          lastActivity: DateTime.parse('2026-04-02T13:20:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rils-1',
              authorId: 'rina-ortiz',
              title:
                  'Block land-management queue separated from storage queues',
              body:
                  'Yard lighting, access questions, and shared-site requests now land on their own service instead of being mixed into the three Riverside storage projects.',
              time: DateTime.parse('2026-04-02T12:55:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rils-1',
              title: 'Industrial block land-service walk',
              timeLabel: 'Apr 12, 9:00 AM',
              location: 'Riverside Industrial Block',
              going: 5,
              description:
                  'Review yard access, lighting, maintenance issues, and any requests that affect the block as land rather than one specific building service.',
              rolesNeeded: ['1 block-routing lead', '1 maintenance note-taker'],
              materials: [
                'Block access map',
                'Shared infrastructure checklist',
              ],
              outcome:
                  'Keep the land base legible as its own service while the storage teams stay focused on stock and release flow.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rils-1',
              title: 'Publish shared yard access routing',
              status: 'In progress',
            ),
          ],
          linkedProjectIds: const [
            'riverside-storage',
            'riverside-heavy-equipment-warehouse',
            'riverside-supplies-warehouse',
          ],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Daily block-wide site response windows',
          serviceKind: MockServiceKind.landManagement,
          serviceMode: 'Land management and shared-yard routing',
          serviceCadence: 'Continuous weekly service',
          assetRequestPolicy:
              'Tied-to-land-asset and site-access requests route here when they affect the block itself rather than one storage-service queue.',
        ),
        MockProject(
          id: 'riverside-heavy-equipment-warehouse',
          title: 'Riverside Heavy Equipment Warehouse',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'carlos-rivera',
          managerIds: const ['carlos-rivera', 'omar-nguyen'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 15,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'omar-nguyen',
              approveCount: 12,
              rejectCount: 2,
            ),
          ],
          memberIds: const ['carlos-rivera', 'omar-nguyen', 'rina-ortiz'],
          channelIds: const ['housing-build', 'energy-retrofit'],
          communityIds: const ['east-market-retrofit-circle'],
          locationLabel: 'Riverside Industrial Block, Heavy Equipment Bay',
          locationDistrict: 'Riverside',
          summary:
              'A separate storage service for forklifts, tractors, and larger shared machines that need tighter access control.',
          body:
              'This service demonstrates the multiple-project model on the same land asset. It runs independently from Riverside Storage even though both sit on the same block.',
          demandCount: 12,
          awarenessCount: 34,
          comments: 4,
          createdAt: DateTime.parse('2026-03-20T11:20:00Z'),
          lastActivity: DateTime.parse('2026-04-02T13:35:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rhew-1',
              authorId: 'carlos-rivera',
              title: 'Forklift inspection rotation approved',
              body:
                  'The team now has a steadier inspection loop for larger shared machines before release windows open.',
              time: DateTime.parse('2026-04-02T13:10:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rhew-1',
              title: 'Machine release check',
              timeLabel: 'Apr 12, 8:00 AM',
              location: 'Riverside Industrial Block',
              going: 5,
              description:
                  'Inspect the larger machines, clear the next release queue, and confirm which requests need a stewarded operator handoff.',
              rolesNeeded: [
                '1 inspection lead',
                '1 operator check',
                '1 release recorder',
              ],
              materials: ['Inspection sheets', 'Key log', 'Release approvals'],
              outcome:
                  'Keep the heavy-equipment queue independent from the rest of the block while staying on the same land asset.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rhew-1',
              title: 'Replace one forklift beacon',
              status: 'In progress',
            ),
          ],
          linkedProjectIds: const ['riverside-storage'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Stewarded machine release windows',
          serviceKind: MockServiceKind.storage,
          serviceMode: 'Heavy equipment storage and release',
          serviceCadence: 'Continuous weekly service',
          assetRequestPolicy:
              'Project requests prioritized. Machine releases require steward confirmation and a scheduled handoff window.',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'Heavy equipment bay',
              quantityLabel: '1 monitored release bay',
              statusLabel: 'Active and stewarded',
              note:
                  'This bay is part of the Riverside Industrial Block and exists as its own storage service on the same land asset.',
              buildingId: 'riverside-heavy-equipment-bay',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Shared forklifts',
              quantityLabel: '2 forklifts listed',
              statusLabel: '1 ready · 1 under inspection',
              buildingId: 'riverside-heavy-equipment-bay',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Compact tractors',
              quantityLabel: '2 tractors listed',
              statusLabel: 'Both ready',
              buildingId: 'riverside-heavy-equipment-bay',
              requestability: MockAssetRequestability.projectOnly,
            ),
          ],
        ),
        MockProject(
          id: 'riverside-supplies-warehouse',
          title: 'Riverside Supplies Warehouse',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'mara-holt',
          managerIds: const ['mara-holt', 'sarah-kim'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'mara-holt',
              approveCount: 14,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'sarah-kim',
              approveCount: 11,
              rejectCount: 2,
            ),
          ],
          memberIds: const ['mara-holt', 'sarah-kim', 'joel-morris'],
          channelIds: const ['mutual-aid', 'repair-maintenance'],
          communityIds: const ['riverside-repair-club'],
          locationLabel: 'Riverside Industrial Block, Supplies Warehouse',
          locationDistrict: 'Riverside',
          summary:
              'A separate storage service for consumables, small tools, and quick-turn support stock on the same land asset.',
          body:
              'This service stays independent enough to justify its own project while still sharing the Riverside Industrial Block land base with the other storage services.',
          demandCount: 10,
          awarenessCount: 31,
          comments: 5,
          createdAt: DateTime.parse('2026-03-21T10:05:00Z'),
          lastActivity: DateTime.parse('2026-04-02T13:55:00Z'),
          updates: [
            MockUpdate(
              id: 'u-rsw-1',
              authorId: 'mara-holt',
              title:
                  'Consumables lanes now grouped by repair, build, and event use',
              body:
                  'The warehouse layout is now clearer for smaller project requests that do not need the heavy-equipment queue.',
              time: DateTime.parse('2026-04-02T13:25:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-rsw-1',
              title: 'Consumables restock shift',
              timeLabel: 'Apr 12, 1:00 PM',
              location: 'Riverside Industrial Block',
              going: 4,
              description:
                  'Recount the most-requested supply bins, publish what is low, and prep the next outgoing holds for small-tool requests.',
              rolesNeeded: ['1 stock counter', '1 outgoing picker'],
              materials: ['Bin count sheet', 'Outgoing hold tags'],
              outcome:
                  'Keep the supplies service independent but legible inside the same Riverside land asset.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-rsw-1',
              title: 'Recount fastening and sealant bins',
              status: 'To do',
            ),
          ],
          linkedProjectIds: const ['riverside-storage'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Daily outgoing holds and restock windows',
          serviceKind: MockServiceKind.storage,
          serviceMode: 'Consumables and small-tools storage',
          serviceCadence: 'Continuous weekly service',
          assetRequestPolicy:
              'Personal and project requests. Smaller holds move through this independent supplies queue rather than through the block-wide service.',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'Supplies warehouse floor',
              quantityLabel: '1 warehouse floor',
              statusLabel: 'Open for stewarded picking',
              note:
                  'This floor is part of the Riverside Industrial Block and is independently managed as its own storage service.',
              buildingId: 'riverside-supplies-bay',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Fasteners and brackets bins',
              quantityLabel: '24 bins listed',
              statusLabel: '19 ready · 5 low',
              buildingId: 'riverside-supplies-bay',
              requestability: MockAssetRequestability.projectOnly,
            ),
            MockAssetStockItem(
              name: 'Small tool restock kits',
              quantityLabel: '12 kits listed',
              statusLabel: '10 ready · 2 reserved',
              buildingId: 'riverside-supplies-bay',
            ),
          ],
        ),
        MockProject(
          id: 'cargo-bike-pool',
          title: 'Cargo Bike Pool',
          type: MockProjectType.service,
          stage: MockProjectStage.ongoing,
          authorId: 'omar-nguyen',
          managerIds: const ['omar-nguyen', 'sarah-kim'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'omar-nguyen',
              approveCount: 14,
              rejectCount: 3,
            ),
            MockGovernanceSeat(
              userId: 'sarah-kim',
              approveCount: 12,
              rejectCount: 2,
            ),
          ],
          memberIds: const [
            'anika-shaw',
            'omar-nguyen',
            'sarah-kim',
            'leo-park',
          ],
          channelIds: const ['mutual-aid', 'energy-retrofit'],
          communityIds: const ['east-market-retrofit-circle'],
          locationLabel: 'East Market Depot, Riverbend',
          locationDistrict: 'East Market',
          summary:
              'Keep a shared pool of cargo bikes, trailers, and booking slots available for local deliveries and project logistics.',
          body:
              'The cargo bike pool is a service project that handles booking, maintenance, and handoff rules for a small shared delivery fleet. It supports both neighborhood errands and project logistics.',
          demandCount: 21,
          awarenessCount: 56,
          comments: 8,
          createdAt: DateTime.parse('2026-03-27T12:10:00Z'),
          lastActivity: DateTime.parse('2026-04-02T13:50:00Z'),
          updates: [
            MockUpdate(
              id: 'u-cbp-1',
              authorId: 'omar-nguyen',
              title: 'Trailer booking sheet simplified',
              body:
                  'The old request form was too long, so we cut it down to route, time window, and load type.',
              time: DateTime.parse('2026-04-02T09:40:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-cbp-1',
              title: 'Fleet check and route test',
              timeLabel: 'Apr 11, 9:00 AM',
              location: 'East Market Depot',
              going: 7,
              description:
                  'Inspect the shared fleet, test trailer hookups, and run one practice route through the east-side delivery loop.',
              rolesNeeded: [
                '2 mechanics',
                '2 route riders',
                '1 handoff recorder',
              ],
              materials: [
                'Tire repair kit',
                'Route checklist',
                'Trailer latch parts',
              ],
              outcome:
                  'Confirm which bikes are ready for requests this week and which need maintenance before release.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-cbp-1',
              title: 'Mark overdue maintenance on two trailers',
              status: 'In progress',
            ),
            MockTask(
              id: 't-cbp-2',
              title: 'Publish simplified request window rules',
              status: 'Done',
            ),
          ],
          linkedProjectIds: const ['east-market-retrofit-pilot'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
          availability: 'Weekdays and Saturdays · request-based dispatch',
          assetRequestPolicy:
              'Personal and project requests. Dispatch stewards confirm release windows, returns, and route-kit readiness.',
          serviceMode: 'Borrow and dispatch',
          serviceCadence: 'Continuous weekly service',
          isCollectiveAssetProject: true,
          inventoryItems: const [
            MockAssetStockItem(
              name: 'East Market depot site',
              quantityLabel: '1 fleet bay',
              statusLabel: 'Dispatch and return point active',
              note:
                  'The depot is a fixed site that organizes the pool and is not individually requestable.',
              isSiteAsset: true,
              requestability: MockAssetRequestability.unavailable,
            ),
            MockAssetStockItem(
              name: 'Cargo bikes',
              quantityLabel: '6 bikes listed',
              statusLabel: '4 ready · 2 under maintenance',
            ),
            MockAssetStockItem(
              name: 'Cargo trailers',
              quantityLabel: '4 trailers listed',
              statusLabel: '3 ready · 1 pending latch repair',
            ),
            MockAssetStockItem(
              name: 'Helmet and light kits',
              quantityLabel: '8 kits listed',
              statusLabel: 'All ready',
              requestability: MockAssetRequestability.personalOnly,
            ),
          ],
        ),
        MockProject(
          id: 'north-commons-canning-shelf-build',
          title: 'North Commons Canning Shelf Build',
          type: MockProjectType.production,
          stage: MockProjectStage.completed,
          authorId: 'talia-brooks',
          managerIds: const ['talia-brooks', 'iya-ford'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'talia-brooks',
              approveCount: 18,
              rejectCount: 2,
            ),
            MockGovernanceSeat(
              userId: 'iya-ford',
              approveCount: 16,
              rejectCount: 2,
            ),
          ],
          memberIds: const [
            'talia-brooks',
            'iya-ford',
            'anika-shaw',
            'joel-morris',
          ],
          channelIds: const ['food-agriculture', 'housing-build'],
          communityIds: const ['downtown-growers'],
          locationLabel: 'North Commons Kitchen, Riverbend',
          locationDistrict: 'North Commons',
          summary:
              'A one-off build round that finished the new dry-storage shelving and handoff labels for the kitchen pantry.',
          body:
              'This production project is complete and remains as a record of the work, materials, and handoff notes that made the pantry easier to use for later kitchen work.',
          demandCount: 14,
          awarenessCount: 39,
          comments: 5,
          createdAt: DateTime.parse('2026-03-01T09:00:00Z'),
          lastActivity: DateTime.parse('2026-03-26T15:10:00Z'),
          updates: [
            MockUpdate(
              id: 'u-nccs-1',
              authorId: 'talia-brooks',
              title: 'Shelving build and labels complete',
              body:
                  'All planned shelving is installed, labeled, and handed off for regular kitchen use.',
              time: DateTime.parse('2026-03-26T14:20:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-nccs-1',
              title: 'Post-build handoff walk',
              timeLabel: 'Mar 26, 2:00 PM',
              location: 'North Commons Kitchen',
              going: 7,
              description:
                  'Walk the completed shelving layout, confirm jar and dry-goods placement, and record final handoff notes.',
              rolesNeeded: ['1 pantry lead', '1 handoff note-taker'],
              materials: ['Shelf map', 'Label set'],
              outcome:
                  'Finish the project with a clean handoff into ongoing kitchen use.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-nccs-1',
              title: 'Install final dry-goods labels',
              status: 'Done',
            ),
          ],
          linkedProjectIds: const ['tuesday-thursday-community-kitchen'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
        ),
        MockProject(
          id: 'east-side-freezer-expansion-pilot',
          title: 'East Side Freezer Expansion Pilot',
          type: MockProjectType.production,
          stage: MockProjectStage.cancelled,
          authorId: 'carlos-rivera',
          managerIds: const ['carlos-rivera'],
          managerSeats: const [
            MockGovernanceSeat(
              userId: 'carlos-rivera',
              approveCount: 9,
              rejectCount: 6,
            ),
          ],
          memberIds: const ['carlos-rivera', 'rina-ortiz', 'omar-nguyen'],
          channelIds: const ['mutual-aid', 'housing-build'],
          communityIds: const ['east-market-retrofit-circle'],
          locationLabel: 'East Market cold-storage corner, Riverbend',
          locationDistrict: 'East Market',
          summary:
              'A freezer expansion attempt that was cancelled after the site-access and power upgrade assumptions fell apart.',
          body:
              'This project remains visible as a cancelled record so the failed assumptions, site notes, and abandoned procurement path stay legible for later attempts.',
          demandCount: 11,
          awarenessCount: 28,
          comments: 7,
          createdAt: DateTime.parse('2026-03-03T11:15:00Z'),
          lastActivity: DateTime.parse('2026-03-19T18:05:00Z'),
          updates: [
            MockUpdate(
              id: 'u-esfe-1',
              authorId: 'carlos-rivera',
              title: 'Pilot cancelled after power and access review',
              body:
                  'The site could not support the planned freezer load without a much larger upgrade, so the pilot was cancelled instead of limping forward.',
              time: DateTime.parse('2026-03-19T17:10:00Z'),
            ),
          ],
          events: const [
            MockEvent(
              id: 'ev-esfe-1',
              title: 'Cancellation review meeting',
              timeLabel: 'Mar 19, 5:00 PM',
              location: 'East Market yard',
              going: 6,
              description:
                  'Review why the pilot stopped, what assumptions failed, and what should be preserved for any future cold-storage attempt.',
              rolesNeeded: ['1 review lead', '1 documentation recorder'],
              materials: ['Power estimate notes', 'Access checklist'],
              outcome:
                  'Keep a clean cancelled record instead of letting the project quietly disappear.',
            ),
          ],
          tasks: const [
            MockTask(
              id: 't-esfe-1',
              title: 'Archive failed procurement assumptions',
              status: 'Done',
            ),
          ],
          linkedProjectIds: const ['central-resource-storage-facility'],
          productionPlanIds: const [],
          distributionPlanIds: const [],
        ),
      ],
      threads = [
        MockThread(
          id: 'thread-farmers-market',
          title: 'Should the weekend market include a free swap table?',
          authorId: 'leo-park',
          channelIds: const ['food-agriculture', 'mutual-aid'],
          communityIds: const ['downtown-growers'],
          linkedThreadIds: const [],
          body:
              'A swap table would make the market more useful for people who have surplus produce, jars, or pantry basics but are not ready to join a larger project yet.',
          awarenessCount: 67,
          replyCount: 12,
          createdAt: DateTime.parse('2026-04-01T10:00:00Z'),
          lastActivity: DateTime.parse('2026-04-02T13:15:00Z'),
        ),
        MockThread(
          id: 'thread-watering-rotation',
          title: 'Local watering rotation ideas for block gardens',
          authorId: 'anika-shaw',
          channelIds: const ['food-agriculture'],
          communityIds: const ['downtown-growers'],
          linkedThreadIds: const ['thread-farmers-market'],
          body:
              'Before the garden network moves into planning, we need realistic volunteer rotation ideas that match people\'s actual schedules.',
          awarenessCount: 44,
          replyCount: 9,
          createdAt: DateTime.parse('2026-03-31T17:20:00Z'),
          lastActivity: DateTime.parse('2026-04-02T11:30:00Z'),
        ),
        MockThread(
          id: 'thread-tool-return-reminder',
          title: 'Better reminder flow for shared tool returns',
          authorId: 'devon-lee',
          channelIds: const ['repair-maintenance', 'housing-build'],
          communityIds: const ['riverside-repair-club'],
          linkedThreadIds: const [],
          body:
              'The current reminder copy feels too operator-heavy. Looking for a friendlier way to explain return timing without sounding punitive.',
          awarenessCount: 31,
          replyCount: 6,
          createdAt: DateTime.parse('2026-03-30T14:00:00Z'),
          lastActivity: DateTime.parse('2026-04-01T19:10:00Z'),
        ),
        MockThread(
          id: 'thread-seed-saving-shelf',
          title: 'What should count as reserve seed versus project-ready seed?',
          authorId: 'nina-patel',
          channelIds: const ['food-agriculture'],
          communityIds: const ['downtown-growers'],
          linkedThreadIds: const ['thread-watering-rotation'],
          body:
              'If we start a shared seed bank, we need a visible rule for what stays in reserve and what can be drawn down by active projects.',
          awarenessCount: 29,
          replyCount: 7,
          createdAt: DateTime.parse('2026-04-01T08:40:00Z'),
          lastActivity: DateTime.parse('2026-04-02T09:15:00Z'),
        ),
        MockThread(
          id: 'thread-retrofit-scouting',
          title:
              'Best way to batch scouting notes across the first retrofit cluster',
          authorId: 'rina-ortiz',
          channelIds: const ['energy-retrofit', 'housing-build'],
          communityIds: const ['east-market-retrofit-circle'],
          linkedThreadIds: const [],
          body:
              'Trying to avoid three different survey formats for the same pilot. Looking for one note structure everyone can reuse building to building.',
          awarenessCount: 37,
          replyCount: 10,
          createdAt: DateTime.parse('2026-04-01T13:25:00Z'),
          lastActivity: DateTime.parse('2026-04-02T17:05:00Z'),
        ),
        MockThread(
          id: 'thread-insulation-tool-checklist',
          title:
              'Which shared tools should stay packed for insulation prep days?',
          authorId: 'omar-nguyen',
          channelIds: const ['energy-retrofit'],
          communityIds: const ['east-market-retrofit-circle'],
          linkedThreadIds: const ['thread-retrofit-scouting'],
          body:
              'If we want the retrofit pilot to move faster, the most-used prep tools should probably live in one ready kit instead of being reassembled each time.',
          awarenessCount: 24,
          replyCount: 5,
          createdAt: DateTime.parse('2026-04-01T15:05:00Z'),
          lastActivity: DateTime.parse('2026-04-02T16:45:00Z'),
        ),
        MockThread(
          id: 'thread-repair-intake-signage',
          title: 'Friendlier intake signage for repair nights',
          authorId: 'sarah-kim',
          channelIds: const ['repair-maintenance'],
          communityIds: const ['riverside-repair-club'],
          linkedThreadIds: const ['thread-tool-return-reminder'],
          body:
              'People understand the process better when the signage describes what happens next instead of what they did wrong. Looking for better phrasing and ordering.',
          awarenessCount: 18,
          replyCount: 4,
          createdAt: DateTime.parse('2026-03-31T19:00:00Z'),
          lastActivity: DateTime.parse('2026-04-01T20:35:00Z'),
        ),
        MockThread(
          id: 'thread-release-queue-policy',
          title:
              'Should small UI fixes move through a lighter public review lane?',
          authorId: 'leo-park',
          channelIds: const ['stewardship'],
          communityIds: const [],
          linkedThreadIds: const [],
          body:
              'Right now every software proposal lands in the same review queue. I think small mock UI fixes should still be public, but should not wait behind larger infrastructure changes. Looking for a public rule before the board starts merging from the new stewardship project surface.',
          awarenessCount: 23,
          replyCount: 6,
          createdAt: DateTime.parse('2026-04-01T15:30:00Z'),
          lastActivity: DateTime.parse('2026-04-02T15:15:00Z'),
        ),
        MockThread(
          id: 'thread-fund-execution-brief',
          title:
              'What should every collective-fund execution note include by default?',
          authorId: 'anika-shaw',
          channelIds: const ['stewardship'],
          communityIds: const [],
          linkedThreadIds: const [],
          body:
              'The execution project now publishes one note after each approved disbursement block. I want a default public checklist so people do not have to guess whether the board actually executed what had already been approved.',
          awarenessCount: 19,
          replyCount: 5,
          createdAt: DateTime.parse('2026-04-01T17:00:00Z'),
          lastActivity: DateTime.parse('2026-04-02T14:50:00Z'),
        ),
      ],
      plans = [
        MockPlan(
          id: 'plan-garden-rotation',
          projectId: 'community-garden-network',
          kind: MockPlanKind.production,
          title: 'Adopt shared plot rotation plan for the first pilot',
          summary:
              'Set up a block-based rotation instead of permanent plot ownership for the first twelve weeks.',
          status: 'Voting Open',
          approved: false,
          version: 'Option A',
          proposerId: 'anika-shaw',
          yes: 58,
          no: 9,
          abstain: 6,
          threshold: '60% participation threshold',
          closesLabel: 'Closes in 2 days',
          createdAt: DateTime.parse('2026-03-31T15:10:00Z'),
          body:
              'This proposal keeps the first pilot flexible while we are still learning maintenance load and participation patterns. It prevents early lock-in and lets future rounds adapt to real demand.',
          discussion: [
            MockComment(
              id: 'pd-1',
              authorId: 'carlos-rivera',
              body:
                  'Rotation makes sense for the first round because the risk of uneven plot upkeep is still high.',
              time: DateTime.parse('2026-04-01T09:00:00Z'),
              score: 7,
              replies: [
                MockComment(
                  id: 'pd-1-r1',
                  authorId: 'anika-shaw',
                  body:
                      'That keeps the first pilot reversible if one block drops off mid-cycle.',
                  time: DateTime.parse('2026-04-01T11:05:00Z'),
                  score: 3,
                ),
              ],
            ),
            MockComment(
              id: 'pd-2',
              authorId: 'iya-ford',
              body:
                  'Please keep pickup-day planning tied to this, because allocation rules affect who can really participate.',
              time: DateTime.parse('2026-04-01T14:20:00Z'),
              score: 5,
            ),
          ],
        ),
        MockPlan(
          id: 'plan-garden-bed-layout',
          projectId: 'community-garden-network',
          kind: MockPlanKind.production,
          title: 'Approve fixed bed ownership for the first garden round',
          summary:
              'Assign plots to named stewards immediately instead of using rotation during the pilot.',
          status: 'Voting Open',
          approved: false,
          version: 'Option B',
          proposerId: 'carlos-rivera',
          yes: 21,
          no: 36,
          abstain: 4,
          threshold: '60% participation threshold',
          closesLabel: 'Closes in 2 days',
          createdAt: DateTime.parse('2026-03-31T16:00:00Z'),
          body:
              'This alternative plan favors immediate ownership clarity over rotation. It may be simpler to explain, but it reduces flexibility while the first round is still uncertain.',
          checklist: const [
            'Permanent plot assignments',
            'Named watering stewards',
            'Fixed harvest handoff points',
          ],
          discussion: [
            MockComment(
              id: 'pd-2b',
              authorId: 'leo-park',
              body:
                  'This feels too rigid while participation is still shifting week to week.',
              time: DateTime.parse('2026-04-01T18:10:00Z'),
              score: 4,
            ),
          ],
        ),
        MockPlan(
          id: 'plan-meal-kit-production',
          projectId: 'meal-kit-round',
          kind: MockPlanKind.production,
          title: 'Approved production plan for the first meal-kit round',
          summary:
              'Produce 120 kits over one weekend packing run with locked ingredient volumes and staffing assignments.',
          status: 'Approved',
          approved: true,
          version: 'Approved',
          proposerId: 'iya-ford',
          yes: 73,
          no: 5,
          abstain: 3,
          threshold: 'Threshold met',
          closesLabel: 'Approved last week',
          createdAt: DateTime.parse('2026-03-26T11:20:00Z'),
          body:
              'The first production run will pack 120 meal kits with one ingredient list, one packing sequence, and one cold-storage reservation window so the round stays executable.',
          checklist: const [
            '120-kit production target',
            'Ingredient volumes locked',
            'Cold storage reserved',
            'Packing labor assigned',
          ],
          estimatedExecutionLabel: 'Weekend of Apr 19',
          assetNeeds: const [
            MockPlanAssetNeed(
              label: 'North Commons cold-room shelves',
              quantityLabel: '2 shelf lanes',
              linkedAssetId: 'foundation-cold-room',
              note: 'Needed from Friday morning through first pickup staging.',
            ),
          ],
          costLines: const [
            MockPlanCostLine(
              label: 'Starter ingredient stock',
              cost: 4700,
              note: 'Bulk staples, greens, aromatics, and protein add-ons.',
            ),
            MockPlanCostLine(
              label: 'Reusable containers and labels',
              cost: 2500,
              note: 'First-round packaging and handoff labeling.',
            ),
          ],
          discussion: const [],
        ),
        MockPlan(
          id: 'plan-meal-kit-distribution',
          projectId: 'meal-kit-round',
          kind: MockPlanKind.distribution,
          title: 'Approved distribution plan for the first meal-kit round',
          summary:
              'Distribute finished kits through two pickup windows and one overflow delivery run tied to the approved production count.',
          status: 'Approved',
          approved: true,
          version: 'Approved',
          proposerId: 'anika-shaw',
          yes: 69,
          no: 4,
          abstain: 2,
          threshold: 'Threshold met',
          closesLabel: 'Approved last week',
          createdAt: DateTime.parse('2026-03-27T14:15:00Z'),
          body:
              'Distribution is tied directly to the approved 120-kit production plan, with pickup slots and overflow routing sized to that exact run.',
          checklist: const [
            'Two pickup windows',
            'Overflow delivery route',
            'Waitlist release order',
            'Readiness confirmation',
          ],
          estimatedExecutionLabel: 'Apr 20 and Apr 21',
          assetNeeds: const [
            MockPlanAssetNeed(
              label: 'Insulated handoff carriers',
              quantityLabel: '12 carrier slots',
              note:
                  'Pulled from the kitchen stack already on site, so no separate transfer is required.',
            ),
          ],
          costLines: const [
            MockPlanCostLine(
              label: 'Overflow route support',
              cost: 600,
              note: 'Fuel equivalent, volunteer support, and route materials.',
            ),
            MockPlanCostLine(
              label: 'Pickup signage and release tags',
              cost: 180,
            ),
          ],
          discussion: const [],
        ),
        MockPlan(
          id: 'plan-central-storage-circulation',
          projectId: 'central-resource-storage-facility',
          kind: MockPlanKind.distribution,
          title:
              'Approved circulation plan for shared storage releases and returns',
          summary:
              'Define how reserve stock is held, released to projects, and returned when storage allocations change.',
          status: 'Approved',
          approved: true,
          version: 'Approved',
          proposerId: 'carlos-rivera',
          yes: 34,
          no: 4,
          abstain: 1,
          threshold: 'Threshold met',
          closesLabel: 'Approved three days ago',
          createdAt: DateTime.parse('2026-03-28T13:40:00Z'),
          body:
              'Storage releases, reserve holds, return notes, and pickup windows now run through one visible circulation plan so the facility behaves like a public collective resource instead of an operator-only warehouse.',
          checklist: const [
            'Project request release order',
            'Personal pickup window',
            'Return logging step',
            'Cold-lane exception rule',
          ],
          discussion: const [],
        ),
        MockPlan(
          id: 'plan-seed-bank-circulation',
          projectId: 'shared-seed-bank',
          kind: MockPlanKind.distribution,
          title:
              'Approved circulation plan for shared seed borrowing and reserve handling',
          summary:
              'Define how personal packets, project allocations, and reserve stock move through the shared seed library.',
          status: 'Approved',
          approved: true,
          version: 'Approved',
          proposerId: 'nina-patel',
          yes: 28,
          no: 2,
          abstain: 1,
          threshold: 'Threshold met',
          closesLabel: 'Approved two days ago',
          createdAt: DateTime.parse('2026-03-30T17:10:00Z'),
          body:
              'The seed bank now uses one visible circulation plan covering personal packets, project allocations, reserve protection, and return notes when unused seed comes back into common stock.',
          checklist: const [
            'Personal packet pickup window',
            'Project allocation handoff note',
            'Reserve-stock exception rule',
            'Unused seed return log',
          ],
          discussion: const [],
        ),
        MockPlan(
          id: 'plan-library-queue',
          projectId: 'cooperative-tool-library',
          kind: MockPlanKind.distribution,
          title:
              'Approved borrowing and return plan for scarce tool circulation',
          summary:
              'Define the shared borrowing, return, and hold-release flow for high-demand tools.',
          status: 'Approved',
          approved: true,
          version: 'Approved',
          proposerId: 'devon-lee',
          yes: 31,
          no: 3,
          abstain: 2,
          threshold: '60% participation threshold met',
          closesLabel: 'Passed yesterday',
          createdAt: DateTime.parse('2026-03-29T11:45:00Z'),
          body:
              'The library uses one approved circulation plan for borrowing and return. Readiness confirmation, hold release, return check-in, and next-borrower handoff now stay visible to both borrowers and library managers.',
          checklist: const [
            '48-hour readiness confirmation',
            'Automatic hold release',
            'Return check-in step',
            'Visible queue status',
          ],
          discussion: [
            MockComment(
              id: 'pd-3',
              authorId: 'mara-holt',
              body:
                  'This is a good example of queue rules staying visible without becoming a bureaucracy wall.',
              time: DateTime.parse('2026-03-30T12:10:00Z'),
              score: 6,
            ),
          ],
        ),
      ],
      notifications = [
        MockNotificationItem(
          id: 'n-1',
          title: 'Community Garden Network posted a milestone update',
          body:
              'The lot survey closed one major uncertainty and added a new similar-project suggestion.',
          time: DateTime.parse('2026-04-02T17:48:00Z'),
          targetKind: 'project',
          targetId: 'community-garden-network',
          targetProjectTab: MockProjectTab.updates,
          targetUpdateId: 'u-cgn-1',
        ),
        MockNotificationItem(
          id: 'n-2',
          title: 'Vote open on the shared plot rotation proposal',
          body:
              'Governance discussion continues while the voting window stays open.',
          time: DateTime.parse('2026-04-02T17:00:00Z'),
          targetKind: 'plan',
          targetId: 'plan-garden-rotation',
        ),
        MockNotificationItem(
          id: 'n-3',
          title: 'Repair night RSVP confirmed',
          body: 'You are marked as going to the next Riverside repair shift.',
          time: DateTime.parse('2026-04-02T14:00:00Z'),
          targetKind: 'project',
          targetId: 'repair-circle',
          targetProjectTab: MockProjectTab.events,
        ),
        MockNotificationItem(
          id: 'n-4',
          title: 'Tool library rule update is now live',
          body: 'Queue handling changed after the readiness proposal passed.',
          time: DateTime.parse('2026-04-01T16:30:00Z'),
          targetKind: 'project',
          targetId: 'cooperative-tool-library',
          targetProjectTab: MockProjectTab.overview,
        ),
        MockNotificationItem(
          id: 'n-5',
          title: 'Storage release window opened for project requests',
          body:
              'Central Resource Storage Facility published the next outgoing pickup window for approved requests.',
          time: DateTime.parse('2026-04-02T16:00:00Z'),
          targetKind: 'project',
          targetId: 'central-resource-storage-facility',
          targetProjectTab: MockProjectTab.inventory,
        ),
        MockNotificationItem(
          id: 'n-6',
          title: 'Mara sent you a message',
          body:
              'Could you look over the updated intake checklist before Thursday night?',
          time: DateTime.parse('2026-04-02T17:51:00Z'),
          targetKind: 'conversation',
          targetId: 'dm-anika-mara',
        ),
      ],
      directConversations = [
        MockDirectConversation(
          id: 'dm-anika-mara',
          participantIds: ['anika-shaw', 'mara-holt'],
          lastActivity: DateTime.parse('2026-04-02T17:58:00Z'),
          unreadCount: 1,
        ),
        MockDirectConversation(
          id: 'dm-anika-devon',
          participantIds: ['anika-shaw', 'devon-lee'],
          lastActivity: DateTime.parse('2026-04-01T19:30:00Z'),
          unreadCount: 0,
        ),
        MockDirectConversation(
          id: 'dm-anika-iya',
          participantIds: ['anika-shaw', 'iya-ford'],
          lastActivity: DateTime.parse('2026-03-31T21:15:00Z'),
          unreadCount: 0,
        ),
      ],
      directMessagesByConversationId = {
        'dm-anika-mara': [
          MockDirectMessage(
            id: 'dm-am-1',
            authorId: 'mara-holt',
            body:
                'Could you look over the updated intake checklist before Thursday night?',
            time: DateTime.parse('2026-04-02T17:56:00Z'),
          ),
          MockDirectMessage(
            id: 'dm-am-2',
            authorId: 'anika-shaw',
            body:
                'Yes. I also want to compare it against the last repair-night bottlenecks.',
            time: DateTime.parse('2026-04-02T17:57:00Z'),
          ),
          MockDirectMessage(
            id: 'dm-am-3',
            authorId: 'mara-holt',
            body:
                'Perfect. I folded in the new triage categories and the bench handoff note.',
            time: DateTime.parse('2026-04-02T17:58:00Z'),
            reactions: {'✅': 1},
          ),
        ],
        'dm-anika-devon': [
          MockDirectMessage(
            id: 'dm-ad-1',
            authorId: 'devon-lee',
            body:
                'Warehouse Three is clearer now that the new shelving zones are live.',
            time: DateTime.parse('2026-04-01T19:12:00Z'),
            reactions: {'👍': 2, '👀': 1},
          ),
          MockDirectMessage(
            id: 'dm-ad-2',
            authorId: 'anika-shaw',
            body:
                'Good. That should make project pickups less confusing for first-time borrowers.',
            time: DateTime.parse('2026-04-01T19:30:00Z'),
          ),
        ],
        'dm-anika-iya': [
          MockDirectMessage(
            id: 'dm-ai-1',
            authorId: 'iya-ford',
            body:
                'If the cold storage quote holds, the meal-kit round can finally move without another planning detour.',
            time: DateTime.parse('2026-03-31T20:48:00Z'),
          ),
          MockDirectMessage(
            id: 'dm-ai-2',
            authorId: 'anika-shaw',
            body:
                'Send it once the final revision lands. I want the update text to match the fund ask exactly.',
            time: DateTime.parse('2026-03-31T21:15:00Z'),
          ),
        ],
      },
      updateCommentsById = {
        'u-cgn-1': [
          MockComment(
            id: 'ucgn-1',
            authorId: 'carlos-rivera',
            body:
                'The water-line issue is exactly the kind of blocker that should stay visible before planning opens.',
            time: DateTime.parse('2026-04-02T09:25:00Z'),
            score: 6,
            replies: [
              MockComment(
                id: 'ucgn-1-r1',
                authorId: 'anika-shaw',
                body:
                    'Agreed. I want the update thread to hold the constraint history instead of burying it in the overview text.',
                time: DateTime.parse('2026-04-02T09:42:00Z'),
                score: 4,
              ),
            ],
          ),
        ],
        'u-rc-1': [
          MockComment(
            id: 'urc-1',
            authorId: 'leo-park',
            body:
                'The intake categories are strong, but the handoff note still needs a clearer damaged-item path.',
            time: DateTime.parse('2026-04-01T18:26:00Z'),
            score: 5,
          ),
        ],
        'u-mkr-1': [
          MockComment(
            id: 'umkr-1',
            authorId: 'talia-brooks',
            body:
                'This is the first update that makes the final acquisition gap feel concrete instead of fuzzy.',
            time: DateTime.parse('2026-04-02T16:04:00Z'),
            score: 7,
          ),
        ],
      },
      foundationAssets = const [
        MockFoundationAsset(
          id: 'foundation-maple-fourth-land',
          name: 'Maple And 4th Garden Lots',
          groupLabel: 'Land',
          kindLabel: 'Collective',
          summary:
              'Three linked lots being assembled into the first shared garden network base, including access, drainage, and water-line work.',
          locationLabel: 'Maple and 4th, Downtown District',
          zoneId: 'maple-fourth-lots',
          availabilityLabel: 'Stewarded collectively · not requestable',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'riverbend-land-stewards',
          linkedProjectIds: [
            'community-garden-network',
            'riverbend-land-stewards',
          ],
        ),
        MockFoundationAsset(
          id: 'foundation-south-field-land',
          name: 'South Field Collective Land',
          groupLabel: 'Land',
          kindLabel: 'Collective Farm',
          summary:
              'The land parcel, field lanes, and greenhouse footprint that anchor the Riverbend farm buildout and seasonal work cycles.',
          locationLabel: 'South Field Cooperative Farm',
          zoneId: 'south-field',
          availabilityLabel: 'Active cultivation site',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'riverbend-land-stewards',
          linkedProjectIds: [
            'riverbend-collective-farm',
            'riverbend-land-stewards',
          ],
        ),
        MockFoundationAsset(
          id: 'foundation-warehouse-three-site',
          name: 'Warehouse Three Site',
          groupLabel: 'Land',
          kindLabel: 'Warehouse',
          summary:
              'The warehouse lot and loading apron anchoring the cooperative tool library.',
          locationLabel: 'Warehouse Three, Warehouse District',
          zoneId: 'warehouse-three',
          availabilityLabel: 'Active collective warehouse site',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'shared-sites-land-service',
          linkedProjectIds: [
            'cooperative-tool-library',
            'shared-sites-land-service',
          ],
        ),
        MockFoundationAsset(
          id: 'foundation-tool-cage',
          name: 'Home Repair Tool Library',
          groupLabel: 'Storage',
          kindLabel: 'Tools',
          summary:
              'Shared drills, repair kits, staplers, extension reels, and home-repair hand tools held for borrowing and return.',
          locationLabel: 'Warehouse Three',
          zoneId: 'warehouse-three',
          availabilityLabel: '12 of 16 items available',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-warehouse-three-site',
          stewardProjectId: 'cooperative-tool-library',
          buildingId: 'warehouse-three-main',
          linkedProjectIds: ['cooperative-tool-library'],
        ),
        MockFoundationAsset(
          id: 'foundation-west-garden-site',
          name: 'West Garden Seed Shed Lot',
          groupLabel: 'Land',
          kindLabel: 'Shed',
          summary:
              'The small land parcel and shed base supporting the shared seed bank and learning-kit storage.',
          locationLabel: 'West Garden Shed, Riverbend',
          zoneId: 'west-garden-annex',
          availabilityLabel: 'Active garden-side storage site',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'shared-sites-land-service',
          linkedProjectIds: ['shared-seed-bank', 'shared-sites-land-service'],
        ),
        MockFoundationAsset(
          id: 'foundation-seed-cabinet',
          name: 'Shared Seed Cabinet',
          groupLabel: 'Library',
          kindLabel: 'Seed stock',
          summary:
              'Open-pollinated vegetable and herb seed held back for neighborhood growing rounds and member learning kits.',
          locationLabel: 'West Garden Annex',
          zoneId: 'west-garden-annex',
          availabilityLabel: '84 packets ready',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-west-garden-site',
          stewardProjectId: 'shared-seed-bank',
          buildingId: 'west-garden-shed',
          linkedProjectIds: ['shared-seed-bank'],
        ),
        MockFoundationAsset(
          id: 'foundation-north-commons-site',
          name: 'North Commons Kitchen Site',
          groupLabel: 'Land',
          kindLabel: 'Community Kitchen',
          summary:
              'The kitchen lot and service footprint used by food production, handoff, and cold-hold work at North Commons.',
          locationLabel: 'North Commons Kitchen, Riverbend',
          zoneId: 'north-commons',
          availabilityLabel: 'Active kitchen site',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'riverbend-land-stewards',
          linkedProjectIds: [
            'riverbend-land-stewards',
            'meal-kit-round',
            'tuesday-thursday-community-kitchen',
            'north-commons-canning-shelf-build',
          ],
        ),
        MockFoundationAsset(
          id: 'foundation-cold-room',
          name: 'North Commons Cold Room',
          groupLabel: 'Storage',
          kindLabel: 'Cold storage',
          summary:
              'Short-cycle refrigerated shelving for produce, meal-kit packing windows, and temporary overflow holding.',
          locationLabel: 'North Commons',
          zoneId: 'north-commons',
          availabilityLabel: '2 of 6 shelves open',
          requestPolicyLabel: 'Project requests prioritized',
          landAssetId: 'foundation-north-commons-site',
          linkedProjectIds: ['riverbend-land-stewards'],
        ),
        MockFoundationAsset(
          id: 'foundation-east-market-depot-site',
          name: 'East Market Depot Site',
          groupLabel: 'Land',
          kindLabel: 'Dispatch yard',
          summary:
              'The depot yard and dispatch point used by the cargo-bike pool for releases, returns, and quick maintenance handoffs.',
          locationLabel: 'East Market Depot, Riverbend',
          zoneId: 'east-market-depot',
          availabilityLabel: 'Active dispatch yard',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'shared-sites-land-service',
          linkedProjectIds: ['cargo-bike-pool', 'shared-sites-land-service'],
        ),
        MockFoundationAsset(
          id: 'foundation-bike-locker',
          name: 'Cargo Bike Locker',
          groupLabel: 'Storage',
          kindLabel: 'Route kits',
          summary:
              'Chargers, helmets, repair kits, bags, and route boards for the shared neighborhood delivery fleet.',
          locationLabel: 'East Market Depot',
          zoneId: 'east-market-depot',
          availabilityLabel: '5 route kits available',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-east-market-depot-site',
          linkedProjectIds: ['cargo-bike-pool'],
        ),
        MockFoundationAsset(
          id: 'foundation-central-storage',
          name: 'Central Resource Release Lanes',
          groupLabel: 'Storage',
          kindLabel: 'Warehouse stock',
          summary:
              'Shared cold lanes, lumber reserve bays, oil storage, and outgoing pickup staging for collective stock redistribution.',
          locationLabel: 'Warehouse Seven',
          zoneId: 'east-market-yard',
          availabilityLabel: '4 lanes open this week',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-warehouse-seven-site',
          stewardProjectId: 'central-resource-storage-facility',
          buildingId: 'warehouse-seven-main',
          linkedProjectIds: ['central-resource-storage-facility'],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-industrial-block',
          name: 'Riverside Industrial Block',
          groupLabel: 'Land',
          kindLabel: 'Collective',
          summary:
              'A collectively owned block anchoring several storage-service configurations, shared yards, and future physical project work.',
          locationLabel: 'Riverside Industrial Block, Riverbend',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: 'Collective industrial block in active use',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'riverside-industrial-land-service',
          linkedProjectIds: [
            'riverside-industrial-land-service',
            'riverside-storage',
            'riverside-heavy-equipment-warehouse',
            'riverside-supplies-warehouse',
          ],
        ),
        MockFoundationAsset(
          id: 'foundation-warehouse-seven-site',
          name: 'Warehouse Seven Site',
          groupLabel: 'Land',
          kindLabel: 'Storage',
          summary:
              'The warehouse lot, loading apron, and access lanes that the central storage facility runs out of.',
          locationLabel: 'Warehouse Seven, East Market',
          zoneId: 'east-market-yard',
          availabilityLabel: 'Collective storage site in active use',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'shared-sites-land-service',
          linkedAssetIds: ['foundation-central-storage'],
          linkedProjectIds: [
            'central-resource-storage-facility',
            'shared-sites-land-service',
          ],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-heavy-racks',
          name: 'Warehouse A Heavy Equipment Racks',
          groupLabel: 'Storage',
          kindLabel: 'Heavy equipment storage',
          summary:
              'Rack lanes for shared machine attachments and oversize hardware inside Warehouse A.',
          locationLabel: 'Riverside Industrial Block · Warehouse A',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: '6 of 9 rack positions ready',
          requestPolicyLabel: 'Project requests prioritized',
          landAssetId: 'foundation-riverside-industrial-block',
          stewardProjectId: 'riverside-storage',
          buildingId: 'riverside-warehouse-a',
          linkedProjectIds: ['riverside-storage'],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-general-stock',
          name: 'Warehouse B General Supplies',
          groupLabel: 'Storage',
          kindLabel: 'General supplies',
          summary:
              'Fast-moving shared materials and repair consumables held in the main Riverside block warehouse.',
          locationLabel: 'Riverside Industrial Block · Warehouse B',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: '8 pallet positions active',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-riverside-industrial-block',
          stewardProjectId: 'riverside-storage',
          buildingId: 'riverside-warehouse-b',
          linkedProjectIds: ['riverside-storage'],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-small-tools',
          name: 'Equipment Shed Tool Reserve',
          groupLabel: 'Library',
          kindLabel: 'Small tools',
          summary:
              'Shared kits, small power tools, and quick-turn repair tools kept in the Riverside equipment shed.',
          locationLabel: 'Riverside Industrial Block · Equipment Shed',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: '18 of 22 kits ready',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-riverside-industrial-block',
          stewardProjectId: 'riverside-storage',
          buildingId: 'riverside-equipment-shed',
          linkedProjectIds: ['riverside-storage'],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-forklift-bay',
          name: 'Heavy Equipment Release Bay',
          groupLabel: 'Storage',
          kindLabel: 'Machine release area',
          summary:
              'Forklifts, tractors, and larger shared machines held in a separately managed heavy-equipment service on the same block.',
          locationLabel: 'Riverside Industrial Block · Heavy Equipment Bay',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: '3 machine slots active',
          requestPolicyLabel: 'Project requests prioritized',
          landAssetId: 'foundation-riverside-industrial-block',
          stewardProjectId: 'riverside-heavy-equipment-warehouse',
          buildingId: 'riverside-heavy-equipment-bay',
          linkedProjectIds: ['riverside-heavy-equipment-warehouse'],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-supplies-bins',
          name: 'Supplies Warehouse Fast-Moving Stock',
          groupLabel: 'Storage',
          kindLabel: 'Consumables',
          summary:
              'Repair consumables, small-tool restocks, and outgoing support stock held in a separate Riverside supplies service.',
          locationLabel: 'Riverside Industrial Block · Supplies Warehouse',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: '19 of 24 bins ready',
          requestPolicyLabel: 'Personal and project requests',
          landAssetId: 'foundation-riverside-industrial-block',
          stewardProjectId: 'riverside-supplies-warehouse',
          buildingId: 'riverside-supplies-bay',
          linkedProjectIds: ['riverside-supplies-warehouse'],
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-yard-grid',
          name: 'Riverside Yard Lighting And Power Grid',
          groupLabel: 'Infrastructure',
          kindLabel: 'Shared yard infrastructure',
          summary:
              'Fixed lighting, yard power hookups, and shared route markings that support the whole block without belonging to any one storage service.',
          locationLabel: 'Riverside Industrial Block yard',
          zoneId: 'riverside-industrial-block',
          availabilityLabel: 'In active use across the block',
          requestPolicyLabel: 'Unavailable for request',
          landAssetId: 'foundation-riverside-industrial-block',
        ),
        MockFoundationAsset(
          id: 'foundation-riverside-workshop-site',
          name: 'Riverside Workshop Site',
          groupLabel: 'Land',
          kindLabel: 'Workshop',
          summary:
              'The workshop land base supporting recurring repair nights, intake benches, and follow-up documentation space.',
          locationLabel: 'Riverside Workshop, Riverbend',
          zoneId: 'riverside-workshop',
          availabilityLabel: 'Active workshop site',
          requestPolicyLabel: 'Unavailable for request',
          stewardProjectId: 'shared-sites-land-service',
          linkedProjectIds: ['repair-circle', 'shared-sites-land-service'],
        ),
        MockFoundationAsset(
          id: 'foundation-repair-bay',
          name: 'Repair Intake Bay',
          groupLabel: 'Space',
          kindLabel: 'Workspace',
          summary:
              'Bench space, tagged shelving, and intake signage for repair nights, inspections, and follow-up documentation.',
          locationLabel: 'Riverside Workshop',
          zoneId: 'riverside-workshop',
          availabilityLabel: 'Next opening Thu 6pm',
          requestPolicyLabel: 'Project scheduling with personal shift requests',
          landAssetId: 'foundation-riverside-workshop-site',
          linkedProjectIds: ['repair-circle'],
        ),
      ],
      foundationRequests = [
        MockFoundationRequest(
          id: 'foundation-request-1',
          assetId: 'foundation-seed-cabinet',
          requesterId: 'anika-shaw',
          scopeLabel: 'Personal',
          statusLabel: 'Ready for pickup',
          needByLabel: 'Tomorrow morning',
          note:
              'Need a few quick greens and herb packets for the block demo bed and a short seed-saving walkthrough.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-2',
          assetId: 'foundation-tool-cage',
          requesterId: 'rina-ortiz',
          projectId: 'east-market-retrofit-pilot',
          assignedProjectId: 'cooperative-tool-library',
          scopeLabel: 'Project',
          statusLabel: 'In review',
          needByLabel: 'This weekend',
          note:
              'Reserve moisture meters and staplers for the three-building insulation prep survey.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-2b',
          assetId: 'foundation-tool-cage',
          requesterId: 'anika-shaw',
          assignedProjectId: 'cooperative-tool-library',
          scopeLabel: 'Personal',
          statusLabel: 'In review',
          needByLabel: 'This weekend',
          note:
              'Need one drill kit and a small hand-tool set for a home repair shift at my building.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-3',
          assetId: 'foundation-cold-room',
          requesterId: 'talia-brooks',
          projectId: 'meal-kit-round',
          assignedProjectId: 'riverbend-land-stewards',
          scopeLabel: 'Project',
          statusLabel: 'Requested · waiting on acquisition',
          needByLabel: 'Friday 7am',
          note:
              'Hold two shelves for the first short meal-kit packing run before neighborhood pickup starts.',
          createdByPlanId: 'plan-meal-kit-production',
          dispatchBlockedByAcquisition: true,
        ),
        MockFoundationRequest(
          id: 'foundation-request-4',
          assetId: 'foundation-bike-locker',
          requesterId: 'omar-nguyen',
          projectId: 'cargo-bike-pool',
          assignedProjectId: 'cargo-bike-pool',
          scopeLabel: 'Project',
          statusLabel: 'Ready',
          needByLabel: 'Today 4pm',
          note:
              'Pick up two route kits and a charger pack for the evening delivery loop and trailer check.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-4b',
          assetId: 'foundation-central-storage',
          requesterId: 'iya-ford',
          projectId: 'tuesday-thursday-community-kitchen',
          assignedProjectId: 'central-resource-storage-facility',
          scopeLabel: 'Project',
          statusLabel: 'Scheduled window',
          needByLabel: 'Thursday noon',
          note:
              'Release two cold shelf lanes and one dry-stock pallet for the next Tuesday and Thursday kitchen cycle.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-5',
          assetId: 'foundation-repair-bay',
          requesterId: 'sarah-kim',
          assignedProjectId: 'repair-circle',
          scopeLabel: 'Personal',
          statusLabel: 'Pending steward approval',
          needByLabel: 'Next repair night',
          note:
              'Use one intake bench to document a friendlier lamp and appliance dropoff flow for volunteers.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-6',
          assetId: 'foundation-riverside-small-tools',
          requesterId: 'mara-holt',
          assignedProjectId: 'riverside-storage',
          scopeLabel: 'Personal',
          statusLabel: 'In review',
          needByLabel: 'Friday afternoon',
          note:
              'Need two small-tool kits from the Riverside shed for a neighborhood repair training shift.',
        ),
        MockFoundationRequest(
          id: 'foundation-request-7',
          assetId: 'foundation-riverside-forklift-bay',
          requesterId: 'carlos-rivera',
          projectId: 'east-market-retrofit-pilot',
          assignedProjectId: 'riverside-heavy-equipment-warehouse',
          scopeLabel: 'Project',
          statusLabel: 'Scheduled window',
          needByLabel: 'Monday 8am',
          note:
              'Reserve one forklift release window and one attachment set for a block-materials lift at the retrofit pilot.',
        ),
      ],
      landManagementRequests = [],
      softwareChangeRequests = [
        MockSoftwareChangeRequest(
          id: 'software-change-1',
          projectId: 'platform-network-maintenance',
          requesterId: 'carlos-rivera',
          repoTarget: 'mock app/lib/main.dart',
          diffSummary:
              'Tighten the plan composer copy so new land-management routing choices read clearly in the mock.',
          status: MockSoftwareChangeRequestStatus.proposed,
          createdAt: DateTime.parse('2026-04-02T10:20:00Z'),
          note:
              'This is a wording-only change, but it affects whether people understand the plan branch before approval.',
        ),
        MockSoftwareChangeRequest(
          id: 'software-change-2',
          projectId: 'platform-network-maintenance',
          requesterId: 'sarah-kim',
          repoTarget: 'web/src/feed/notification_list.tsx',
          diffSummary:
              'Group project-request alerts so land-management and transfer events do not collapse into the same unread pattern.',
          status: MockSoftwareChangeRequestStatus.underReview,
          createdAt: DateTime.parse('2026-04-02T09:15:00Z'),
          note:
              'The current notification surface makes it hard to tell operational handoffs from governance review.',
        ),
        MockSoftwareChangeRequest(
          id: 'software-change-3',
          projectId: 'platform-network-maintenance',
          requesterId: 'leo-park',
          repoTarget: 'network/crates/sync/src/subscriptions.rs',
          diffSummary:
              'Merge lightweight subscription-state fix so channel follow toggles survive reconnects.',
          status: MockSoftwareChangeRequestStatus.merged,
          createdAt: DateTime.parse('2026-04-01T16:45:00Z'),
          reviewNote: 'Merged during the last stewardship review window.',
        ),
      ],
      foundationZones = const [
        MockFoundationZone(
          id: 'maple-fourth-lots',
          name: 'Maple and 4th Lots',
          locationLabel: 'Demand-signalling garden site',
          summary:
              'Pilot land base for the neighborhood garden network and later linked growing work.',
          assetIds: ['foundation-maple-fourth-land'],
        ),
        MockFoundationZone(
          id: 'south-field',
          name: 'South Field',
          locationLabel: 'Collective farm land',
          summary:
              'Field, greenhouse, and shed footprint used by the Riverbend collective farm.',
          assetIds: ['foundation-south-field-land'],
        ),
        MockFoundationZone(
          id: 'warehouse-three',
          name: 'Warehouse Three',
          locationLabel: 'Central storage and prep',
          summary:
              'Holds durable tools and prep gear that move across build and retrofit work.',
          assetIds: ['foundation-warehouse-three-site', 'foundation-tool-cage'],
        ),
        MockFoundationZone(
          id: 'west-garden-annex',
          name: 'West Garden Annex',
          locationLabel: 'Seed and learning stock',
          summary:
              'Small accessible room for seed packets, reserve stock, and lightweight learning kits.',
          assetIds: ['foundation-west-garden-site', 'foundation-seed-cabinet'],
        ),
        MockFoundationZone(
          id: 'north-commons',
          name: 'North Commons',
          locationLabel: 'Cold chain site',
          summary:
              'Refrigerated holding and staging space near the kitchen and neighborhood pickup points.',
          assetIds: ['foundation-north-commons-site', 'foundation-cold-room'],
        ),
        MockFoundationZone(
          id: 'east-market-depot',
          name: 'East Market Depot',
          locationLabel: 'Dispatch yard and route handoff point',
          summary:
              'Depot land and quick-turn route-kit storage for the cargo-bike pool.',
          assetIds: [
            'foundation-east-market-depot-site',
            'foundation-bike-locker',
          ],
        ),
        MockFoundationZone(
          id: 'east-market-yard',
          name: 'Warehouse Seven Yard',
          locationLabel: 'Warehouse storage and loading yard',
          summary:
              'Loading yard and warehouse footprint for the central storage service.',
          assetIds: [
            'foundation-central-storage',
            'foundation-warehouse-seven-site',
          ],
        ),
        MockFoundationZone(
          id: 'riverside-workshop',
          name: 'Riverside Workshop',
          locationLabel: 'Repair and intake space',
          summary:
              'Shared intake benches and sorting shelves tied to the repair-night workflow.',
          assetIds: [
            'foundation-riverside-workshop-site',
            'foundation-repair-bay',
          ],
        ),
        MockFoundationZone(
          id: 'riverside-industrial-block',
          name: 'Riverside Industrial Block',
          locationLabel: 'Multi-service land asset',
          summary:
              'One land asset demonstrating both a multi-building storage service and multiple independent storage services on the same block.',
          assetIds: [
            'foundation-riverside-industrial-block',
            'foundation-riverside-yard-grid',
          ],
        ),
      ],
      storageBuildings = const [
        MockStorageBuilding(
          id: 'warehouse-three-main',
          projectId: 'cooperative-tool-library',
          landAssetId: 'foundation-warehouse-three-site',
          name: 'Warehouse Three Main Floor',
          kindLabel: 'Warehouse',
          summary:
              'The main tool-library floor, shelving lanes, and pickup/loading bay for the cooperative tool library.',
        ),
        MockStorageBuilding(
          id: 'west-garden-shed',
          projectId: 'shared-seed-bank',
          landAssetId: 'foundation-west-garden-site',
          name: 'West Garden Seed Shed',
          kindLabel: 'Shed',
          summary:
              'The small seed-sorting and reserve-stock building used by the shared seed bank.',
        ),
        MockStorageBuilding(
          id: 'warehouse-seven-main',
          projectId: 'central-resource-storage-facility',
          landAssetId: 'foundation-warehouse-seven-site',
          name: 'Warehouse Seven Main Floor',
          kindLabel: 'Warehouse',
          summary:
              'The main storage floor and release lanes used by the central resource storage service.',
        ),
        MockStorageBuilding(
          id: 'riverside-warehouse-a',
          projectId: 'riverside-storage',
          landAssetId: 'foundation-riverside-industrial-block',
          name: 'Warehouse A',
          kindLabel: 'Warehouse',
          summary:
              'Heavy equipment overflow and larger rack lanes inside the shared Riverside Storage service.',
        ),
        MockStorageBuilding(
          id: 'riverside-warehouse-b',
          projectId: 'riverside-storage',
          landAssetId: 'foundation-riverside-industrial-block',
          name: 'Warehouse B',
          kindLabel: 'Warehouse',
          summary:
              'General supplies and pallet-ready stock held under the same block-wide storage service.',
        ),
        MockStorageBuilding(
          id: 'riverside-equipment-shed',
          projectId: 'riverside-storage',
          landAssetId: 'foundation-riverside-industrial-block',
          name: 'Equipment Shed',
          kindLabel: 'Shed',
          summary:
              'Small tools and quick-turn kits stewarded by the same Riverside Storage project.',
        ),
        MockStorageBuilding(
          id: 'riverside-heavy-equipment-bay',
          projectId: 'riverside-heavy-equipment-warehouse',
          landAssetId: 'foundation-riverside-industrial-block',
          name: 'Heavy Equipment Bay',
          kindLabel: 'Warehouse',
          summary:
              'An independently managed machine-release building on the same land asset.',
        ),
        MockStorageBuilding(
          id: 'riverside-supplies-bay',
          projectId: 'riverside-supplies-warehouse',
          landAssetId: 'foundation-riverside-industrial-block',
          name: 'Supplies Warehouse',
          kindLabel: 'Warehouse',
          summary:
              'A separately managed supplies building on the same Riverside block.',
        ),
      ],
      projectCommentsById = {
        'community-garden-network': [
          MockComment(
            id: 'pc1',
            authorId: 'leo-park',
            body:
                'If this moves into planning, I want the first pickup points chosen by walking distance, not only by lot ownership.',
            time: DateTime.parse('2026-04-02T10:10:00Z'),
            score: 11,
            replies: [
              MockComment(
                id: 'pc1-r1',
                authorId: 'iya-ford',
                body:
                    'Agreed. Distribution logic needs to be visible before the first acquisition opens.',
                time: DateTime.parse('2026-04-02T10:42:00Z'),
                score: 6,
              ),
            ],
          ),
          MockComment(
            id: 'pc2',
            authorId: 'carlos-rivera',
            body:
                'The similar-project comparison is helpful. It keeps this from duplicating the meal-kit work by accident.',
            time: DateTime.parse('2026-04-01T18:05:00Z'),
            score: 7,
          ),
        ],
        'repair-circle': [
          MockComment(
            id: 'pc3',
            authorId: 'mara-holt',
            body:
                'I would like a clearer request intake form before we add another weekly shift.',
            time: DateTime.parse('2026-04-02T15:10:00Z'),
            score: 5,
          ),
        ],
        'cooperative-tool-library': [
          MockComment(
            id: 'pc4',
            authorId: 'devon-lee',
            body:
                'Nested discussion is enough for the mock as long as queue-rule decisions stay visible.',
            time: DateTime.parse('2026-04-02T09:00:00Z'),
            score: 8,
          ),
        ],
        'meal-kit-round': [
          MockComment(
            id: 'pc5',
            authorId: 'anika-shaw',
            body:
                'The purchase list is finally specific enough that the acquisition feels concrete and not hand-wavy.',
            time: DateTime.parse('2026-04-02T16:10:00Z'),
            score: 10,
          ),
        ],
      },
      threadCommentsById = {
        'thread-farmers-market': [
          MockComment(
            id: 'c1',
            authorId: 'carlos-rivera',
            body:
                'A staffed swap table makes sense if we pair it with a simple intake board so people can tell what is moving fast.',
            time: DateTime.parse('2026-04-02T13:15:00Z'),
            score: 8,
            replies: [
              MockComment(
                id: 'c1-r1',
                authorId: 'iya-ford',
                body:
                    'And that same board could feed demand signals back into future production rounds.',
                time: DateTime.parse('2026-04-02T14:00:00Z'),
                score: 4,
              ),
            ],
          ),
          MockComment(
            id: 'c2',
            authorId: 'mara-holt',
            body:
                'If it is unsupervised for long stretches it will probably turn into a cleanup problem, so I would keep the window short.',
            time: DateTime.parse('2026-04-02T12:20:00Z'),
            score: 5,
          ),
        ],
        'thread-watering-rotation': [
          MockComment(
            id: 'c3',
            authorId: 'leo-park',
            body:
                'A two-day-on rotation by block might be easier than assigning individual plots immediately.',
            time: DateTime.parse('2026-04-01T18:40:00Z'),
            score: 7,
          ),
        ],
        'thread-tool-return-reminder': [
          MockComment(
            id: 'c4',
            authorId: 'anika-shaw',
            body:
                'Framing it as next borrower is waiting lands better than you are late.',
            time: DateTime.parse('2026-04-01T19:10:00Z'),
            score: 6,
          ),
        ],
      },
      projectHistoryByProjectId = {
        'meal-kit-round': [
          MockProjectHistoryEntry(
            id: 'ph-mkr-1',
            projectId: 'meal-kit-round',
            categoryLabel: 'Stage',
            title: 'Moved into Acquisition',
            body:
                'The project left planning after the production and distribution plans were approved and the ingredient, packaging, and cold-hold gap was narrow enough to quantify.',
            time: DateTime.parse('2026-03-28T16:45:00Z'),
            actorId: 'iya-ford',
            assetId: 'foundation-cold-room',
          ),
          MockProjectHistoryEntry(
            id: 'ph-mkr-2',
            projectId: 'meal-kit-round',
            categoryLabel: 'Transfer',
            title: 'Cold-room shelf window scheduled',
            body:
                'Two shelf lanes were scheduled through the North Commons kitchen team so the first pack run can move without another storage bottleneck.',
            time: DateTime.parse('2026-04-02T07:20:00Z'),
            actorId: 'talia-brooks',
            assetId: 'foundation-cold-room',
            requestId: 'foundation-request-3',
          ),
        ],
        'central-resource-storage-facility': [
          MockProjectHistoryEntry(
            id: 'ph-crs-1',
            projectId: 'central-resource-storage-facility',
            categoryLabel: 'Transfer',
            title: 'Kitchen cycle release queued',
            body:
                'The storage team scheduled dry-stock and cold-lane release windows for the next Tuesday and Thursday kitchen cycle.',
            time: DateTime.parse('2026-04-01T10:35:00Z'),
            actorId: 'omar-nguyen',
            assetId: 'foundation-central-storage',
            requestId: 'foundation-request-4b',
          ),
        ],
        'east-market-retrofit-pilot': [
          MockProjectHistoryEntry(
            id: 'ph-emr-1',
            projectId: 'east-market-retrofit-pilot',
            categoryLabel: 'Transfer',
            title: 'Warehouse tool reservation opened',
            body:
                'The retrofit team opened a reservation for survey tools and a forklift window so the first three-building insulation pass can stage cleanly.',
            time: DateTime.parse('2026-04-01T14:05:00Z'),
            actorId: 'carlos-rivera',
            assetId: 'foundation-tool-cage',
            requestId: 'foundation-request-2',
          ),
        ],
      },
      assetHistoryByAssetId = {
        'foundation-cold-room': [
          MockAssetHistoryEntry(
            id: 'ah-cold-1',
            assetId: 'foundation-cold-room',
            categoryLabel: 'Origin',
            title: 'Cold room installed at North Commons',
            body:
                'The refrigeration footprint was fitted into the kitchen site so produce, meal-kit staging, and short-cycle overflow could stay local to pickup.',
            time: DateTime.parse('2026-03-08T10:00:00Z'),
            locationLabel: 'North Commons Kitchen, Riverbend',
            actorLabel: 'Collective build crew',
            projectId: 'tuesday-thursday-community-kitchen',
          ),
          MockAssetHistoryEntry(
            id: 'ah-cold-2',
            assetId: 'foundation-cold-room',
            categoryLabel: 'Transfer',
            title: 'Shelf lanes reserved for meal-kit round',
            body:
                'Two shelves were scheduled for the first meal-kit pack run, with the receiving team confirming the Friday morning handoff window.',
            time: DateTime.parse('2026-04-02T07:20:00Z'),
            locationLabel: 'North Commons Cold Room',
            actorId: 'talia-brooks',
            projectId: 'meal-kit-round',
            requestId: 'foundation-request-3',
          ),
        ],
        'foundation-central-storage': [
          MockAssetHistoryEntry(
            id: 'ah-central-1',
            assetId: 'foundation-central-storage',
            categoryLabel: 'Origin',
            title: 'Warehouse release lanes activated',
            body:
                'Shared cold lanes, lumber reserve bays, and outgoing pickup staging were activated as the core release surface for the storage service.',
            time: DateTime.parse('2026-03-02T11:00:00Z'),
            locationLabel: 'Warehouse Seven',
            actorLabel: 'Central storage stewards',
            projectId: 'central-resource-storage-facility',
          ),
          MockAssetHistoryEntry(
            id: 'ah-central-2',
            assetId: 'foundation-central-storage',
            categoryLabel: 'Transfer',
            title: 'Kitchen cycle stock release scheduled',
            body:
                'Two cold shelf lanes and one dry-stock pallet were assigned to the next community-kitchen cycle before dispatch confirmation.',
            time: DateTime.parse('2026-04-01T10:35:00Z'),
            locationLabel: 'Warehouse Seven',
            actorId: 'omar-nguyen',
            projectId: 'tuesday-thursday-community-kitchen',
            requestId: 'foundation-request-4b',
          ),
        ],
        'foundation-tool-cage': [
          MockAssetHistoryEntry(
            id: 'ah-tool-1',
            assetId: 'foundation-tool-cage',
            categoryLabel: 'Origin',
            title: 'Survey and retrofit tool cage assembled',
            body:
                'Meters, staplers, reels, and drill kits were grouped into a shared cage so build crews could borrow a known baseline set instead of rebuilding kits by hand.',
            time: DateTime.parse('2026-03-12T15:00:00Z'),
            locationLabel: 'Warehouse Three',
            actorLabel: 'Tool-library stewards',
            projectId: 'cooperative-tool-library',
          ),
          MockAssetHistoryEntry(
            id: 'ah-tool-2',
            assetId: 'foundation-tool-cage',
            categoryLabel: 'Transfer',
            title: 'Retrofit pilot reservation opened',
            body:
                'Moisture meters and insulation staplers were reserved for the East Market retrofit survey window pending library dispatch confirmation.',
            time: DateTime.parse('2026-04-01T14:05:00Z'),
            locationLabel: 'Warehouse Three',
            actorId: 'carlos-rivera',
            projectId: 'east-market-retrofit-pilot',
            requestId: 'foundation-request-2',
          ),
        ],
      } {
    _ensureProjectCreatorsStartAsManagers();
    _normalizeStewardshipProjectManagers();
    _normalizeFoundationRequestAssignments();
  }

  final List<MockUser> users;
  final List<MockChannel> channels;
  final List<MockCommunity> communities;
  final List<MockProject> projects;
  final List<MockThread> threads;
  final List<MockPlan> plans;
  final List<MockNotificationItem> notifications;
  final List<MockDirectConversation> directConversations;
  final Map<String, List<MockDirectMessage>> directMessagesByConversationId;
  final List<MockFoundationAsset> foundationAssets;
  final List<MockFoundationRequest> foundationRequests;
  final List<MockLandManagementRequest> landManagementRequests;
  final List<MockSoftwareChangeRequest> softwareChangeRequests;
  final List<MockFoundationZone> foundationZones;
  final List<MockStorageBuilding> storageBuildings;
  final Map<String, List<MockComment>> projectCommentsById;
  final Map<String, List<MockComment>> threadCommentsById;
  final Map<String, List<MockComment>> updateCommentsById;
  final Map<String, List<MockComment>> personalPostCommentsById = {
    'personal-post-1': [
      MockComment(
        id: 'personal-post-1-comment-1',
        authorId: 'mara-holt',
        body:
            'This is better than forcing every note into Public before it is ready.',
        time: DateTime.parse('2026-04-02T16:05:00Z'),
        score: 8,
      ),
    ],
    'personal-post-2': [
      MockComment(
        id: 'personal-post-2-comment-1',
        authorId: 'anika-shaw',
        body:
            'Post the clean sketch when you have it. I want to compare it to the current intake layout.',
        time: DateTime.parse('2026-04-02T14:00:00Z'),
        score: 5,
      ),
    ],
  };
  final Map<String, List<MockProjectHistoryEntry>> projectHistoryByProjectId;
  final Map<String, List<MockAssetHistoryEntry>> assetHistoryByAssetId;
  final Map<String, List<String>> followingIdsByUser = <String, List<String>>{
    'anika-shaw': [
      'carlos-rivera',
      'mara-holt',
      'devon-lee',
      'leo-park',
      'rina-ortiz',
      'sarah-kim',
    ],
    'mara-holt': ['anika-shaw', 'devon-lee', 'sarah-kim', 'joel-morris'],
    'devon-lee': ['anika-shaw', 'mara-holt', 'carlos-rivera', 'joel-morris'],
  };
  final List<MockEvent> standaloneEvents = [
    MockEvent(
      id: 'standalone-event-birthday-dinner',
      title: 'Warehouse Birthday Dinner',
      timeLabel: 'Apr 7, 7:00 PM',
      location: 'Warehouse Three mezzanine',
      going: 6,
      description:
          'A one-off birthday dinner with a short toast for the tool-library crew and whoever the organizer directly invited.',
      rolesNeeded: ['1 dinner setup helper', '1 cleanup lead'],
      materials: ['Shared dish list', 'Folding tables', 'String lights'],
      outcome:
          'Celebrate, catch up, and keep the evening low-pressure without turning it into a project meeting.',
      managerIds: ['mara-holt'],
      discussion: [
        MockComment(
          id: 'event-comment-birthday-1',
          authorId: 'mara-holt',
          body:
              'Keep this one relaxed. I only want direct invites and a simple dish list.',
          time: DateTime.parse('2026-04-02T10:40:00Z'),
          score: 7,
        ),
      ],
      updates: [
        MockUpdate(
          id: 'event-update-birthday-1',
          authorId: 'mara-holt',
          title: 'Dinner list posted',
          body:
              'The potluck list is up and the mezzanine tables are already reserved for the evening.',
          time: DateTime.parse('2026-04-02T10:15:00Z'),
        ),
      ],
      creatorId: 'mara-holt',
      invitedUserIds: ['anika-shaw', 'devon-lee', 'sarah-kim'],
      isPrivate: true,
      createdAt: DateTime.parse('2026-04-01T18:20:00Z'),
      lastActivity: DateTime.parse('2026-04-02T11:10:00Z'),
    ),
    MockEvent(
      id: 'standalone-event-transit-rally',
      title: 'Transit Fare Protest Rally',
      timeLabel: 'Apr 12, 1:00 PM',
      location: 'East Market Station Plaza',
      going: 41,
      description:
          'A public rally and march opposing the proposed fare jump, with neighborhood speakers and sign-making before the walk begins.',
      rolesNeeded: [
        '2 marshals',
        '1 speaker coordinator',
        '2 sign-table hosts',
      ],
      materials: ['Sign board', 'Megaphone', 'Water station'],
      outcome:
          'Bring turnout to the station plaza, keep the route coordinated, and leave with clear next-step commitments.',
      managerIds: ['leo-park', 'anika-shaw'],
      discussion: [
        MockComment(
          id: 'event-comment-transit-1',
          authorId: 'anika-shaw',
          body: 'We need the speaker queue posted before the sign table opens.',
          time: DateTime.parse('2026-04-02T14:30:00Z'),
          score: 11,
        ),
      ],
      updates: [
        MockUpdate(
          id: 'event-update-transit-1',
          authorId: 'leo-park',
          title: 'Marshal check-in point confirmed',
          body:
              'Marshals will meet at the east entrance fifteen minutes before the first speaker starts.',
          time: DateTime.parse('2026-04-02T14:10:00Z'),
        ),
      ],
      creatorId: 'leo-park',
      channelIds: ['mutual-aid', 'housing-build'],
      communityIds: ['east-market-retrofit-circle'],
      createdAt: DateTime.parse('2026-04-01T09:30:00Z'),
      lastActivity: DateTime.parse('2026-04-02T15:05:00Z'),
    ),
    MockEvent(
      id: 'standalone-event-commons-picnic',
      title: 'North Commons Spring Picnic',
      timeLabel: 'Apr 14, 4:00 PM',
      location: 'North Commons lawn',
      going: 22,
      description:
          'A public one-off picnic for nearby growers, kitchen volunteers, and neighbors who want a lighter social event outside the work queue.',
      rolesNeeded: ['1 blanket host', '2 food table helpers'],
      materials: ['Picnic blankets', 'Potluck sign-up sheet', 'Water jugs'],
      outcome:
          'Meet new people, share updates casually, and keep the social side of the network visible.',
      managerIds: ['talia-brooks'],
      updates: [
        MockUpdate(
          id: 'event-update-picnic-1',
          authorId: 'talia-brooks',
          title: 'Potluck sheet is live',
          body:
              'Food sign-ups are open so the commons picnic stays light instead of becoming another logistics pile.',
          time: DateTime.parse('2026-04-01T19:00:00Z'),
        ),
      ],
      creatorId: 'talia-brooks',
      channelIds: ['food-agriculture'],
      communityIds: ['downtown-growers'],
      createdAt: DateTime.parse('2026-03-31T17:45:00Z'),
      lastActivity: DateTime.parse('2026-04-02T08:40:00Z'),
    ),
  ];
  final List<MockPersonalPost> personalPosts = [
    MockPersonalPost(
      id: 'personal-post-1',
      authorId: 'anika-shaw',
      body:
          'Trying to keep more coordination notes in the personal lane before deciding what actually needs a tagged public post.',
      createdAt: DateTime.parse('2026-04-02T15:45:00Z'),
      signalCount: 14,
    ),
    MockPersonalPost(
      id: 'personal-post-2',
      authorId: 'carlos-rivera',
      body:
          'Bench layout sketches finally make sense. I can probably turn today’s mess into a clean build note tomorrow.',
      createdAt: DateTime.parse('2026-04-02T13:35:00Z'),
      signalCount: 9,
    ),
    MockPersonalPost(
      id: 'personal-post-3',
      authorId: 'mara-holt',
      body:
          'Repair intake stopped overflowing for exactly one evening. I’m counting that as a real victory.',
      createdAt: DateTime.parse('2026-04-02T12:20:00Z'),
      signalCount: 11,
    ),
    MockPersonalPost(
      id: 'personal-post-4',
      authorId: 'devon-lee',
      body:
          'Warehouse three is finally quiet enough to hear yourself think. That means the storage relabel is working.',
      createdAt: DateTime.parse('2026-04-02T11:00:00Z'),
      signalCount: 7,
    ),
  ];
  final List<MockPersonalCommentShare> personalCommentShares = [];
  final Map<String, String> _pendingProjectUpdateTargets = <String, String>{};
  final Map<String, String> _pendingProjectCommentTargets = <String, String>{};
  final Map<String, String> _pendingThreadCommentTargets = <String, String>{};
  final Map<String, String> _directMessageReactionByActor = <String, String>{};

  void _ensureProjectCreatorsStartAsManagers() {
    for (var index = 0; index < projects.length; index++) {
      final project = projects[index];
      final managerIds = {...project.managerIds, project.authorId}.toList();
      final managerSeats = [...project.managerSeats];

      if (!managerSeats.any((seat) => seat.userId == project.authorId)) {
        managerSeats.add(
          MockGovernanceSeat(
            userId: project.authorId,
            approveCount: 14,
            rejectCount: 1,
          ),
        );
      }

      if (managerIds.length != project.managerIds.length ||
          managerSeats.length != project.managerSeats.length) {
        projects[index] = project.copyWith(
          managerIds: managerIds,
          managerSeats: managerSeats,
        );
      }
    }
  }

  void _normalizeStewardshipProjectManagers() {
    final stewardship = channelById('stewardship');
    if (stewardship == null) {
      return;
    }

    final moderatorIds = [
      for (final seat in stewardship.moderatorSeats) seat.userId,
    ];
    for (var index = 0; index < projects.length; index++) {
      final project = projects[index];
      if (!isStewardshipTaggedProject(project)) {
        continue;
      }

      projects[index] = project.copyWith(
        managerIds: moderatorIds,
        managerSeats: stewardship.moderatorSeats,
      );
    }
  }

  void _replaceProject(MockProject project) {
    final index = projects.indexWhere((item) => item.id == project.id);
    if (index != -1) {
      projects[index] = project;
    }
  }

  void _replacePlan(MockPlan plan) {
    final index = plans.indexWhere((item) => item.id == plan.id);
    if (index != -1) {
      plans[index] = plan;
    }
  }

  void _replaceFoundationRequest(MockFoundationRequest request) {
    final index = foundationRequests.indexWhere(
      (item) => item.id == request.id,
    );
    if (index != -1) {
      foundationRequests[index] = request;
    }
  }

  void _replaceFoundationAsset(MockFoundationAsset asset) {
    final index = foundationAssets.indexWhere((item) => item.id == asset.id);
    if (index != -1) {
      foundationAssets[index] = asset;
    }
  }

  void _replaceLandManagementRequest(MockLandManagementRequest request) {
    final index = landManagementRequests.indexWhere(
      (item) => item.id == request.id,
    );
    if (index != -1) {
      landManagementRequests[index] = request;
    }
  }

  void _replaceSoftwareChangeRequest(MockSoftwareChangeRequest request) {
    final index = softwareChangeRequests.indexWhere(
      (item) => item.id == request.id,
    );
    if (index != -1) {
      softwareChangeRequests[index] = request;
    }
  }

  void _normalizeFoundationRequestAssignments() {
    for (var index = 0; index < foundationRequests.length; index++) {
      final request = foundationRequests[index];
      final asset = foundationAssetById(request.assetId);
      if (asset == null) {
        continue;
      }

      final stewardProject = stewardProjectForAsset(asset);
      final shouldBlockForAcquisition =
          request.projectId != null &&
          request.createdByPlanId != null &&
          !acquisitionReadyForProject(request.projectId!);
      final statusLabel =
          shouldBlockForAcquisition &&
              !request.statusLabel.toLowerCase().contains('dispatch') &&
              !request.statusLabel.toLowerCase().contains('ready') &&
              !request.statusLabel.toLowerCase().contains('received')
          ? 'Requested · waiting on acquisition'
          : request.statusLabel;

      foundationRequests[index] = request.copyWith(
        assignedProjectId: stewardProject?.id,
        statusLabel: statusLabel,
        dispatchBlockedByAcquisition:
            shouldBlockForAcquisition || request.dispatchBlockedByAcquisition,
      );
    }
  }

  void _appendProjectHistory(String projectId, MockProjectHistoryEntry entry) {
    final items = projectHistoryByProjectId.putIfAbsent(projectId, () => []);
    items.insert(0, entry);
  }

  void _appendAssetHistory(String assetId, MockAssetHistoryEntry entry) {
    final items = assetHistoryByAssetId.putIfAbsent(assetId, () => []);
    items.insert(0, entry);
  }

  String _nextProjectHistoryId(String projectId) =>
      'ph-$projectId-${(projectHistoryByProjectId[projectId]?.length ?? 0) + 1}';

  String _nextAssetHistoryId(String assetId) =>
      'ah-$assetId-${(assetHistoryByAssetId[assetId]?.length ?? 0) + 1}';

  void _linkProjects(String firstProjectId, String secondProjectId) {
    final first = projectById(firstProjectId);
    final second = projectById(secondProjectId);
    if (first == null || second == null) {
      return;
    }

    if (!first.linkedProjectIds.contains(secondProjectId)) {
      _replaceProject(
        first.copyWith(
          linkedProjectIds: [...first.linkedProjectIds, secondProjectId],
        ),
      );
    }
    if (!second.linkedProjectIds.contains(firstProjectId)) {
      _replaceProject(
        second.copyWith(
          linkedProjectIds: [...second.linkedProjectIds, firstProjectId],
        ),
      );
    }
  }

  String _nextPlanId(String projectId, MockPlanKind kind) {
    final prefix = kind == MockPlanKind.production ? 'prod' : 'dist';
    final count =
        plans
            .where((item) => item.projectId == projectId && item.kind == kind)
            .length +
        1;
    return 'plan-$prefix-$projectId-$count';
  }

  String _nextGeneratedProjectId(String prefix, String title) {
    final slug = _normalizedAssetKey(title);
    var candidate = '$prefix-$slug';
    var suffix = 2;
    while (projectById(candidate) != null) {
      candidate = '$prefix-$slug-$suffix';
      suffix += 1;
    }
    return candidate;
  }

  String _stageLabel(MockProjectStage stage) {
    switch (stage) {
      case MockProjectStage.proposal:
        return 'Demand Signalling';
      case MockProjectStage.planning:
        return 'Planning';
      case MockProjectStage.funding:
        return 'Acquisition';
      case MockProjectStage.ongoing:
        return 'Ongoing';
      case MockProjectStage.completed:
        return 'Completed';
      case MockProjectStage.cancelled:
        return 'Cancelled';
    }
  }

  bool isStewardshipChannel(MockChannel channel) => channel.id == 'stewardship';

  bool isChannelModerator(MockChannel channel, String userId) =>
      channel.moderatorSeats.any((seat) => seat.userId == userId);

  bool canCreateTaggedProjectInChannel(MockChannel channel, String userId) {
    if (!isStewardshipChannel(channel)) {
      return true;
    }
    return isChannelModerator(channel, userId);
  }

  bool canCreateEventInChannel(MockChannel channel, String userId) {
    if (!isStewardshipChannel(channel)) {
      return true;
    }
    return isChannelModerator(channel, userId);
  }

  bool isStewardshipTaggedProject(MockProject project) =>
      project.channelIds.contains('stewardship');

  bool isProjectManager(MockProject project, String userId) =>
      isStewardshipTaggedProject(project)
      ? (channelById(
              'stewardship',
            )?.moderatorSeats.any((seat) => seat.userId == userId) ??
            false)
      : project.managerIds.contains(userId);

  bool isProjectMember(MockProject project, String userId) =>
      project.memberIds.contains(userId) || isProjectManager(project, userId);

  List<MockProject> projectsManagedByUser(String userId) =>
      projects.where((project) => isProjectManager(project, userId)).toList();

  List<MockProject> landManagementProjects() => projects
      .where((project) => project.serviceKind == MockServiceKind.landManagement)
      .toList();

  bool acquisitionReadyForProject(String projectId) {
    final project = projectById(projectId);
    final fund = project?.fund;
    if (project == null || fund == null) {
      return true;
    }
    return fund.raised >= fund.goal;
  }

  List<MockGovernanceSeat> managerSeatsForProject(MockProject project) {
    if (isStewardshipTaggedProject(project)) {
      return channelById('stewardship')?.moderatorSeats ?? const [];
    }

    final seatsById = {
      for (final seat in project.managerSeats) seat.userId: seat,
    };
    return [
      for (final userId in project.managerIds)
        seatsById[userId] ??
            MockGovernanceSeat(
              userId: userId,
              approveCount: 12,
              rejectCount: 1,
            ),
    ];
  }

  List<MockProjectHistoryEntry> projectHistoryForProject(String projectId) {
    final items = [...?projectHistoryByProjectId[projectId]];
    items.sort((left, right) => right.time.compareTo(left.time));
    return items;
  }

  List<MockAssetHistoryEntry> assetHistoryForAsset(String assetId) {
    final asset = foundationAssetById(assetId);
    final items = [...?assetHistoryByAssetId[assetId]];
    items.sort((left, right) => right.time.compareTo(left.time));
    if (items.isNotEmpty || asset == null || asset.groupLabel == 'Land') {
      return items;
    }
    return _syntheticAssetHistoryForAsset(asset);
  }

  List<MockAssetHistoryEntry> _syntheticAssetHistoryForAsset(
    MockFoundationAsset asset,
  ) {
    final entries = <MockAssetHistoryEntry>[];
    final stewardProject = stewardProjectForAsset(asset);
    final landAsset = asset.landAssetId == null
        ? null
        : foundationAssetById(asset.landAssetId!);
    final storageBuilding = asset.buildingId == null
        ? null
        : storageBuildingById(asset.buildingId!);

    if (storageBuilding != null) {
      final storageProject = projectById(storageBuilding.projectId);
      entries.add(
        MockAssetHistoryEntry(
          id: 'synthetic-${asset.id}-storage',
          assetId: asset.id,
          categoryLabel: 'Storage',
          title: 'Placed in ${storageBuilding.name}',
          body: storageProject == null
              ? 'This asset is currently recorded inside ${storageBuilding.name} so the storage chain stays visible.'
              : 'This asset is currently recorded inside ${storageBuilding.name} under ${storageProject.title}, keeping the storage chain visible.',
          time: prototypeNow.subtract(const Duration(hours: 4)),
          locationLabel: landAsset?.locationLabel ?? asset.locationLabel,
          projectId: storageProject?.id,
        ),
      );
    }

    if (landAsset != null) {
      entries.add(
        MockAssetHistoryEntry(
          id: 'synthetic-${asset.id}-land',
          assetId: asset.id,
          categoryLabel: 'Land link',
          title: 'Linked to ${landAsset.name}',
          body:
              'This asset stays attached to ${landAsset.name} so its physical location remains visible even when it moves through storage or steward projects.',
          time: prototypeNow.subtract(const Duration(days: 2)),
          locationLabel: landAsset.locationLabel,
        ),
      );
    }

    if (stewardProject != null) {
      entries.add(
        MockAssetHistoryEntry(
          id: 'synthetic-${asset.id}-steward',
          assetId: asset.id,
          categoryLabel: 'Stewardship',
          title: 'Assigned to ${stewardProject.title}',
          body:
              '${stewardProject.title} currently stewards this asset and keeps its custody visible in the mock inventory chain.',
          time: prototypeNow.subtract(const Duration(days: 1)),
          locationLabel: asset.locationLabel,
          projectId: stewardProject.id,
        ),
      );
    }

    if (entries.isEmpty) {
      entries.add(
        MockAssetHistoryEntry(
          id: 'synthetic-${asset.id}-record',
          assetId: asset.id,
          categoryLabel: 'Asset record',
          title: 'Recorded in the asset ledger',
          body:
              'This mock asset now carries a visible history record even when no earlier transfer notes were seeded.',
          time: prototypeNow.subtract(const Duration(days: 3)),
          locationLabel: asset.locationLabel,
        ),
      );
    }

    entries.sort((left, right) => right.time.compareTo(left.time));
    return entries;
  }

  MockFoundationRequest? foundationRequestById(String id) => foundationRequests
      .where((item) => item.id == id)
      .cast<MockFoundationRequest?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockFoundationAsset? landAssetForProject(String projectId) => foundationAssets
      .where(
        (item) =>
            item.groupLabel == 'Land' &&
            item.linkedProjectIds.contains(projectId),
      )
      .cast<MockFoundationAsset?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockProject? landManagementProjectForLandAsset(
    MockFoundationAsset landAsset,
  ) {
    if (landAsset.stewardProjectId != null) {
      final explicit = projectById(landAsset.stewardProjectId!);
      if (explicit?.serviceKind == MockServiceKind.landManagement) {
        return explicit;
      }
    }

    return linkedProjectsForLandAsset(landAsset)
        .where(
          (project) => project.serviceKind == MockServiceKind.landManagement,
        )
        .firstOrNull;
  }

  MockProject? stewardProjectForLandAsset(MockFoundationAsset landAsset) {
    final managingService = landManagementProjectForLandAsset(landAsset);
    if (managingService != null) {
      return managingService;
    }

    final linked = linkedProjectsForLandAsset(landAsset);
    return linked.firstOrNull;
  }

  MockProject? stewardProjectForAsset(MockFoundationAsset asset) {
    if (asset.groupLabel == 'Land') {
      return stewardProjectForLandAsset(asset);
    }

    if (asset.stewardProjectId != null) {
      final steward = projectById(asset.stewardProjectId!);
      if (steward != null) {
        return steward;
      }
    }

    final directLinked = linkedProjectsForAsset(asset);
    final directService = directLinked
        .where((project) => project.type == MockProjectType.service)
        .firstOrNull;
    if (directService != null) {
      return directService;
    }

    if (asset.landAssetId != null) {
      final landAsset = foundationAssetById(asset.landAssetId!);
      if (landAsset != null) {
        final landSteward = landManagementProjectForLandAsset(landAsset);
        if (landSteward != null) {
          return landSteward;
        }
      }
    }

    if (directLinked.isNotEmpty) {
      return directLinked.first;
    }

    return null;
  }

  MockFoundationAsset assetForInventoryItem(
    MockProject project,
    MockAssetStockItem item,
  ) {
    if (item.assetId != null) {
      final linked = foundationAssetById(item.assetId!);
      if (linked != null) {
        return linked;
      }
    }

    final projectAssets = foundationAssetsForProject(project.id);
    final normalizedItemName = _normalizedAssetKey(item.name);
    final byName = projectAssets.firstWhere(
      (asset) => _normalizedAssetKey(asset.name) == normalizedItemName,
      orElse: () => _fallbackInventoryAsset(project, item),
    );
    if (byName.id != _inventoryAssetId(project, item)) {
      return byName;
    }

    final buildingMatch = item.buildingId == null
        ? null
        : projectAssets
              .where((asset) => asset.buildingId == item.buildingId)
              .toList();
    if (buildingMatch != null && buildingMatch.isNotEmpty) {
      final nonLand = buildingMatch
          .where((asset) => asset.groupLabel != 'Land')
          .toList();
      if (nonLand.length == 1) {
        return nonLand.first;
      }
      if (nonLand.isNotEmpty) {
        final closest = nonLand.firstWhere(
          (asset) =>
              normalizedItemName.contains(
                _normalizedAssetKey(asset.kindLabel),
              ) ||
              _normalizedAssetKey(asset.kindLabel).contains(normalizedItemName),
          orElse: () => nonLand.first,
        );
        return closest;
      }
    }

    final nonLandProjectAssets = projectAssets
        .where((asset) => asset.groupLabel != 'Land')
        .toList();
    if (item.isSiteAsset) {
      final landAsset = landAssetForProject(project.id);
      if (landAsset != null) {
        return landAsset;
      }
    }
    if (nonLandProjectAssets.length == 1) {
      return nonLandProjectAssets.first;
    }

    return _fallbackInventoryAsset(project, item);
  }

  MockFoundationAsset _fallbackInventoryAsset(
    MockProject project,
    MockAssetStockItem item,
  ) {
    final landAsset = landAssetForProject(project.id);
    final groupLabel = item.isSiteAsset
        ? 'Land'
        : project.type == MockProjectType.service
        ? 'Storage'
        : 'Equipment';
    final kindLabel = item.isSiteAsset
        ? 'Site'
        : item.requestability == MockAssetRequestability.projectOnly
        ? 'Shared equipment'
        : 'Shared asset';

    return MockFoundationAsset(
      id: _inventoryAssetId(project, item),
      name: item.name,
      groupLabel: groupLabel,
      kindLabel: kindLabel,
      summary:
          item.note ??
          '${item.name} is currently represented from ${project.title} inventory records.',
      locationLabel: landAsset?.locationLabel ?? project.locationLabel,
      zoneId: landAsset?.zoneId ?? 'inventory-${project.id}',
      availabilityLabel: item.statusLabel,
      requestPolicyLabel: _requestabilityPolicyLabel(item.requestability),
      landAssetId: item.isSiteAsset ? null : landAsset?.id,
      buildingId: item.buildingId,
      linkedProjectIds: [project.id],
    );
  }

  String _inventoryAssetId(MockProject project, MockAssetStockItem item) =>
      'inventory-${project.id}-${_normalizedAssetKey(item.name)}';

  String _normalizedAssetKey(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  String _requestabilityPolicyLabel(MockAssetRequestability requestability) {
    switch (requestability) {
      case MockAssetRequestability.both:
        return 'Personal and project requests';
      case MockAssetRequestability.personalOnly:
        return 'Personal requests only';
      case MockAssetRequestability.projectOnly:
        return 'Project requests only';
      case MockAssetRequestability.unavailable:
        return 'Unavailable for request';
    }
  }

  String _softwareChangeHistoryTitle(MockSoftwareChangeRequestStatus status) {
    switch (status) {
      case MockSoftwareChangeRequestStatus.proposed:
        return 'Software change proposed';
      case MockSoftwareChangeRequestStatus.underReview:
        return 'Software change moved to review';
      case MockSoftwareChangeRequestStatus.changesRequested:
        return 'Software change returned with requested changes';
      case MockSoftwareChangeRequestStatus.merged:
        return 'Software change merged';
      case MockSoftwareChangeRequestStatus.rejected:
        return 'Software change rejected';
    }
  }

  List<MockFoundationRequest> transferRequestsForProject(String projectId) {
    final managedAssetIds = foundationAssetsForProject(
      projectId,
    ).map((item) => item.id).toSet();
    final items = foundationRequests.where((item) {
      return item.projectId == projectId ||
          item.assignedProjectId == projectId ||
          managedAssetIds.contains(item.assetId);
    }).toList();
    items.sort((left, right) => right.id.compareTo(left.id));
    return items;
  }

  void optIntoProjectManagement(String projectId, String userId) {
    final project = projectById(projectId);
    if (project == null ||
        isStewardshipTaggedProject(project) ||
        !isProjectMember(project, userId) ||
        isProjectManager(project, userId)) {
      return;
    }

    final updatedProject = project.copyWith(
      managerIds: [...project.managerIds, userId],
      managerSeats: [
        ...managerSeatsForProject(project),
        MockGovernanceSeat(userId: userId, approveCount: 12, rejectCount: 1),
      ],
      lastActivity: prototypeNow,
    );
    _replaceProject(updatedProject);

    _appendProjectHistory(
      project.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(project.id),
        projectId: project.id,
        categoryLabel: 'Manager',
        title: 'New project manager joined',
        body: 'A project member opted into manager responsibilities.',
        time: prototypeNow,
        actorId: userId,
      ),
    );
  }

  void stepDownAsProjectManager(String projectId, String userId) {
    final project = projectById(projectId);
    if (project == null ||
        isStewardshipTaggedProject(project) ||
        !isProjectManager(project, userId)) {
      return;
    }

    final updatedProject = project.copyWith(
      managerIds: project.managerIds.where((item) => item != userId).toList(),
      managerSeats: project.managerSeats
          .where((seat) => seat.userId != userId)
          .toList(),
      lastActivity: prototypeNow,
    );
    _replaceProject(updatedProject);

    _appendProjectHistory(
      project.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(project.id),
        projectId: project.id,
        categoryLabel: 'Manager',
        title: 'Manager stepped down',
        body: 'A current manager stepped out of direct project operations.',
        time: prototypeNow,
        actorId: userId,
      ),
    );
  }

  void changeProjectStage(
    String projectId,
    MockProjectStage stage,
    String actorId,
  ) {
    final project = projectById(projectId);
    if (project == null || project.stage == stage) {
      return;
    }

    final previousLabel = _stageLabel(project.stage);
    final nextLabel = _stageLabel(stage);
    _replaceProject(project.copyWith(stage: stage, lastActivity: prototypeNow));

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Stage',
        title: 'Moved to $nextLabel',
        body: 'Lifecycle status changed from $previousLabel to $nextLabel.',
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void postProjectUpdate(
    String projectId, {
    required String actorId,
    required String title,
    required String body,
  }) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    final update = MockUpdate(
      id: 'u-$projectId-${project.updates.length + 1}',
      authorId: actorId,
      title: title,
      body: body,
      time: prototypeNow,
    );

    _replaceProject(
      project.copyWith(
        updates: [update, ...project.updates],
        lastActivity: prototypeNow,
      ),
    );
    updateCommentsById[update.id] = [];

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Update',
        title: 'Manager update posted',
        body: title,
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void updateProjectAcquisitionDetails(
    String projectId, {
    required String actorId,
    required String title,
    required String deadlineLabel,
    required int goal,
    required int raised,
  }) {
    final project = projectById(projectId);
    final fund = project?.fund;
    if (project == null || fund == null) {
      return;
    }

    _replaceProject(
      project.copyWith(
        fund: fund.copyWith(
          title: title,
          deadlineLabel: deadlineLabel,
          goal: goal,
          raised: raised,
        ),
        lastActivity: prototypeNow,
      ),
    );

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Acquisition',
        title: 'Acquisition details updated',
        body:
            'Goal, raised total, label, or deadline details were revised by a project manager.',
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void submitProjectPlan(
    String projectId, {
    required String actorId,
    required MockPlanKind kind,
    required String title,
    required String summary,
    required String body,
    required String estimatedExecutionLabel,
    required List<String> checklist,
    required List<MockPlanAssetNeed> assetNeeds,
    required List<MockPlanCostLine> costLines,
    MockPlanLandRouting? landRouting,
  }) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    final plan = MockPlan(
      id: _nextPlanId(projectId, kind),
      projectId: projectId,
      kind: kind,
      title: title,
      summary: summary,
      status: 'Voting Open',
      approved: false,
      version:
          'Draft ${plans.where((item) => item.projectId == projectId).length + 1}',
      proposerId: actorId,
      yes: 0,
      no: 0,
      abstain: 0,
      threshold: '60% participation threshold',
      closesLabel: 'Closes in 3 days',
      createdAt: prototypeNow,
      body: body,
      checklist: checklist,
      discussion: const [],
      estimatedExecutionLabel: estimatedExecutionLabel,
      assetNeeds: assetNeeds,
      costLines: costLines,
      landRouting: landRouting,
    );

    plans.insert(0, plan);
    final planIds = kind == MockPlanKind.production
        ? [plan.id, ...project.productionPlanIds]
        : [plan.id, ...project.distributionPlanIds];
    _replaceProject(
      kind == MockPlanKind.production
          ? project.copyWith(
              productionPlanIds: planIds,
              lastActivity: prototypeNow,
            )
          : project.copyWith(
              distributionPlanIds: planIds,
              lastActivity: prototypeNow,
            ),
    );

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Plan',
        title:
            '${kind == MockPlanKind.production ? 'Production' : 'Distribution'} plan submitted',
        body: title,
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void approveProjectPlan(String planId, String actorId) {
    final plan = planById(planId);
    if (plan == null || plan.approved) {
      return;
    }

    final approvedPlan = plan.copyWith(
      approved: true,
      status: 'Approved',
      version: 'Approved',
      threshold: 'Threshold met',
      closesLabel: 'Approved just now',
      yes: plan.yes == 0 ? 1 : plan.yes,
    );
    _replacePlan(approvedPlan);

    final project = projectById(plan.projectId);
    if (project != null) {
      _replaceProject(project.copyWith(lastActivity: prototypeNow));
      _appendProjectHistory(
        project.id,
        MockProjectHistoryEntry(
          id: _nextProjectHistoryId(project.id),
          projectId: project.id,
          categoryLabel: 'Plan',
          title:
              '${plan.kind == MockPlanKind.production ? 'Production' : 'Distribution'} plan approved',
          body: plan.title,
          time: prototypeNow,
          actorId: actorId,
        ),
      );
      _maybeFinalizeLandRoutingForApprovedPlan(approvedPlan, actorId);
      _maybeGenerateTransferRequestsForApprovedPlans(project.id, actorId);
    }
  }

  void _maybeFinalizeLandRoutingForApprovedPlan(MockPlan plan, String actorId) {
    final routing = plan.landRouting;
    if (routing == null) {
      return;
    }

    switch (routing.managementSelection) {
      case MockLandManagementSelection.existingService:
        if (routing.existingProjectId == null || routing.requestId != null) {
          return;
        }
        createLandManagementRequest(
          planId: plan.id,
          requestingProjectId: plan.projectId,
          targetProjectId: routing.existingProjectId!,
          requesterId: actorId,
          action: routing.action,
          landAssetId: routing.landAssetId,
          note: routing.action == MockLandPlanAction.purchase
              ? 'Approved plan now needs land-management acceptance before collective land execution can proceed.'
              : 'Approved plan now needs land-management acceptance before the tied land asset can move under this project workflow.',
        );
      case MockLandManagementSelection.createNewService:
        if (routing.resolvedProjectId != null) {
          return;
        }
        final createdProject = _createLandManagementServiceForApprovedPlan(
          plan,
        );
        final refreshedPlan = planById(plan.id) ?? plan;
        _replacePlan(
          refreshedPlan.copyWith(
            status: 'Approved · land-management service created',
            landRouting: (refreshedPlan.landRouting ?? routing).copyWith(
              resolvedProjectId: createdProject.id,
              statusLabel: 'New land-management service created after approval',
            ),
          ),
        );
    }
  }

  MockProject _createLandManagementServiceForApprovedPlan(MockPlan plan) {
    final sourceProject = projectById(plan.projectId)!;
    final routing = plan.landRouting!;
    final title = (routing.newServiceTitle ?? '').trim().isEmpty
        ? '${sourceProject.title} Land Service'
        : routing.newServiceTitle!.trim();
    final summary = (routing.newServiceSummary ?? '').trim().isEmpty
        ? 'Land-management service created from the approved plan for ${sourceProject.title}.'
        : routing.newServiceSummary!.trim();
    final newProject = MockProject(
      id: _nextGeneratedProjectId('land-service', title),
      title: title,
      type: MockProjectType.service,
      stage: MockProjectStage.ongoing,
      authorId: plan.proposerId,
      managerIds: [plan.proposerId],
      managerSeats: [
        MockGovernanceSeat(
          userId: plan.proposerId,
          approveCount: 12,
          rejectCount: 1,
        ),
      ],
      memberIds: [plan.proposerId],
      channelIds: sourceProject.channelIds,
      communityIds: sourceProject.communityIds,
      locationLabel: sourceProject.locationLabel,
      locationDistrict: sourceProject.locationDistrict,
      summary: summary,
      body:
          '$summary This service appeared after the approval of ${plan.title} and starts with the proposer as the first manager.',
      demandCount: 0,
      awarenessCount: 0,
      comments: 0,
      createdAt: prototypeNow,
      lastActivity: prototypeNow,
      updates: const [],
      events: const [],
      tasks: const [],
      linkedProjectIds: [sourceProject.id],
      productionPlanIds: const [],
      distributionPlanIds: const [],
      availability: 'Newly created land-management coverage',
      serviceKind: MockServiceKind.landManagement,
      serviceMode: 'Land management and site-use routing',
      serviceCadence: 'Continuous weekly service',
      assetRequestPolicy:
          'Site-use and tied-to-land-asset requests route through this service.',
    );
    projects.insert(0, newProject);
    _linkProjects(sourceProject.id, newProject.id);

    if (routing.landAssetId != null) {
      final asset = foundationAssetById(routing.landAssetId!);
      if (asset != null) {
        _replaceFoundationAsset(
          asset.copyWith(
            stewardProjectId: newProject.id,
            linkedProjectIds: [
              ...asset.linkedProjectIds,
              if (!asset.linkedProjectIds.contains(newProject.id))
                newProject.id,
            ],
          ),
        );
      }
    }

    _appendProjectHistory(
      sourceProject.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(sourceProject.id),
        projectId: sourceProject.id,
        categoryLabel: 'Land management',
        title: 'Land-management service created',
        body: '$title was created after ${plan.title} was approved.',
        time: prototypeNow,
        actorId: plan.proposerId,
      ),
    );
    _appendProjectHistory(
      newProject.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(newProject.id),
        projectId: newProject.id,
        categoryLabel: 'Land management',
        title: 'Service created from approved plan',
        body:
            'This service was created from ${sourceProject.title} after ${plan.title} was approved.',
        time: prototypeNow,
        actorId: plan.proposerId,
      ),
    );

    return newProject;
  }

  void _maybeGenerateTransferRequestsForApprovedPlans(
    String projectId,
    String actorId,
  ) {
    final approvedProduction = plansForProject(
      projectId,
      MockPlanKind.production,
    ).where((item) => item.approved).toList();
    final approvedDistribution = plansForProject(
      projectId,
      MockPlanKind.distribution,
    ).where((item) => item.approved).toList();
    if (approvedProduction.isEmpty || approvedDistribution.isEmpty) {
      return;
    }

    for (final plan in [...approvedProduction, ...approvedDistribution]) {
      for (final need in plan.assetNeeds) {
        final assetId = need.linkedAssetId;
        if (assetId == null) {
          continue;
        }
        final duplicate = foundationRequests.any(
          (request) =>
              request.projectId == projectId &&
              request.assetId == assetId &&
              request.createdByPlanId == plan.id,
        );
        if (duplicate) {
          continue;
        }

        final noteParts = <String>[
          '${plan.title}: ${need.label} (${need.quantityLabel})',
          if (need.note != null && need.note!.isNotEmpty) need.note!,
        ];
        createProjectTransferRequest(
          projectId,
          actorId: actorId,
          assetId: assetId,
          needByLabel: plan.estimatedExecutionLabel ?? 'Plan-linked timing',
          note: noteParts.join(' · '),
          createdByPlanId: plan.id,
          dispatchBlockedByAcquisition: !acquisitionReadyForProject(projectId),
        );
      }
    }
  }

  void addProjectAcquisitionItem(
    String projectId, {
    required String actorId,
    required String label,
    required int cost,
  }) {
    final project = projectById(projectId);
    final fund = project?.fund;
    if (project == null || fund == null) {
      return;
    }

    final items = [
      ...fund.purchaseItems,
      MockFundItem(label: label, cost: cost),
    ];
    final total = items.fold<int>(0, (sum, item) => sum + item.cost);
    _replaceProject(
      project.copyWith(
        fund: fund.copyWith(
          purchaseItems: items,
          goal: total > fund.goal ? total : fund.goal,
        ),
        lastActivity: prototypeNow,
      ),
    );

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Acquisition',
        title: 'Acquisition line item added',
        body: '$label was added to the purchase list.',
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void addProjectTask(
    String projectId, {
    required String actorId,
    required String title,
    required List<String> checkpoints,
  }) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    final task = MockTask(
      id: 'task-$projectId-${project.tasks.length + 1}',
      title: title,
      status: 'Todo',
      checkpoints: [
        for (final checkpoint in checkpoints)
          MockTaskCheckpoint(label: checkpoint),
      ],
    );

    _replaceProject(
      project.copyWith(
        tasks: [task, ...project.tasks],
        lastActivity: prototypeNow,
      ),
    );

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Task',
        title: 'Task added',
        body: title,
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void updateProjectTaskStatus(
    String projectId,
    String taskId,
    String status,
    String actorId,
  ) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    final tasks = project.tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }
      return task.copyWith(status: status);
    }).toList();
    final task = tasks.firstWhere((item) => item.id == taskId);

    _replaceProject(project.copyWith(tasks: tasks, lastActivity: prototypeNow));

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Task',
        title: 'Task status changed',
        body: '${task.title} is now marked $status.',
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void addProjectTaskCheckpoint(
    String projectId,
    String taskId,
    String label,
    String actorId,
  ) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    final tasks = project.tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }
      return task.copyWith(
        checkpoints: [
          ...task.checkpoints,
          MockTaskCheckpoint(label: label),
        ],
      );
    }).toList();
    final task = tasks.firstWhere((item) => item.id == taskId);

    _replaceProject(project.copyWith(tasks: tasks, lastActivity: prototypeNow));

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Task',
        title: 'Checkpoint added',
        body: 'A new checkpoint was added to ${task.title}.',
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void toggleProjectTaskCheckpoint(
    String projectId,
    String taskId,
    int checkpointIndex,
    String actorId,
  ) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    MockTask? updatedTask;
    final tasks = project.tasks.map((task) {
      if (task.id != taskId || checkpointIndex >= task.checkpoints.length) {
        return task;
      }
      final checkpoints = [...task.checkpoints];
      checkpoints[checkpointIndex] = checkpoints[checkpointIndex].copyWith(
        done: !checkpoints[checkpointIndex].done,
      );
      updatedTask = task.copyWith(checkpoints: checkpoints);
      return updatedTask!;
    }).toList();

    if (updatedTask == null) {
      return;
    }

    _replaceProject(project.copyWith(tasks: tasks, lastActivity: prototypeNow));

    final checkpoint = updatedTask!.checkpoints[checkpointIndex];
    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Task',
        title: checkpoint.done ? 'Checkpoint completed' : 'Checkpoint reopened',
        body: '${updatedTask!.title}: ${checkpoint.label}',
        time: prototypeNow,
        actorId: actorId,
      ),
    );
  }

  void createLandManagementRequest({
    required String planId,
    required String requestingProjectId,
    required String targetProjectId,
    required String requesterId,
    required MockLandPlanAction action,
    String? landAssetId,
    String? note,
  }) {
    final plan = planById(planId);
    final requestingProject = projectById(requestingProjectId);
    final targetProject = projectById(targetProjectId);
    if (plan == null || requestingProject == null || targetProject == null) {
      return;
    }

    final request = MockLandManagementRequest(
      id: 'land-management-request-${landManagementRequests.length + 1}',
      planId: planId,
      requestingProjectId: requestingProjectId,
      targetProjectId: targetProjectId,
      requesterId: requesterId,
      action: action,
      status: MockLandManagementRequestStatus.pending,
      createdAt: prototypeNow,
      landAssetId: landAssetId,
      note: note,
    );
    landManagementRequests.insert(0, request);
    _linkProjects(requestingProjectId, targetProjectId);

    final routing = plan.landRouting;
    if (routing != null) {
      _replacePlan(
        plan.copyWith(
          status: 'Approved · awaiting land-management acceptance',
          landRouting: routing.copyWith(
            requestId: request.id,
            statusLabel: 'Awaiting ${targetProject.title} acceptance',
          ),
        ),
      );
    }

    _appendProjectHistory(
      requestingProjectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(requestingProjectId),
        projectId: requestingProjectId,
        categoryLabel: 'Land management',
        title: 'Land-management request opened',
        body:
            '${targetProject.title} was asked to manage ${action == MockLandPlanAction.purchase ? 'planned land work' : 'the selected land asset'} for ${plan.title}.',
        time: prototypeNow,
        actorId: requesterId,
        requestId: request.id,
      ),
    );
    _appendProjectHistory(
      targetProjectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(targetProjectId),
        projectId: targetProjectId,
        categoryLabel: 'Land management',
        title: 'Incoming land-management request',
        body:
            '${requestingProject.title} is waiting for management acceptance on ${plan.title}.',
        time: prototypeNow,
        actorId: requesterId,
        requestId: request.id,
      ),
    );

    if (landAssetId != null) {
      final landAsset = foundationAssetById(landAssetId);
      if (landAsset != null) {
        _appendAssetHistory(
          landAsset.id,
          MockAssetHistoryEntry(
            id: _nextAssetHistoryId(landAsset.id),
            assetId: landAsset.id,
            categoryLabel: 'Land management',
            title: 'Management request opened',
            body:
                '${targetProject.title} was asked to manage this land asset through ${plan.title}.',
            time: prototypeNow,
            locationLabel: landAsset.locationLabel,
            actorId: requesterId,
            projectId: targetProjectId,
            requestId: request.id,
          ),
        );
      }
    }
  }

  void respondToLandManagementRequest(
    String requestId, {
    required String actorId,
    required bool accept,
  }) {
    final request = landManagementRequestById(requestId);
    if (request == null) {
      return;
    }

    final plan = planById(request.planId);
    final targetProject = projectById(request.targetProjectId);
    final sourceProject = projectById(request.requestingProjectId);
    if (plan == null || targetProject == null || sourceProject == null) {
      return;
    }

    final nextStatus = accept
        ? MockLandManagementRequestStatus.accepted
        : MockLandManagementRequestStatus.refused;
    _replaceLandManagementRequest(request.copyWith(status: nextStatus));

    final routing = plan.landRouting;
    if (routing != null) {
      _replacePlan(
        plan.copyWith(
          status: accept
              ? 'Approved · land-management accepted'
              : 'Approved · land-management refused',
          landRouting: routing.copyWith(
            resolvedProjectId: accept
                ? targetProject.id
                : routing.resolvedProjectId,
            statusLabel: accept
                ? '${targetProject.title} accepted management'
                : '${targetProject.title} refused management',
          ),
        ),
      );
    }

    if (accept) {
      _linkProjects(sourceProject.id, targetProject.id);
      if (request.landAssetId != null) {
        final landAsset = foundationAssetById(request.landAssetId!);
        if (landAsset != null) {
          _replaceFoundationAsset(
            landAsset.copyWith(
              stewardProjectId: targetProject.id,
              linkedProjectIds: [
                ...landAsset.linkedProjectIds,
                if (!landAsset.linkedProjectIds.contains(targetProject.id))
                  targetProject.id,
              ],
            ),
          );
        }
      }
    }

    _appendProjectHistory(
      targetProject.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(targetProject.id),
        projectId: targetProject.id,
        categoryLabel: 'Land management',
        title: accept
            ? 'Land-management request accepted'
            : 'Land-management request refused',
        body:
            '${sourceProject.title} ${accept ? 'can now route through this service' : 'needs a different land-management service'} for ${plan.title}.',
        time: prototypeNow,
        actorId: actorId,
        requestId: request.id,
      ),
    );
    _appendProjectHistory(
      sourceProject.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(sourceProject.id),
        projectId: sourceProject.id,
        categoryLabel: 'Land management',
        title: accept
            ? 'Land-management service accepted'
            : 'Land-management service refused',
        body:
            '${targetProject.title} ${accept ? 'accepted' : 'refused'} management for ${plan.title}.',
        time: prototypeNow,
        actorId: actorId,
        requestId: request.id,
      ),
    );

    if (request.landAssetId != null) {
      final landAsset = foundationAssetById(request.landAssetId!);
      if (landAsset != null) {
        _appendAssetHistory(
          landAsset.id,
          MockAssetHistoryEntry(
            id: _nextAssetHistoryId(landAsset.id),
            assetId: landAsset.id,
            categoryLabel: 'Land management',
            title: accept ? 'Management accepted' : 'Management refused',
            body:
                '${targetProject.title} ${accept ? 'accepted' : 'refused'} the management request linked to ${plan.title}.',
            time: prototypeNow,
            locationLabel: landAsset.locationLabel,
            actorId: actorId,
            projectId: targetProject.id,
            requestId: request.id,
          ),
        );
      }
    }
  }

  void submitSoftwareChangeRequest(
    String projectId, {
    required String requesterId,
    required String repoTarget,
    required String diffSummary,
    String? note,
  }) {
    final project = projectById(projectId);
    if (project == null) {
      return;
    }

    final request = MockSoftwareChangeRequest(
      id: 'software-change-${softwareChangeRequests.length + 1}',
      projectId: projectId,
      requesterId: requesterId,
      repoTarget: repoTarget,
      diffSummary: diffSummary,
      status: MockSoftwareChangeRequestStatus.proposed,
      createdAt: prototypeNow,
      note: note,
    );
    softwareChangeRequests.insert(0, request);
    _replaceProject(project.copyWith(lastActivity: prototypeNow));

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Software change',
        title: 'Change request submitted',
        body: '${request.repoTarget} · ${request.diffSummary}',
        time: prototypeNow,
        actorId: requesterId,
        requestId: request.id,
      ),
    );
  }

  void updateSoftwareChangeRequestStatus(
    String requestId, {
    required String actorId,
    required MockSoftwareChangeRequestStatus status,
    String? reviewNote,
  }) {
    final request = softwareChangeRequestById(requestId);
    if (request == null) {
      return;
    }

    _replaceSoftwareChangeRequest(
      request.copyWith(status: status, reviewNote: reviewNote),
    );
    final project = projectById(request.projectId);
    if (project == null) {
      return;
    }

    _replaceProject(project.copyWith(lastActivity: prototypeNow));
    _appendProjectHistory(
      project.id,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(project.id),
        projectId: project.id,
        categoryLabel: 'Software change',
        title: _softwareChangeHistoryTitle(status),
        body: '${request.repoTarget} · ${request.diffSummary}',
        time: prototypeNow,
        actorId: actorId,
        requestId: request.id,
      ),
    );
  }

  void createProjectTransferRequest(
    String projectId, {
    required String actorId,
    required String assetId,
    required String needByLabel,
    required String note,
    String? createdByPlanId,
    bool dispatchBlockedByAcquisition = false,
  }) {
    final project = projectById(projectId);
    final asset = foundationAssetById(assetId);
    if (project == null || asset == null) {
      return;
    }

    final stewardProject = stewardProjectForAsset(asset);
    final request = MockFoundationRequest(
      id: 'foundation-request-${foundationRequests.length + 1}',
      assetId: assetId,
      requesterId: actorId,
      projectId: projectId,
      assignedProjectId: stewardProject?.id,
      scopeLabel: 'Project',
      statusLabel: dispatchBlockedByAcquisition
          ? 'Requested · waiting on acquisition'
          : 'Requested',
      needByLabel: needByLabel,
      note: note,
      createdByPlanId: createdByPlanId,
      dispatchBlockedByAcquisition: dispatchBlockedByAcquisition,
    );
    foundationRequests.insert(0, request);
    _replaceProject(project.copyWith(lastActivity: prototypeNow));

    _appendProjectHistory(
      projectId,
      MockProjectHistoryEntry(
        id: _nextProjectHistoryId(projectId),
        projectId: projectId,
        categoryLabel: 'Transfer',
        title: 'Transfer request submitted',
        body: createdByPlanId == null
            ? 'Requested ${asset.name} for ${project.title}.'
            : 'A plan-linked transfer request was opened for ${asset.name}.',
        time: prototypeNow,
        actorId: actorId,
        assetId: asset.id,
        requestId: request.id,
      ),
    );

    if (stewardProject != null && stewardProject.id != projectId) {
      _appendProjectHistory(
        stewardProject.id,
        MockProjectHistoryEntry(
          id: _nextProjectHistoryId(stewardProject.id),
          projectId: stewardProject.id,
          categoryLabel: 'Transfer',
          title: 'Incoming transfer request',
          body: '${project.title} requested ${asset.name}.',
          time: prototypeNow,
          actorId: actorId,
          assetId: asset.id,
          requestId: request.id,
        ),
      );
    }

    _appendAssetHistory(
      asset.id,
      MockAssetHistoryEntry(
        id: _nextAssetHistoryId(asset.id),
        assetId: asset.id,
        categoryLabel: 'Transfer',
        title: 'Transfer request opened',
        body: createdByPlanId == null
            ? '${project.title} requested this asset for a managed handoff.'
            : '${project.title} generated a plan-linked request for this asset.',
        time: prototypeNow,
        locationLabel: asset.locationLabel,
        actorId: actorId,
        projectId: projectId,
        requestId: request.id,
      ),
    );
  }

  void confirmTransferDispatch(String requestId, String actorId) {
    final request = foundationRequestById(requestId);
    if (request == null) {
      return;
    }
    final asset = foundationAssetById(request.assetId);
    if (asset == null) {
      return;
    }

    final stewardProject = request.assignedProjectId == null
        ? stewardProjectForAsset(asset)
        : projectById(request.assignedProjectId!);
    final receivingProject = request.projectId == null
        ? null
        : projectById(request.projectId!);
    if (request.dispatchBlockedByAcquisition &&
        request.projectId != null &&
        !acquisitionReadyForProject(request.projectId!)) {
      return;
    }
    final newStatus = receivingProject == null
        ? 'Ready for pickup'
        : 'Dispatched';
    _replaceFoundationRequest(
      request.copyWith(
        statusLabel: newStatus,
        dispatchBlockedByAcquisition: false,
      ),
    );

    if (stewardProject != null) {
      _appendProjectHistory(
        stewardProject.id,
        MockProjectHistoryEntry(
          id: _nextProjectHistoryId(stewardProject.id),
          projectId: stewardProject.id,
          categoryLabel: 'Transfer',
          title: 'Transfer dispatched',
          body: receivingProject == null
              ? '${asset.name} was cleared for pickup.'
              : '${asset.name} was dispatched toward ${receivingProject.title}.',
          time: prototypeNow,
          actorId: actorId,
          assetId: asset.id,
          requestId: request.id,
        ),
      );
    }

    if (receivingProject != null) {
      _appendProjectHistory(
        receivingProject.id,
        MockProjectHistoryEntry(
          id: _nextProjectHistoryId(receivingProject.id),
          projectId: receivingProject.id,
          categoryLabel: 'Transfer',
          title: 'Transfer dispatched toward project',
          body:
              '${asset.name} left steward custody and is now in transit or pickup-ready.',
          time: prototypeNow,
          actorId: actorId,
          assetId: asset.id,
          requestId: request.id,
        ),
      );
    }

    _appendAssetHistory(
      asset.id,
      MockAssetHistoryEntry(
        id: _nextAssetHistoryId(asset.id),
        assetId: asset.id,
        categoryLabel: 'Transfer',
        title: receivingProject == null ? 'Pickup cleared' : 'Dispatched',
        body: receivingProject == null
            ? 'The steward marked this asset ready for pickup.'
            : 'The steward dispatched this asset toward ${receivingProject.title}.',
        time: prototypeNow,
        locationLabel: asset.locationLabel,
        actorId: actorId,
        projectId: receivingProject?.id,
        requestId: request.id,
      ),
    );
  }

  void confirmTransferReceipt(String requestId, String actorId) {
    final request = foundationRequestById(requestId);
    if (request == null) {
      return;
    }
    final asset = foundationAssetById(request.assetId);
    if (asset == null) {
      return;
    }

    final receivingProject = request.projectId == null
        ? null
        : projectById(request.projectId!);
    final stewardProject = request.assignedProjectId == null
        ? stewardProjectForAsset(asset)
        : projectById(request.assignedProjectId!);
    _replaceFoundationRequest(
      request.copyWith(
        statusLabel: 'Received',
        dispatchBlockedByAcquisition: false,
      ),
    );

    if (receivingProject != null) {
      _appendProjectHistory(
        receivingProject.id,
        MockProjectHistoryEntry(
          id: _nextProjectHistoryId(receivingProject.id),
          projectId: receivingProject.id,
          categoryLabel: 'Transfer',
          title: 'Receipt confirmed',
          body:
              '${asset.name} was received and logged by the destination project.',
          time: prototypeNow,
          actorId: actorId,
          assetId: asset.id,
          requestId: request.id,
        ),
      );
    }

    if (stewardProject != null) {
      _appendProjectHistory(
        stewardProject.id,
        MockProjectHistoryEntry(
          id: _nextProjectHistoryId(stewardProject.id),
          projectId: stewardProject.id,
          categoryLabel: 'Transfer',
          title: 'Receipt confirmed downstream',
          body: receivingProject == null
              ? 'A personal pickup was marked complete.'
              : '${receivingProject.title} confirmed receipt of ${asset.name}.',
          time: prototypeNow,
          actorId: actorId,
          assetId: asset.id,
          requestId: request.id,
        ),
      );
    }

    _appendAssetHistory(
      asset.id,
      MockAssetHistoryEntry(
        id: _nextAssetHistoryId(asset.id),
        assetId: asset.id,
        categoryLabel: 'Transfer',
        title: 'Receipt confirmed',
        body: receivingProject == null
            ? 'A pickup or return was confirmed complete.'
            : '${receivingProject.title} confirmed receipt and custody.',
        time: prototypeNow,
        locationLabel: asset.locationLabel,
        actorId: actorId,
        projectId: receivingProject?.id,
        requestId: request.id,
      ),
    );
  }

  MockUser? userById(String id) => users
      .where((item) => item.id == id)
      .cast<MockUser?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockChannel? channelById(String id) => channels
      .where((item) => item.id == id)
      .cast<MockChannel?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockCommunity? communityById(String id) => communities
      .where((item) => item.id == id)
      .cast<MockCommunity?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockProject? projectById(String id) => projects
      .where((item) => item.id == id)
      .cast<MockProject?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockThread? threadById(String id) => threads
      .where((item) => item.id == id)
      .cast<MockThread?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockPlan? planById(String id) => plans
      .where((item) => item.id == id)
      .cast<MockPlan?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockUpdate? updateById(String id) {
    for (final project in projects) {
      for (final update in project.updates) {
        if (update.id == id) {
          return update;
        }
      }
    }
    return null;
  }

  MockProject? projectForUpdate(String updateId) {
    for (final project in projects) {
      if (project.updates.any((update) => update.id == updateId)) {
        return project;
      }
    }
    return null;
  }

  MockDirectConversation? directConversationById(String id) =>
      directConversations
          .where((item) => item.id == id)
          .cast<MockDirectConversation?>()
          .firstWhere((item) => item != null, orElse: () => null);

  List<MockDirectConversation> directConversationsForUser(String userId) {
    final items = directConversations
        .where((item) => item.participantIds.contains(userId))
        .toList();
    items.sort(
      (left, right) => right.lastActivity.compareTo(left.lastActivity),
    );
    return items;
  }

  MockDirectConversation conversationWithUser(
    String currentUserId,
    String otherUserId,
  ) {
    final existing = directConversations
        .where((item) {
          return item.participantIds.length == 2 &&
              item.participantIds.contains(currentUserId) &&
              item.participantIds.contains(otherUserId);
        })
        .cast<MockDirectConversation?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (existing != null) {
      return existing;
    }

    final participantIds = [currentUserId, otherUserId]..sort();
    return MockDirectConversation(
      id: 'dm-preview-${participantIds.join('-')}',
      participantIds: participantIds,
      lastActivity: prototypeNow,
      unreadCount: 0,
    );
  }

  MockUser? otherParticipantForConversation(
    MockDirectConversation conversation,
    String currentUserId,
  ) {
    final otherId = conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );
    return userById(otherId);
  }

  List<MockDirectMessage> messagesForConversation(String conversationId) =>
      directMessagesByConversationId[conversationId] ?? const [];

  MockDirectMessage? latestMessageForConversation(String conversationId) {
    final messages = messagesForConversation(conversationId);
    if (messages.isEmpty) {
      return null;
    }
    return messages.reduce(
      (left, right) => left.time.isAfter(right.time) ? left : right,
    );
  }

  void markConversationRead(String conversationId) {
    final index = directConversations.indexWhere(
      (item) => item.id == conversationId,
    );
    if (index == -1) {
      return;
    }

    final conversation = directConversations[index];
    if (conversation.unreadCount == 0) {
      return;
    }

    directConversations[index] = conversation.copyWith(unreadCount: 0);
  }

  MockDirectConversation sendDirectMessage({
    required String currentUserId,
    required String otherUserId,
    required String body,
  }) {
    final trimmed = body.trim();
    final conversation = conversationWithUser(currentUserId, otherUserId);
    if (trimmed.isEmpty) {
      return conversation;
    }

    final messages = [...messagesForConversation(conversation.id)];
    final latestMessage = messages.isEmpty
        ? null
        : messages.reduce(
            (left, right) => left.time.isAfter(right.time) ? left : right,
          );
    final sentAt =
        latestMessage == null || latestMessage.time.isBefore(prototypeNow)
        ? prototypeNow
        : latestMessage.time.add(const Duration(minutes: 1));

    final persistedConversation = conversation.copyWith(
      lastActivity: sentAt,
      unreadCount: 0,
    );
    _upsertDirectConversation(persistedConversation);
    messages.add(
      MockDirectMessage(
        id: '${conversation.id}-m${messages.length + 1}',
        authorId: currentUserId,
        body: trimmed,
        time: sentAt,
      ),
    );
    directMessagesByConversationId[conversation.id] = messages;
    return persistedConversation;
  }

  String? directMessageReactionForUser(String messageId, String userId) {
    return _directMessageReactionByActor['$messageId::$userId'];
  }

  void toggleDirectMessageReaction({
    required String conversationId,
    required String messageId,
    required String userId,
    required String emoji,
  }) {
    final messages = directMessagesByConversationId[conversationId];
    if (messages == null) {
      return;
    }

    final messageIndex = messages.indexWhere((item) => item.id == messageId);
    if (messageIndex == -1) {
      return;
    }

    final message = messages[messageIndex];
    final reactions = Map<String, int>.from(message.reactions);
    final actorKey = '$messageId::$userId';
    final currentReaction = _directMessageReactionByActor[actorKey];

    if (currentReaction == emoji) {
      _decrementDirectMessageReaction(reactions, emoji);
      _directMessageReactionByActor.remove(actorKey);
    } else {
      if (currentReaction != null) {
        _decrementDirectMessageReaction(reactions, currentReaction);
      }
      reactions[emoji] = (reactions[emoji] ?? 0) + 1;
      _directMessageReactionByActor[actorKey] = emoji;
    }

    messages[messageIndex] = message.copyWith(reactions: reactions);
  }

  MockUpdate? latestUpdateForProject(String projectId) {
    final project = projectById(projectId);
    if (project == null || project.updates.isEmpty) {
      return null;
    }
    return project.updates.reduce(
      (left, right) => left.time.isAfter(right.time) ? left : right,
    );
  }

  void setPendingProjectUpdateTarget(String projectId, String updateId) {
    _pendingProjectUpdateTargets[projectId] = updateId;
  }

  void setPendingProjectCommentTarget(String projectId, String commentId) {
    _pendingProjectCommentTargets[projectId] = commentId;
  }

  void setPendingThreadCommentTarget(String threadId, String commentId) {
    _pendingThreadCommentTargets[threadId] = commentId;
  }

  void _upsertDirectConversation(MockDirectConversation conversation) {
    final existingIndex = directConversations.indexWhere(
      (item) => item.id == conversation.id,
    );

    if (existingIndex == -1) {
      directConversations.add(conversation);
      return;
    }

    directConversations[existingIndex] = conversation;
  }

  void _decrementDirectMessageReaction(
    Map<String, int> reactions,
    String emoji,
  ) {
    final currentCount = reactions[emoji];
    if (currentCount == null) {
      return;
    }
    if (currentCount <= 1) {
      reactions.remove(emoji);
      return;
    }
    reactions[emoji] = currentCount - 1;
  }

  String? takePendingProjectUpdateTarget(String projectId) =>
      _pendingProjectUpdateTargets.remove(projectId);

  String? takePendingProjectCommentTarget(String projectId) =>
      _pendingProjectCommentTargets.remove(projectId);

  String? takePendingThreadCommentTarget(String threadId) =>
      _pendingThreadCommentTargets.remove(threadId);

  MockFoundationAsset? foundationAssetById(String id) => foundationAssets
      .where((item) => item.id == id)
      .cast<MockFoundationAsset?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockFoundationZone? foundationZoneById(String id) => foundationZones
      .where((item) => item.id == id)
      .cast<MockFoundationZone?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockStorageBuilding? storageBuildingById(String id) => storageBuildings
      .where((item) => item.id == id)
      .cast<MockStorageBuilding?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockEvent? standaloneEventById(String id) => standaloneEvents
      .where((item) => item.id == id)
      .cast<MockEvent?>()
      .firstWhere((item) => item != null, orElse: () => null);

  MockPersonalPost? personalPostById(String id) => personalPosts
      .where((item) => item.id == id)
      .cast<MockPersonalPost?>()
      .firstWhere((item) => item != null, orElse: () => null);

  List<MockUser> followingForUser(String userId) =>
      (followingIdsByUser[userId] ?? const [])
          .map(userById)
          .whereType<MockUser>()
          .toList();

  List<MockUser> followersForUser(String userId) => followingIdsByUser.entries
      .where((entry) => entry.value.contains(userId))
      .map((entry) => userById(entry.key))
      .whereType<MockUser>()
      .toList();

  List<MockUser> friendsForUser(String userId) => followingForUser(userId);

  bool isFollowing(String userId, String targetUserId) =>
      (followingIdsByUser[userId] ?? const []).contains(targetUserId);

  void toggleFollowing(String userId, String targetUserId) {
    if (userId == targetUserId) {
      return;
    }

    final followedIds = [...(followingIdsByUser[userId] ?? const <String>[])];
    if (followedIds.contains(targetUserId)) {
      followedIds.remove(targetUserId);
    } else {
      followedIds.add(targetUserId);
    }
    followingIdsByUser[userId] = followedIds;
  }

  bool hasPersonalCommentShare({
    required String authorId,
    required MockCommentShareSourceKind sourceKind,
    required String sourceId,
    required String commentId,
  }) => personalCommentShares.any(
    (item) =>
        item.authorId == authorId &&
        item.sourceKind == sourceKind &&
        item.sourceId == sourceId &&
        item.commentId == commentId,
  );

  MockPersonalPost createPersonalPost({
    required String authorId,
    required String body,
  }) {
    final createdAt = prototypeNow.add(Duration(minutes: personalPosts.length));
    final post = MockPersonalPost(
      id: 'personal-post-${personalPosts.length + 1}',
      authorId: authorId,
      body: body,
      createdAt: createdAt,
      signalCount: 0,
    );
    personalPosts.insert(0, post);
    personalPostCommentsById[post.id] = [];
    return post;
  }

  MockComment addCommentToPersonalPost({
    required String postId,
    required String authorId,
    required String body,
  }) {
    final comments = personalPostCommentsById.putIfAbsent(postId, () => []);
    final comment = MockComment(
      id: '$postId-comment-${comments.length + 1}',
      authorId: authorId,
      body: body,
      time: prototypeNow.add(Duration(minutes: comments.length + 1)),
      score: 0,
    );
    comments.add(comment);
    return comment;
  }

  bool deletePersonalPost(String postId) {
    final exists = personalPosts.any((item) => item.id == postId);
    if (!exists) {
      return false;
    }
    personalPosts.removeWhere((item) => item.id == postId);
    personalPostCommentsById.remove(postId);
    return true;
  }

  void removePersonalCommentSharesForAuthor(String authorId) {
    personalCommentShares.removeWhere((item) => item.authorId == authorId);
  }

  void shareProjectCommentToPersonal({
    required String authorId,
    required String projectId,
    required String commentId,
  }) {
    final comment = projectCommentById(projectId, commentId);
    if (comment == null || comment.authorId != authorId) {
      return;
    }
    if (hasPersonalCommentShare(
      authorId: authorId,
      sourceKind: MockCommentShareSourceKind.project,
      sourceId: projectId,
      commentId: commentId,
    )) {
      return;
    }

    personalCommentShares.insert(
      0,
      MockPersonalCommentShare(
        id: 'personal-share-${personalCommentShares.length + 1}',
        authorId: authorId,
        sourceKind: MockCommentShareSourceKind.project,
        sourceId: projectId,
        commentId: commentId,
        sharedAt: prototypeNow.add(
          Duration(minutes: personalCommentShares.length + 1),
        ),
        caption: 'Shared from a project discussion.',
      ),
    );
  }

  void shareThreadCommentToPersonal({
    required String authorId,
    required String threadId,
    required String commentId,
  }) {
    final comment = threadCommentById(threadId, commentId);
    if (comment == null || comment.authorId != authorId) {
      return;
    }
    if (hasPersonalCommentShare(
      authorId: authorId,
      sourceKind: MockCommentShareSourceKind.thread,
      sourceId: threadId,
      commentId: commentId,
    )) {
      return;
    }

    personalCommentShares.insert(
      0,
      MockPersonalCommentShare(
        id: 'personal-share-${personalCommentShares.length + 1}',
        authorId: authorId,
        sourceKind: MockCommentShareSourceKind.thread,
        sourceId: threadId,
        commentId: commentId,
        sharedAt: prototypeNow.add(
          Duration(minutes: personalCommentShares.length + 1),
        ),
        caption: 'Shared from a thread discussion.',
      ),
    );
  }

  bool deleteComment(String commentId) {
    var removed = false;

    void updateCommentMap(Map<String, List<MockComment>> map) {
      for (final entry in map.entries.toList()) {
        final updated = _removeCommentFromList(entry.value, commentId);
        if (updated != null) {
          map[entry.key] = updated;
          removed = true;
        }
      }
    }

    updateCommentMap(projectCommentsById);
    updateCommentMap(threadCommentsById);
    updateCommentMap(updateCommentsById);
    updateCommentMap(personalPostCommentsById);

    for (var index = 0; index < plans.length; index++) {
      final updatedDiscussion = _removeCommentFromList(
        plans[index].discussion,
        commentId,
      );
      if (updatedDiscussion != null) {
        plans[index] = plans[index].copyWith(discussion: updatedDiscussion);
        removed = true;
      }
    }

    for (var index = 0; index < projects.length; index++) {
      final project = projects[index];
      var changed = false;
      final updatedEvents = <MockEvent>[];
      for (final event in project.events) {
        final updatedDiscussion = _removeCommentFromList(
          event.discussion,
          commentId,
        );
        if (updatedDiscussion != null) {
          changed = true;
          updatedEvents.add(event.copyWith(discussion: updatedDiscussion));
        } else {
          updatedEvents.add(event);
        }
      }
      if (changed) {
        projects[index] = project.copyWith(events: updatedEvents);
        removed = true;
      }
    }

    for (var index = 0; index < standaloneEvents.length; index++) {
      final updatedDiscussion = _removeCommentFromList(
        standaloneEvents[index].discussion,
        commentId,
      );
      if (updatedDiscussion != null) {
        standaloneEvents[index] = standaloneEvents[index].copyWith(
          discussion: updatedDiscussion,
        );
        removed = true;
      }
    }

    if (removed) {
      personalCommentShares.removeWhere((item) => item.commentId == commentId);
    }

    return removed;
  }

  List<MockComment>? _removeCommentFromList(
    List<MockComment> comments,
    String commentId,
  ) {
    var removed = false;
    final updated = <MockComment>[];

    for (final comment in comments) {
      if (comment.id == commentId) {
        removed = true;
        continue;
      }

      final updatedReplies = _removeCommentFromList(comment.replies, commentId);
      if (updatedReplies != null) {
        removed = true;
        updated.add(comment.copyWith(replies: updatedReplies));
      } else {
        updated.add(comment);
      }
    }

    return removed ? updated : null;
  }

  List<MockPersonalTimelineEntry> personalTimelineForUser(String viewerUserId) {
    final visibleAuthorIds = {
      viewerUserId,
      ...(followingIdsByUser[viewerUserId] ?? const []),
    };
    final items = <MockPersonalTimelineEntry>[
      for (final post in personalPosts)
        if (visibleAuthorIds.contains(post.authorId))
          MockPersonalTimelineEntry.post(
            post: post,
            lastActivity: post.createdAt,
          ),
      for (final share in personalCommentShares)
        if (visibleAuthorIds.contains(share.authorId))
          MockPersonalTimelineEntry.sharedComment(
            share: share,
            lastActivity: share.sharedAt,
          ),
      for (final event in standaloneEvents)
        if (_eventBelongsInPersonalTimeline(event, viewerUserId))
          MockPersonalTimelineEntry.event(
            event: event,
            lastActivity: event.lastActivity ?? event.createdAt ?? prototypeNow,
          ),
    ];
    items.sort(
      (left, right) => right.lastActivity.compareTo(left.lastActivity),
    );
    return items;
  }

  List<MockEvent> publicFeedStandaloneEvents({
    String viewerUserId = mockCurrentUserId,
  }) => visibleStandaloneEvents(viewerUserId: viewerUserId)
      .where(
        (event) =>
            !event.isPrivate ||
            event.channelIds.isNotEmpty ||
            event.communityIds.isNotEmpty,
      )
      .toList();

  bool _eventBelongsInPersonalTimeline(MockEvent event, String viewerUserId) {
    final creatorId = event.creatorId;
    if (creatorId == null) {
      return false;
    }

    final visibleAuthorIds = {
      viewerUserId,
      ...(followingIdsByUser[viewerUserId] ?? const []),
    };
    if (!visibleAuthorIds.contains(creatorId)) {
      return false;
    }

    final isUntagged = event.channelIds.isEmpty && event.communityIds.isEmpty;
    if (isUntagged && !event.isPrivate) {
      return true;
    }

    if (!event.isPrivate) {
      return false;
    }

    return creatorId == viewerUserId ||
        event.invitedUserIds.contains(viewerUserId) ||
        isFollowing(viewerUserId, creatorId);
  }

  bool canViewStandaloneEvent(
    MockEvent event, {
    String viewerUserId = mockCurrentUserId,
  }) {
    if (!event.isPrivate) {
      return true;
    }

    if (event.invitedUserIds.contains(viewerUserId)) {
      return true;
    }

    final hasTaggedChannelAccess = event.channelIds.any(
      (channelId) =>
          channelById(channelId)?.memberIds.contains(viewerUserId) ?? false,
    );
    if (hasTaggedChannelAccess) {
      return true;
    }

    return event.communityIds.any(
      (communityId) =>
          communityById(communityId)?.memberIds.contains(viewerUserId) ?? false,
    );
  }

  List<MockEvent> visibleStandaloneEvents({
    String viewerUserId = mockCurrentUserId,
  }) {
    final items = standaloneEvents
        .where(
          (item) => canViewStandaloneEvent(item, viewerUserId: viewerUserId),
        )
        .toList();
    items.sort(
      (left, right) => (right.lastActivity ?? right.createdAt ?? prototypeNow)
          .compareTo(left.lastActivity ?? left.createdAt ?? prototypeNow),
    );
    return items;
  }

  List<MockEvent> standaloneEventsForChannel(
    String channelId, {
    String viewerUserId = mockCurrentUserId,
  }) => visibleStandaloneEvents(
    viewerUserId: viewerUserId,
  ).where((item) => item.channelIds.contains(channelId)).toList();

  List<MockEvent> standaloneEventsForCommunity(
    String communityId, {
    String viewerUserId = mockCurrentUserId,
  }) => visibleStandaloneEvents(
    viewerUserId: viewerUserId,
  ).where((item) => item.communityIds.contains(communityId)).toList();

  MockEvent createStandaloneEvent({
    required String title,
    required String timeLabel,
    required String location,
    required String description,
    required String creatorId,
    required List<String> channelIds,
    required List<String> communityIds,
    required bool isPrivate,
    required List<String> invitedUserIds,
    List<String> rolesNeeded = const [],
    List<String> materials = const [],
    String outcome = '',
    List<String> managerIds = const [],
    List<MockComment> discussion = const [],
    List<MockUpdate> updates = const [],
  }) {
    final createdAt = prototypeNow.add(
      Duration(minutes: standaloneEvents.length + 1),
    );
    final filteredChannelIds = channelIds.where((channelId) {
      final channel = channelById(channelId);
      return channel != null && canCreateEventInChannel(channel, creatorId);
    }).toList();
    final event = MockEvent(
      id: 'standalone-event-${standaloneEvents.length + 1}',
      title: title,
      timeLabel: timeLabel,
      location: location,
      going: 1,
      description: description,
      rolesNeeded: rolesNeeded,
      materials: materials,
      outcome: outcome,
      managerIds: managerIds.isEmpty ? [creatorId] : managerIds,
      discussion: discussion,
      updates: updates,
      creatorId: creatorId,
      channelIds: filteredChannelIds,
      communityIds: communityIds,
      invitedUserIds: invitedUserIds,
      isPrivate: isPrivate,
      createdAt: createdAt,
      lastActivity: createdAt,
    );
    standaloneEvents.insert(0, event);
    return event;
  }

  List<MockFeedEntry> buildFeed({
    required MockFeedScope scope,
    required MockFeedFilter filter,
    required MockFeedSort sort,
    required Map<String, int> votes,
    String viewerUserId = mockCurrentUserId,
  }) {
    var items = <MockFeedEntry>[
      for (final project in projects)
        MockFeedEntry.project(
          id: project.id,
          lastActivity: project.lastActivity,
        ),
      for (final thread in threads)
        MockFeedEntry.thread(id: thread.id, lastActivity: thread.lastActivity),
      for (final event in publicFeedStandaloneEvents(
        viewerUserId: viewerUserId,
      ))
        MockFeedEntry.event(
          id: event.id,
          lastActivity: event.lastActivity ?? event.createdAt ?? prototypeNow,
        ),
    ];

    if (scope == MockFeedScope.mine) {
      items = items.where((entry) {
        if (entry.kind == MockFeedEntryKind.project) {
          final project = projectById(entry.id)!;
          return project.channelIds.contains('food-agriculture') ||
              project.communityIds.contains('downtown-growers');
        }

        if (entry.kind == MockFeedEntryKind.event) {
          final event = standaloneEventById(entry.id)!;
          return event.creatorId == viewerUserId ||
              event.invitedUserIds.contains(viewerUserId) ||
              event.channelIds.contains('food-agriculture') ||
              event.communityIds.contains('downtown-growers');
        }

        final thread = threadById(entry.id)!;
        return thread.channelIds.contains('food-agriculture') ||
            thread.communityIds.contains('downtown-growers');
      }).toList();
    }

    if (scope == MockFeedScope.local) {
      items = items.where((entry) => localityScore(entry) > 0).toList()
        ..sort((left, right) {
          final scoreCompare = localityScore(
            right,
          ).compareTo(localityScore(left));
          if (scoreCompare != 0) {
            return scoreCompare;
          }
          return right.lastActivity.compareTo(left.lastActivity);
        });
    }

    if (filter == MockFeedFilter.projects) {
      items = items
          .where((entry) => entry.kind == MockFeedEntryKind.project)
          .toList();
    }

    if (filter == MockFeedFilter.threads) {
      items = items
          .where((entry) => entry.kind == MockFeedEntryKind.thread)
          .toList();
    }

    if (filter == MockFeedFilter.events) {
      items = items
          .where((entry) => entry.kind == MockFeedEntryKind.event)
          .toList();
    }

    if (sort == MockFeedSort.latest) {
      items.sort(
        (left, right) => right.lastActivity.compareTo(left.lastActivity),
      );
    }

    if (sort == MockFeedSort.votes) {
      items.sort(
        (left, right) =>
            voteCount(right, votes).compareTo(voteCount(left, votes)),
      );
    }

    if (sort == MockFeedSort.comments) {
      items.sort(
        (left, right) => commentCount(right).compareTo(commentCount(left)),
      );
    }

    return items;
  }

  int localityScore(MockFeedEntry entry) {
    if (entry.kind == MockFeedEntryKind.project) {
      final project = projectById(entry.id)!;
      var score = 0;
      if (project.locationDistrict == mockLocalDistrict) {
        score += 3;
      }
      if (project.communityIds.contains('downtown-growers')) {
        score += 2;
      }
      if (project.channelIds.contains('food-agriculture')) {
        score += 1;
      }
      return score;
    }

    if (entry.kind == MockFeedEntryKind.event) {
      final event = standaloneEventById(entry.id)!;
      var score = 0;
      if (event.communityIds.contains('downtown-growers')) {
        score += 2;
      }
      if (event.channelIds.contains('food-agriculture')) {
        score += 1;
      }
      return score;
    }

    final thread = threadById(entry.id)!;
    var score = 0;
    if (thread.communityIds.contains('downtown-growers')) {
      score += 2;
    }
    if (thread.channelIds.contains('food-agriculture')) {
      score += 1;
    }
    return score;
  }

  int voteCount(MockFeedEntry entry, Map<String, int> votes) {
    final base = switch (entry.kind) {
      MockFeedEntryKind.project => projectById(entry.id)!.awarenessCount,
      MockFeedEntryKind.thread => threadById(entry.id)!.awarenessCount,
      MockFeedEntryKind.event => standaloneEventById(entry.id)!.going,
    };
    return base + (votes[entry.id] ?? 0);
  }

  int commentCount(MockFeedEntry entry) {
    if (entry.kind == MockFeedEntryKind.project) {
      return projectById(entry.id)!.comments;
    }
    if (entry.kind == MockFeedEntryKind.event) {
      return standaloneEventById(entry.id)!.invitedUserIds.length;
    }
    return threadById(entry.id)!.replyCount;
  }

  List<MockUpcomingEvent> upcomingEvents({int limit = 4}) {
    final items = <MockUpcomingEvent>[];
    for (final project in projects) {
      for (final event in project.events) {
        items.add(MockUpcomingEvent(project: project, event: event));
      }
    }
    return items.take(limit).toList();
  }

  List<MockProject> openFunds() =>
      projects.where((item) => item.fund != null).toList();

  List<MockPlan> plansForProject(String projectId, MockPlanKind kind) => plans
      .where((plan) => plan.projectId == projectId && plan.kind == kind)
      .toList();

  List<MockProject> linkedProjectsForProject(MockProject project) => project
      .linkedProjectIds
      .map(projectById)
      .whereType<MockProject>()
      .toList();

  List<MockThread> linkedThreadsForThread(MockThread thread) =>
      thread.linkedThreadIds.map(threadById).whereType<MockThread>().toList();

  List<MockProject> projectsForChannel(String channelId) => projects
      .where((project) => project.channelIds.contains(channelId))
      .toList();

  List<MockThread> threadsForChannel(String channelId) =>
      threads.where((thread) => thread.channelIds.contains(channelId)).toList();

  List<MockProject> projectsForCommunity(String communityId) => projects
      .where((project) => project.communityIds.contains(communityId))
      .toList();

  List<MockThread> threadsForCommunity(String communityId) => threads
      .where((thread) => thread.communityIds.contains(communityId))
      .toList();

  List<MockCommunity> communitiesForChannel(String channelId) => communities
      .where(
        (community) => projectsForCommunity(
          community.id,
        ).any((project) => project.channelIds.contains(channelId)),
      )
      .toList();

  List<MockComment> commentsForProject(String projectId) =>
      projectCommentsById[projectId] ?? const [];

  List<MockComment> commentsForThread(String threadId) =>
      threadCommentsById[threadId] ?? const [];

  List<MockComment> commentsForUpdate(String updateId) =>
      updateCommentsById[updateId] ?? const [];

  List<MockComment> commentsForPersonalPost(String postId) =>
      personalPostCommentsById[postId] ?? const [];

  MockComment? projectCommentById(String projectId, String commentId) =>
      _findCommentById(commentsForProject(projectId), commentId);

  MockComment? threadCommentById(String threadId, String commentId) =>
      _findCommentById(commentsForThread(threadId), commentId);

  MockComment? _findCommentById(List<MockComment> comments, String commentId) {
    for (final comment in comments) {
      if (comment.id == commentId) {
        return comment;
      }
      final nested = _findCommentById(comment.replies, commentId);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  List<MockFoundationAsset> foundationAssetsForZone(String zoneId) =>
      foundationAssets.where((item) => item.zoneId == zoneId).toList();

  List<MockFoundationAsset> foundationAssetsForProject(String projectId) =>
      foundationAssets
          .where(
            (item) =>
                item.stewardProjectId == projectId ||
                item.linkedProjectIds.contains(projectId),
          )
          .toList();

  List<MockStorageBuilding> storageBuildingsForProject(String projectId) =>
      storageBuildings.where((item) => item.projectId == projectId).toList();

  List<MockStorageBuilding> storageBuildingsForLandAsset(String landAssetId) =>
      storageBuildings
          .where((item) => item.landAssetId == landAssetId)
          .toList();

  List<MockFoundationAsset> foundationAssetsForBuilding(String buildingId) =>
      foundationAssets.where((item) => item.buildingId == buildingId).toList();

  List<MockFoundationAsset> standaloneLandAssets() =>
      foundationAssets.where((item) => item.groupLabel == 'Land').toList();

  List<MockProject> linkedProjectsForLandAsset(MockFoundationAsset landAsset) =>
      landAsset.linkedProjectIds
          .map(projectById)
          .whereType<MockProject>()
          .toList();

  List<MockFoundationAsset> directAssetsForLandAsset(String landAssetId) =>
      foundationAssets
          .where(
            (item) =>
                item.landAssetId == landAssetId &&
                item.stewardProjectId == null &&
                item.buildingId == null,
          )
          .toList();

  List<MockFoundationAsset> linkedAssetsForAsset(MockFoundationAsset asset) =>
      asset.linkedAssetIds
          .map(foundationAssetById)
          .whereType<MockFoundationAsset>()
          .toList();

  List<MockProject> linkedProjectsForAsset(MockFoundationAsset asset) =>
      asset.linkedProjectIds.map(projectById).whereType<MockProject>().toList();

  List<MockFoundationRequest> foundationRequestsForAsset(String assetId) =>
      foundationRequests.where((item) => item.assetId == assetId).toList();

  List<MockFoundationRequest> transferRequestsForPlan(String planId) =>
      foundationRequests
          .where((item) => item.createdByPlanId == planId)
          .toList();

  List<MockFoundationRequest> foundationRequestsForProject(String projectId) {
    final assetIds = foundationAssetsForProject(
      projectId,
    ).map((item) => item.id).toSet();
    return foundationRequests
        .where((item) => assetIds.contains(item.assetId))
        .toList();
  }

  List<MockLandManagementRequest> landManagementRequestsForProject(
    String projectId,
  ) {
    final items = landManagementRequests
        .where(
          (item) =>
              item.requestingProjectId == projectId ||
              item.targetProjectId == projectId,
        )
        .toList();
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  List<MockLandManagementRequest> landManagementRequestsForPlan(String planId) {
    final items = landManagementRequests
        .where((item) => item.planId == planId)
        .toList();
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  MockLandManagementRequest? landManagementRequestById(String id) =>
      landManagementRequests
          .where((item) => item.id == id)
          .cast<MockLandManagementRequest?>()
          .firstWhere((item) => item != null, orElse: () => null);

  List<MockSoftwareChangeRequest> softwareChangeRequestsForProject(
    String projectId,
  ) {
    final items = softwareChangeRequests
        .where((item) => item.projectId == projectId)
        .toList();
    items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items;
  }

  MockSoftwareChangeRequest? softwareChangeRequestById(String id) =>
      softwareChangeRequests
          .where((item) => item.id == id)
          .cast<MockSoftwareChangeRequest?>()
          .firstWhere((item) => item != null, orElse: () => null);

  List<MockFoundationRequest> foundationRequestsForZone(String zoneId) =>
      foundationRequests.where((item) {
        final asset = foundationAssetById(item.assetId);
        return asset?.zoneId == zoneId;
      }).toList();

  MockSearchResults search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const MockSearchResults(
        projects: [],
        threads: [],
        events: [],
        channels: [],
        communities: [],
        users: [],
      );
    }

    bool matches(String text) => text.toLowerCase().contains(normalized);
    bool eventMatches(MockEvent item) {
      final tagLabels = [
        for (final channelId in item.channelIds)
          channelById(channelId)?.name ?? '',
        for (final communityId in item.communityIds)
          communityById(communityId)?.name ?? '',
      ];

      return matches(item.title) ||
          matches(item.description) ||
          matches(item.location) ||
          tagLabels.any(matches);
    }

    return MockSearchResults(
      projects: projects
          .where(
            (item) =>
                matches(item.title) ||
                matches(item.summary) ||
                matches(item.body),
          )
          .toList(),
      threads: threads
          .where((item) => matches(item.title) || matches(item.body))
          .toList(),
      events: visibleStandaloneEvents().where(eventMatches).toList(),
      channels: channels
          .where((item) => matches(item.name) || matches(item.description))
          .toList(),
      communities: communities
          .where((item) => matches(item.name) || matches(item.description))
          .toList(),
      users: users
          .where(
            (item) =>
                matches(item.username) ||
                matches(item.name) ||
                matches(item.bio) ||
                matches(item.location),
          )
          .toList(),
    );
  }
}
