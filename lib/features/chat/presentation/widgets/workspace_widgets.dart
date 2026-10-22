import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xstackapp/core/theme/app_theme.dart';

/// Square, border-first avatar. No photos yet, so initials do the work.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 28,
    this.accent = false,
  });

  final String name;
  final double size;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trimmed = name.trim();
    final initial = trimmed.isEmpty
        ? '?'
        : trimmed.substring(0, 1).toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent ? colors.accentMuted : colors.surfaceMuted,
        border: Border.all(
          color: accent ? colors.accent.withValues(alpha: 0.5) : colors.border,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: accent ? colors.accent : colors.textSecondary,
          height: 1,
        ),
      ),
    );
  }
}

class PaneHeader extends StatelessWidget {
  const PaneHeader({
    super.key,
    required this.title,
    this.trailing = const [],
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                color: colors.textMuted,
              ),
            ),
          ],
          const Spacer(),
          ...trailing,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.hint,
    this.actions = const [],
    this.center = true,
  });

  final String title;
  final String? hint;
  final List<Widget> actions;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              '\$ $title',
              textAlign: center ? TextAlign.center : TextAlign.left,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(
                hint!,
                textAlign: center ? TextAlign.center : TextAlign.left,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  height: 1.6,
                  color: colors.textMuted,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: colors.textMuted,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

String formatClock(DateTime time) => DateFormat.Hm().format(time.toLocal());

String formatChatTimestamp(DateTime time) {
  final local = time.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final difference = today.difference(day).inDays;

  if (difference == 0) {
    return DateFormat.Hm().format(local);
  }
  if (difference == 1) {
    return DateFormat('dd.MM').format(local);
  }
  if (local.year == now.year) {
    return DateFormat('dd.MM').format(local);
  }
  return DateFormat('dd.MM.yy').format(local);
}

String formatLongDate(DateTime time) {
  return DateFormat('dd.MM.yyyy').format(time.toLocal());
}

bool isSameDay(DateTime a, DateTime b) {
  final al = a.toLocal();
  final bl = b.toLocal();
  return al.year == bl.year && al.month == bl.month && al.day == bl.day;
}
