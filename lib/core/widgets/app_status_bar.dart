import 'package:flutter/material.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';

/// The bottom strip that makes the app feel like a workspace rather than a
/// website: persistent context on the left, keyboard actions in the middle,
/// environment details on the right.
class AppStatusBar extends StatelessWidget {
  const AppStatusBar({
    super.key,
    required this.left,
    this.hints = const [],
    this.right = const [],
  });

  final List<Widget> left;
  final List<ShortcutHint> hints;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ...left,
          if (hints.isNotEmpty) ...[
            const SizedBox(width: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final visible = _fitHints(context, constraints.maxWidth);
                  if (visible.isEmpty) return const SizedBox.shrink();
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        for (var i = 0; i < visible.length; i++) ...[
                          if (i > 0) const SizedBox(width: 14),
                          visible[i],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
          ] else
            const Spacer(),
          ...right,
        ],
      ),
    );
  }

  /// Drops hints from the end until the remaining set measures inside
  /// [available]. A clipped word at narrow widths looks like a layout bug,
  /// so the strip degrades by whole actions instead of scrolling.
  List<ShortcutHint> _fitHints(BuildContext context, double available) {
    if (available <= 0) return const [];
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    const keyStyle = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: 10,
      height: 1.2,
      fontWeight: FontWeight.w500,
    );
    const labelStyle = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: 10,
      height: 1.2,
    );

    double widthOf(ShortcutHint hint) {
      var width = 0.0;
      for (var i = 0; i < hint.keys.length; i++) {
        final key = TextPainter(
          text: TextSpan(text: hint.keys[i], style: keyStyle),
          textDirection: direction,
          textScaler: scaler,
        )..layout();
        // 5px horizontal padding + 1px border on each side.
        width += key.width + 12;
        if (i > 0) width += 3;
      }
      final label = TextPainter(
        text: TextSpan(text: hint.label, style: labelStyle),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      return width + 7 + label.width;
    }

    final visible = <ShortcutHint>[];
    var used = 0.0;
    for (final hint in hints) {
      final needed = widthOf(hint) + (visible.isEmpty ? 0 : 14);
      if (used + needed > available) break;
      visible.add(hint);
      used += needed;
    }
    return visible;
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.size = 6});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class StatusText extends StatelessWidget {
  const StatusText(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 10,
        color: color ?? colors.textMuted,
        height: 1.2,
      ),
    );
  }
}
