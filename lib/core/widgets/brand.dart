import 'package:flutter/material.dart';
import 'package:xstackapp/core/theme/app_theme.dart';

/// The five bars echo the stacked blocks of the original XStack logo, but are
/// reduced to a quiet terminal-friendly mark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.barWidth = 3, this.height = 14});

  final double barWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bars = [
      colors.brandRed,
      colors.brandOrange,
      colors.brandGreen,
      colors.brandBlue,
      colors.brandPurple,
    ];

    return Semantics(
      label: 'XStack',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Container(
              width: barWidth,
              height: height - (i.isEven ? 0 : 2),
              color: bars[i],
            ),
          ],
        ],
      ),
    );
  }
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 14});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(height: fontSize + 2),
        const SizedBox(width: 9),
        Text(
          'xstack',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: colors.text,
          ),
        ),
      ],
    );
  }
}
