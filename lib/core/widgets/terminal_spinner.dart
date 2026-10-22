import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xstackapp/core/theme/app_theme.dart';

/// Small ASCII spinner used in inline loading states.
class TerminalSpinner extends StatefulWidget {
  const TerminalSpinner({super.key, this.color, this.label});

  final Color? color;
  final String? label;

  @override
  State<TerminalSpinner> createState() => _TerminalSpinnerState();
}

class _TerminalSpinnerState extends State<TerminalSpinner> {
  static const _frames = ['|', '/', '-', '\\'];
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 140), (_) {
      if (!mounted) return;
      setState(() => _frame = (_frame + 1) % _frames.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final animate = !MediaQuery.of(context).disableAnimations;
    final glyph = animate ? _frames[_frame] : '·';
    final style = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: 12,
      color: widget.color ?? colors.textMuted,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 10,
          child: Text(glyph, style: style, textAlign: TextAlign.center),
        ),
        if (widget.label != null) ...[
          const SizedBox(width: 6),
          Text(widget.label!, style: style),
        ],
      ],
    );
  }
}
