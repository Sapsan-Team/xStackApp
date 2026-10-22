import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class ShortcutsDialog extends StatelessWidget {
  const ShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final navigation = _ShortcutGroup(
      title: l10n.workspaceNavigation,
      items: [
        _Shortcut(['ctrl', 'k'], l10n.workspaceCommands),
        _Shortcut(['ctrl', 'n'], l10n.workspaceNewChat),
        _Shortcut(['ctrl', 'f'], l10n.workspaceFilterChats),
        _Shortcut(['alt', '↑'], l10n.workspacePrevChat),
        _Shortcut(['alt', '↓'], l10n.workspaceNextChat),
        _Shortcut(['esc'], l10n.workspaceCloseOverlay),
      ],
    );

    final conversation = _ShortcutGroup(
      title: l10n.workspaceConversations,
      items: [
        _Shortcut(['enter'], l10n.workspaceSendMessage),
        _Shortcut(['shift', 'enter'], l10n.workspaceNewLine),
        _Shortcut(['ctrl', 'shift', 'c'], l10n.workspaceFocusComposer),
        _Shortcut(['ctrl', 'r'], l10n.workspaceRefresh),
        _Shortcut(['ctrl', 'shift', 'i'], l10n.workspaceToggleDetails),
      ],
    );

    final workspace = _ShortcutGroup(
      title: l10n.workspaceAppearance,
      items: [
        _Shortcut(['ctrl', 'shift', 'l'], l10n.workspaceToggleThemeAction),
        _Shortcut(['ctrl', ','], l10n.workspaceOpenProfileAction),
        _Shortcut(['ctrl', '/'], l10n.workspaceShowShortcutsAction),
        _Shortcut(['ctrl', 'shift', 'd'], l10n.workspaceOpenLogs),
      ],
    );

    final account = _ShortcutGroup(
      title: l10n.workspaceAccount,
      items: [
        _Shortcut(['esc'], l10n.workspaceCloseDialog),
        _Shortcut(['ctrl', 'shift', 'q'], l10n.workspaceSignOutAction),
      ],
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 640,
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.only(left: 14, right: 6),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.workspaceShortcuts,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '${l10n.workspaceClose}  esc',
                      icon: const Icon(Icons.close, size: 14),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _GroupBlock(group: navigation),
                            const SizedBox(height: 18),
                            _GroupBlock(group: conversation),
                          ],
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          children: [
                            _GroupBlock(group: workspace),
                            const SizedBox(height: 18),
                            _GroupBlock(group: account),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 9,
                        color: colors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    ShortcutHint(
                      keys: const ['esc'],
                      label: l10n.workspaceClose,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shortcut {
  const _Shortcut(this.keys, this.label);

  final List<String> keys;
  final String label;
}

class _ShortcutGroup {
  const _ShortcutGroup({required this.title, required this.items});

  final String title;
  final List<_Shortcut> items;
}

class _GroupBlock extends StatelessWidget {
  const _GroupBlock({required this.group});

  final _ShortcutGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: colors.borderMuted),
        const SizedBox(height: 6),
        for (final item in group.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 122,
                  child: Row(
                    children: [
                      for (var i = 0; i < item.keys.length; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        KeyHint(item.keys[i]),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
