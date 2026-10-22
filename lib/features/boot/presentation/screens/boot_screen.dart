import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/constants/api_constants.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/app_status_bar.dart';
import 'package:xstackapp/core/widgets/brand.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/boot/presentation/controllers/boot_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class BootScreen extends HookConsumerWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final phase = ref.watch(bootControllerProvider.select((s) => s.phase));

    useEffect(() {
      Future.microtask(
        () => ref.read(bootControllerProvider.notifier).run(),
      );
      return null;
    }, const []);

    final host = Uri.parse(ApiConstants.baseUrl);
    final hostLabel = '${host.host}:${host.port}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BootChrome(
                            label: phase == BootPhase.starting
                                ? l10n.bootStarting
                                : l10n.bootRestoring,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const BrandWordmark(fontSize: 20),
                                const SizedBox(height: 22),
                                Text(
                                  r'$ xstack start --restore',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                _BootLine(
                                  label: l10n.bootConfig,
                                  state: _BootLineState.done,
                                ),
                                const SizedBox(height: 10),
                                _BootLine(
                                  label: l10n.bootRestoring,
                                  state: phase == BootPhase.starting
                                      ? _BootLineState.pending
                                      : (phase == BootPhase.restoringSession
                                            ? _BootLineState.active
                                            : _BootLineState.done),
                                ),
                                const SizedBox(height: 10),
                                _BootLine(
                                  label: l10n.bootWorkspace,
                                  state: phase == BootPhase.ready
                                      ? _BootLineState.active
                                      : _BootLineState.pending,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  height: 1,
                                  color: colors.borderMuted,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Text(
                                      hostLabel,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 10,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'v0.1.0',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 10,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AppStatusBar(
              left: [
                StatusDot(color: colors.warning),
                const SizedBox(width: 6),
                StatusText(
                  l10n.bootHint,
                  color: colors.textMuted,
                ),
              ],
              right: [StatusText('utf-8')],
            ),
          ],
        ),
      ),
    );
  }
}

enum _BootLineState { pending, active, done }

class _BootLine extends StatelessWidget {
  const _BootLine({required this.label, required this.state});

  final String label;
  final _BootLineState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (state) {
      _BootLineState.pending => colors.textMuted,
      _BootLineState.active => colors.textSecondary,
      _BootLineState.done => colors.textSecondary,
    };

    return Row(
      children: [
        SizedBox(
          width: 20,
          child: switch (state) {
            _BootLineState.pending => Text(
              '·',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
            _BootLineState.active => TerminalSpinner(color: colors.accent),
            _BootLineState.done => Text(
              '✓',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: colors.success,
              ),
            ),
          },
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BootChrome extends StatelessWidget {
  const _BootChrome({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
        color: colors.surfaceMuted,
      ),
      child: Row(
        children: [
          for (final color in [
            colors.brandRed,
            colors.brandOrange,
            colors.brandGreen,
          ]) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 9,
              color: colors.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            'tty1',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 9,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
