import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/gap.dart';
import '../model/room_spec.dart';
import 'mm_field.dart';
import 'room_plan_view.dart';

/// Review and correct a [RoomSpec]: shape, ceiling, wall lengths and
/// openings. Every edit is reported through [onChanged].
class RoomSpecEditor extends StatelessWidget {
  const RoomSpecEditor({
    super.key,
    required this.room,
    required this.onChanged,
  });

  final RoomSpec room;
  final ValueChanged<RoomSpec> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap(h: 16),
        if (room.isEstimate) ...[const _EstimateBanner(), Gap(h: 12)],
        RoomPlanView(room: room),
        Gap(h: 16),
        Text('Kitchen shape', style: AppTextStyles.inputLabel),
        Gap(h: 8),
        SegmentedButton<RoomShape>(
          showSelectedIcon: false,
          segments: [
            for (final s in RoomShape.values)
              ButtonSegment(value: s, label: Text(s.label)),
          ],
          selected: {room.shape},
          onSelectionChanged: (s) => onChanged(room.withShape(s.single)),
        ),
        Gap(h: 16),
        MmField(
          label: 'Ceiling height (mm)',
          value: room.ceilingHeightMm,
          onChanged: (mm) => onChanged(room.copyWith(ceilingHeightMm: mm)),
        ),
        for (var i = 0; i < room.walls.length; i++) ...[
          Gap(h: 16),
          _WallCard(
            key: ValueKey(room.walls[i].id),
            index: i,
            wall: room.walls[i],
            roomCeilingMm: room.ceilingHeightMm,
            onChanged: (w) => onChanged(room.withWall(i, w)),
            // The corner this wall shares with the previous one.
            cornerAngleDeg: i > 0 && room.shape.hasCorners
                ? room.cornerAngleDeg(i - 1)
                : null,
            onCornerChanged: (deg) =>
                onChanged(room.withCornerAngle(i - 1, deg)),
          ),
        ],
      ],
    );
  }
}

class _EstimateBanner extends StatelessWidget {
  const _EstimateBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceTag,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
          Gap(w: 8),
          Expanded(
            child: Text(
              'Scanned values are estimates. Check them and verify on site '
              'before ordering.',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _WallCard extends StatelessWidget {
  const _WallCard({
    super.key,
    required this.index,
    required this.wall,
    required this.roomCeilingMm,
    required this.onChanged,
    required this.cornerAngleDeg,
    required this.onCornerChanged,
  });

  final int index;
  final RoomWall wall;
  final int roomCeilingMm;
  final ValueChanged<RoomWall> onChanged;

  /// Null when this wall has no corner with the previous one.
  final double? cornerAngleDeg;
  final ValueChanged<double> onCornerChanged;

  void _setOpening(int j, RoomOpening o) =>
      onChanged(wall.copyWith(openings: [...wall.openings]..[j] = o));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(wallName(index), style: AppTextStyles.listTitle),
              ),
              PopupMenuButton<OpeningType>(
                tooltip: 'Add to this wall',
                onSelected: (type) => onChanged(
                  wall.copyWith(
                    openings: [...wall.openings, RoomOpening.defaultFor(type)],
                  ),
                ),
                itemBuilder: (_) => [
                  for (final t in OpeningType.values)
                    PopupMenuItem(value: t, child: Text('Add ${t.label}')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18, color: AppColors.primary),
                    Text('Add', style: AppTextStyles.link),
                  ],
                ),
              ),
            ],
          ),
          Gap(h: 8),
          MmField(
            label: 'Length (mm)',
            value: wall.lengthMm,
            onChanged: (mm) => onChanged(wall.copyWith(lengthMm: mm)),
          ),
          Gap(h: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: OptionalMmField(
                  label: 'Ceiling, left',
                  hint: '$roomCeilingMm',
                  value: wall.heightMm,
                  onChanged: (mm) =>
                      onChanged(wall.withHeights(mm, wall.heightEndMm)),
                ),
              ),
              Gap(w: 8),
              Expanded(
                child: OptionalMmField(
                  label: 'Ceiling, right',
                  hint: '${wall.heightMm ?? roomCeilingMm}',
                  value: wall.heightEndMm,
                  onChanged: (mm) =>
                      onChanged(wall.withHeights(wall.heightMm, mm)),
                ),
              ),
            ],
          ),
          if (cornerAngleDeg case final deg?) ...[
            Gap(h: 12),
            DegreesField(
              label: 'Corner with ${wallName(index - 1)} (°)',
              value: deg,
              onChanged: onCornerChanged,
            ),
          ],
          for (var j = 0; j < wall.openings.length; j++) ...[
            Gap(h: 12),
            _OpeningRow(
              key: ValueKey('${wall.id}-$j'),
              opening: wall.openings[j],
              onChanged: (o) => _setOpening(j, o),
              onRemove: () => onChanged(
                wall.copyWith(openings: [...wall.openings]..removeAt(j)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpeningRow extends StatelessWidget {
  const _OpeningRow({
    super.key,
    required this.opening,
    required this.onChanged,
    required this.onRemove,
  });

  final RoomOpening opening;
  final ValueChanged<RoomOpening> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final sill = opening.sillMm;
    final hasHeight = opening.type == .window || opening.type == .door;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(opening.type.label, style: AppTextStyles.inputLabel),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove',
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MmField(
                label: 'From left',
                value: opening.offsetMm,
                onChanged: (mm) => onChanged(opening.copyWith(offsetMm: mm)),
              ),
            ),
            Gap(w: 8),
            Expanded(
              child: MmField(
                label: 'Width',
                value: opening.widthMm,
                onChanged: (mm) => onChanged(opening.copyWith(widthMm: mm)),
              ),
            ),
          ],
        ),
        if (sill != null || hasHeight) ...[
          Gap(h: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: sill != null
                    ? MmField(
                        label: 'Sill',
                        value: sill,
                        onChanged: (mm) =>
                            onChanged(opening.copyWith(sillMm: mm)),
                      )
                    : const SizedBox.shrink(),
              ),
              Gap(w: 8),
              Expanded(
                child: hasHeight
                    ? OptionalMmField(
                        label: 'Height',
                        hint: 'Not measured',
                        value: opening.heightMm,
                        onChanged: (mm) => onChanged(
                          mm == null
                              ? opening.withoutHeight()
                              : opening.copyWith(heightMm: mm),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
