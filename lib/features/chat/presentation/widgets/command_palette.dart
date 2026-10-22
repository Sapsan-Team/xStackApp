import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class CommandPalette extends HookConsumerWidget {
  const CommandPalette({
    super.key,
    required this.onNewChat,
    required this.onProfile,
    required this.onShortcuts,
    required this.onToggleTheme,
    required this.onRefresh,
    required this.onLogs,
    required this.onSignOut,
  });

  final VoidCallback onNewChat;
  final VoidCallback onProfile;
  final VoidCallback onShortcuts;
  final VoidCallback onToggleTheme;
  final VoidCallback onRefresh;
  final VoidCallback onLogs;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final query = useState('');
    final selected = useState(0);
    final controller = useTextEditingController();
    final scroll = useScrollController();
    final chats = ref.watch(chatsControllerProvider).chats;

    void close() => Navigator.of(context).pop();

    void run(VoidCallback action) {
      close();
      action();
    }

    final actions = <_Command>[
      _Command(
        label: l10n.workspaceNewChatAction,
        keys: const ['ctrl', 'n'],
        glyph: '+',
        run: () => run(onNewChat),
      ),
      _Command(
        label: l10n.workspaceOpenProfileAction,
        keys: const ['ctrl', ','],
        glyph: '@',
        run: () => run(onProfile),
      ),
      _Command(
        label: l10n.workspaceShowShortcutsAction,
        keys: const ['ctrl', '/'],
        glyph: '?',
        run: () => run(onShortcuts),
      ),
      _Command(
        label: l10n.workspaceToggleThemeAction,
        keys: const ['ctrl', 'shift', 'l'],
        glyph: '◐',
        run: () => run(onToggleTheme),
      ),
      _Command(
        label: l10n.workspaceRefreshAction,
        keys: const ['ctrl', 'r'],
        glyph: '↻',
        run: () => run(onRefresh),
      ),
      _Command(
        label: l10n.workspaceOpenLogs,
        keys: const ['ctrl', 'shift', 'd'],
        glyph: '≡',
        run: () => run(onLogs),
      ),
      _Command(
        label: l10n.workspaceSignOutAction,
        keys: const [],
        glyph: '×',
        run: () => run(onSignOut),
      ),
    ];

    final needle = query.value.trim().toLowerCase();
    final filteredActions = actions
        .where((a) => needle.isEmpty || a.label.toLowerCase().contains(needle))
        .toList(growable: false);
    final filteredChats = chats
        .where(
          (chat) =>
              needle.isEmpty ||
              chat.displayName.toLowerCase().contains(needle) ||
              chat.handle.toLowerCase().contains(needle),
        )
        .take(12)
        .toList(growable: false);

    final commands = <_Command>[
      ...filteredActions,
      for (final chat in filteredChats)
        _Command(
          label: chat.displayName,
          hint: chat.isGroup ? l10n.workspaceGroup : l10n.workspaceDirect,
          keys: const [],
          glyph: chat.sigil,
          run: () {
            close();
            ref.read(chatsControllerProvider.notifier).openChat(chat.id);
          },
        ),
    ];

    if (selected.value >= commands.length) {
      selected.value = commands.isEmpty ? 0 : commands.length - 1;
    }

    useEffect(() {
      selected.value = 0;
      return null;
    }, [query.value]);

    useEffect(() {
      if (!scroll.hasClients) return null;
      final hasActions = filteredActions.isNotEmpty;
      final hasChats = filteredChats.isNotEmpty;
      final actionOffset = hasActions ? 24 : 0;
      final chatHeader = hasChats ? 24 : 0;
      final row = selected.value < filteredActions.length
          ? actionOffset + selected.value
          : actionOffset +
                (hasActions ? 0 : 0) +
                (hasChats ? chatHeader : 0) +
                (selected.value - filteredActions.length);
      final target = row * 34.0;
      if (target < scroll.offset) {
        scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      } else if (target > scroll.offset + 280) {
        scroll.animateTo(
          target - 200,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
      return null;
    }, [selected.value]);

    void move(int delta) {
      if (commands.isEmpty) return;
      selected.value = (selected.value + delta) % commands.length;
      if (selected.value < 0) selected.value = commands.length - 1;
    }

    void execute() {
      if (commands.isEmpty) return;
      commands[selected.value].run();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => move(-1),
        const SingleActivator(LogicalKeyboardKey.escape): close,
        const SingleActivator(LogicalKeyboardKey.enter): execute,
      },
      child: Dialog(
        alignment: Alignment.topCenter,
        insetPadding: EdgeInsets.only(
          top: MediaQuery.sizeOf(context).height * 0.12,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxHeight: 430),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.only(left: 12, right: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    Text(
                      '>',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: (value) => query.value = value,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: colors.text,
                        ),
                        cursorWidth: 1.5,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: l10n.workspaceCommandHint,
                          hintStyle: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: close,
                      borderRadius: BorderRadius.circular(3),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: KeyHint('esc'),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: commands.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '\$ ${l10n.workspaceNoResults}',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            color: colors.textMuted,
                          ),
                        ),
                      )
                    : ListView(
                        controller: scroll,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        children: [
                          if (filteredActions.isNotEmpty) ...[
                            _SectionHeader(l10n.workspaceActions),
                            for (var i = 0; i < filteredActions.length; i++)
                              _CommandRow(
                                command: filteredActions[i],
                                selected: selected.value == i,
                                onTap: filteredActions[i].run,
                                onHover: () => selected.value = i,
                              ),
                          ],
                          if (filteredChats.isNotEmpty) ...[
                            _SectionHeader(l10n.workspaceConversations),
                            for (var i = 0; i < filteredChats.length; i++)
                              _CommandRow(
                                command: commands[filteredActions.length + i],
                                selected:
                                    selected.value ==
                                    filteredActions.length + i,
                                onTap: commands[filteredActions.length + i].run,
                                onHover: () =>
                                    selected.value = filteredActions.length + i,
                              ),
                          ],
                        ],
                      ),
              ),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    ShortcutHint(
                      keys: const ['↑', '↓'],
                      label: l10n.workspaceNavigate,
                    ),
                    const SizedBox(width: 14),
                    ShortcutHint(
                      keys: const ['enter'],
                      label: l10n.workspaceRun,
                    ),
                    const SizedBox(width: 14),
                    ShortcutHint(
                      keys: const ['esc'],
                      label: l10n.workspaceClose,
                    ),
                    const Spacer(),
                    Text(
                      '${commands.length}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 9,
                        color: colors.textMuted,
                      ),
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

class _Command {
  const _Command({
    required this.label,
    required this.glyph,
    required this.run,
    this.keys = const [],
    this.hint,
  });

  final String label;
  final String? hint;
  final String glyph;
  final List<String> keys;
  final VoidCallback run;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  const _CommandRow({
    required this.command,
    required this.selected,
    required this.onTap,
    required this.onHover,
  });

  final _Command command;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? colors.accentMuted : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: selected ? colors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: Text(
                  command.glyph,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? colors.accent : colors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  command.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11.5,
                    color: colors.text,
                  ),
                ),
              ),
              if (command.hint != null) ...[
                const SizedBox(width: 8),
                Text(
                  command.hint!,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    color: colors.textMuted,
                  ),
                ),
              ],
              if (command.keys.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    for (var i = 0; i < command.keys.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      KeyHint(command.keys[i], dim: !selected),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
