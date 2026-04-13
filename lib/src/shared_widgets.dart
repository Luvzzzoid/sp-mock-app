part of '../main.dart';

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
                    '- ${plan.estimatedExecutionLabel}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (plan.assetNeeds.isNotEmpty)
                  Text(
                    '- ${plan.assetNeeds.length} asset needs',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (plan.costLines.isNotEmpty)
                  Text(
                    '- ${plan.costLines.length} cost lines',
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
        Text('-', style: labelStyle?.copyWith(color: _appMuted(context))),
        _VoteCountBadge(
          icon: Icons.keyboard_arrow_up_rounded,
          count: approvalCount,
          color: activeVote == 1
              ? _positiveVoteColor(context)
              : _appMuted(context),
          compact: compact,
          onTap: canVote ? () => onVote!(1) : null,
        ),
        Text('-', style: labelStyle?.copyWith(color: _appMuted(context))),
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
    final titleStyle = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(color: _titleAccent(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 720) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(title, style: titleStyle)),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(title, style: titleStyle)),
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
