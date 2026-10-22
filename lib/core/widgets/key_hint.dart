import 'package:flutter/material.dart';
import 'package:xstackapp/core/theme/app_theme.dart';

/// A keycap shown in the interface and in shortcut sheets.
class KeyHint extends StatelessWidget {
  const KeyHint(this.label, {super.key, this.dim = false});

  final String label;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        border: Border.all(color: colors.borderMuted),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 10,
          height: 1.2,
          fontWeight: FontWeight.w500,
          color: dim ? colors.textMuted : colors.textSecondary,
        ),
      ),
    );
  }
}

/// "[ctrl K] Search chats" — the recurring way we surface keyboard actions.
class ShortcutHint extends StatelessWidget {
  const ShortcutHint({
    super.key,
    required this.keys,
    required this.label,
    this.onTap,
  });

  final List<String> keys;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          KeyHint(keys[i]),
        ],
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              color: colors.textMuted,
              height: 1.2,
            ),
          ),
        ),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}
