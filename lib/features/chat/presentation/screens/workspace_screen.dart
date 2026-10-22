import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/localization/language_selector_button.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/theme/theme_controller.dart';
import 'package:xstackapp/core/theme/theme_toggle_button.dart';
import 'package:xstackapp/core/widgets/app_status_bar.dart';
import 'package:xstackapp/core/widgets/brand.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/features/auth/presentation/controllers/auth_controller.dart';
import 'package:xstackapp/features/chat/data/realtime/chat_realtime_service.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/thread_controller.dart';
import 'package:xstackapp/features/chat/presentation/widgets/chat_list_pane.dart';
import 'package:xstackapp/features/chat/presentation/widgets/command_palette.dart';
import 'package:xstackapp/features/chat/presentation/widgets/details_pane.dart';
import 'package:xstackapp/features/chat/presentation/widgets/new_chat_dialog.dart';
import 'package:xstackapp/features/chat/presentation/widgets/profile_dialog.dart';
import 'package:xstackapp/features/chat/presentation/widgets/shortcuts_dialog.dart';
import 'package:xstackapp/features/chat/presentation/widgets/thread_pane.dart';
import 'package:xstackapp/features/chat/presentation/widgets/workspace_widgets.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class WorkspaceScreen extends HookConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 840;
    final veryWide = size.width >= 1180;

    final chatsState = ref.watch(chatsControllerProvider);
    final chats = ref.read(chatsControllerProvider.notifier);
    final selected = chatsState.selectedChat;
    final thread = ref.watch(threadControllerProvider);
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    final searchFocus = useFocusNode(debugLabel: 'chat-search');
    final composerFocus = useFocusNode(debugLabel: 'composer');
    final detailsVisible = useState(veryWide);
    final autoOpened = useRef<bool>(false);

    useEffect(() {
      Future.microtask(() => chats.refresh());
      return null;
    }, const []);

    // Background sync so the conversation keeps up with the other side of the
    // thread: messages every tick, chat summaries every third one. Ticks are
    // silent and merge-aware, so they never fight an in-flight send.
    useEffect(() {
      var summariesTick = 0;
      final timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!ref.read(chatsControllerProvider).hasLoaded) return;
        summariesTick += 1;
        if (summariesTick % 3 == 0) {
          ref.read(chatsControllerProvider.notifier).refresh(silent: true);
        }
        ref.read(threadControllerProvider.notifier).poll();
      });
      return timer.cancel;
    }, const []);

    // Follow the selection with the realtime hub room so push events for this
    // thread arrive the moment they happen.
    final selectedChatId = chatsState.selectedChatId;
    useEffect(() {
      if (selectedChatId != null) {
        ref.read(chatRealtimeServiceProvider).enterChat(selectedChatId);
      }
      return null;
    }, [selectedChatId]);

    useEffect(() {
      if (wide &&
          chatsState.hasLoaded &&
          selected == null &&
          !autoOpened.value &&
          chatsState.chats.isNotEmpty) {
        autoOpened.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          chats.openChat(chatsState.chats.first.id);
        });
      }
      return null;
    }, [chatsState.hasLoaded, selected, wide]);

    Future<void> openNewChat() async {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => const NewChatDialog(),
      );
    }

    Future<void> openShortcuts() async {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => const ShortcutsDialog(),
      );
    }

    Future<void> openProfile() async {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => ProfileDialog(
          onSignOut: () => ref.read(authControllerProvider.notifier).logout(),
          onLogs: () => context.push(Routes.logs),
        ),
      );
    }

    Future<void> openPalette() async {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => CommandPalette(
          onNewChat: () => openNewChat(),
          onProfile: () => openProfile(),
          onShortcuts: () => openShortcuts(),
          onToggleTheme: () =>
              ref.read(themeControllerProvider.notifier).toggleTheme(context),
          onRefresh: () => refreshAll(ref),
          onLogs: () => context.push(Routes.logs),
          onSignOut: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      );
    }

    void focusSearch() {
      if (!wide && selected != null) {
        chats.closeChat();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchFocus.requestFocus();
      });
    }

    void focusComposer() {
      if (selected != null) composerFocus.requestFocus();
    }

    void moveSelection(int delta) {
      final visible = chatsState.visibleChats;
      if (visible.isEmpty) return;
      final current = visible.indexWhere((c) => c.id == selected?.id);
      final next = current < 0
          ? 0
          : (current + delta).clamp(0, visible.length - 1);
      chats.openChat(visible[next].id);
    }

    void handleEscape() {
      if (composerFocus.hasFocus) {
        composerFocus.unfocus();
        return;
      }
      if (detailsVisible.value && veryWide) {
        detailsVisible.value = false;
        return;
      }
      if (!wide && selected != null) {
        chats.closeChat();
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            openPalette,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            openNewChat,
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () =>
            refreshAll(ref),
        const SingleActivator(
          LogicalKeyboardKey.keyL,
          control: true,
          shift: true,
        ): () =>
            ref.read(themeControllerProvider.notifier).toggleTheme(context),
        const SingleActivator(
          LogicalKeyboardKey.keyI,
          control: true,
          shift: true,
        ): () {
          if (veryWide) detailsVisible.value = !detailsVisible.value;
        },
        const SingleActivator(
          LogicalKeyboardKey.keyC,
          control: true,
          shift: true,
        ): focusComposer,
        const SingleActivator(LogicalKeyboardKey.comma, control: true):
            openProfile,
        const SingleActivator(LogicalKeyboardKey.slash, control: true):
            openShortcuts,
        const SingleActivator(
          LogicalKeyboardKey.keyD,
          control: true,
          shift: true,
        ): () =>
            context.push(Routes.logs),
        const SingleActivator(
          LogicalKeyboardKey.keyQ,
          control: true,
          shift: true,
        ): () =>
            ref.read(authControllerProvider.notifier).logout(),
        const SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): () =>
            moveSelection(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): () =>
            moveSelection(-1),
        const SingleActivator(LogicalKeyboardKey.escape): handleEscape,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                WorkspaceTopBar(
                  chatLabel: selected == null
                      ? null
                      : '${selected.sigil}${selected.displayName}',
                  userName: user?.displayName?.isNotEmpty == true
                      ? user!.displayName!
                      : (user?.username ?? user?.phoneNumber ?? ''),
                  wide: wide,
                  onPalette: openPalette,
                  onNewChat: openNewChat,
                  onProfile: openProfile,
                ),
                Expanded(
                  child: Row(
                    children: [
                      if (wide) ...[
                        SizedBox(
                          width: 264,
                          child: ChatListPane(
                            onNewChat: openNewChat,
                            searchFocusNode: searchFocus,
                          ),
                        ),
                        Container(width: 1, color: colors.border),
                      ],
                      Expanded(
                        child: selected == null
                            ? (wide
                                  ? _WelcomePane(
                                      onNewChat: openNewChat,
                                      onPalette: openPalette,
                                    )
                                  : ChatListPane(
                                      onNewChat: openNewChat,
                                      searchFocusNode: searchFocus,
                                    ))
                            : ThreadPane(
                                chat: selected,
                                composerFocusNode: composerFocus,
                                onBack: wide ? null : chats.closeChat,
                                onToggleDetails: veryWide
                                    ? () => detailsVisible.value =
                                          !detailsVisible.value
                                    : null,
                                detailsVisible: detailsVisible.value,
                                autoFocusComposer: wide,
                              ),
                      ),
                      if (veryWide &&
                          detailsVisible.value &&
                          selected != null) ...[
                        Container(width: 1, color: colors.border),
                        SizedBox(
                          width: 248,
                          child: DetailsPane(
                            chat: selected,
                            details: thread.details,
                            onClose: () => detailsVisible.value = false,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _WorkspaceStatusBar(
                  hasLoaded: chatsState.hasLoaded,
                  offline: chatsState.failure != null,
                  userName: user?.username ?? user?.phoneNumber,
                  chatLabel: selected == null
                      ? null
                      : '${selected.sigil}${selected.displayName}',
                  wide: wide,
                  l10n: l10n,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void refreshAll(WidgetRef ref) {
  ref.read(chatsControllerProvider.notifier).refresh(silent: true);
  ref.read(threadControllerProvider.notifier).refresh();
}

class WorkspaceTopBar extends StatelessWidget {
  const WorkspaceTopBar({
    super.key,
    required this.chatLabel,
    required this.userName,
    required this.wide,
    required this.onPalette,
    required this.onNewChat,
    required this.onProfile,
  });

  final String? chatLabel;
  final String userName;
  final bool wide;
  final VoidCallback onPalette;
  final VoidCallback onNewChat;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          const BrandWordmark(),
          const SizedBox(width: 12),
          Container(width: 1, height: 14, color: colors.border),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              children: [
                Text(
                  '~/chats',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: colors.textMuted,
                  ),
                ),
                if (chatLabel != null) ...[
                  Text(
                    ' / ',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      color: colors.textMuted,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      chatLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          if (wide)
            _SearchButton(onTap: onPalette)
          else
            IconButton(
              tooltip: '${l10n.workspaceCommands}  ctrl+k',
              icon: const Icon(Icons.search, size: 15),
              onPressed: onPalette,
            ),
          IconButton(
            tooltip: '${l10n.workspaceNewChat}  ctrl+n',
            icon: const Icon(Icons.add, size: 15),
            onPressed: onNewChat,
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 4),
          const LanguageSelectorButton(),
          const SizedBox(width: 8),
          _ProfileChip(name: userName, onTap: onProfile),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Tooltip(
      message: 'ctrl+k',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 196,
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 13, color: colors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.workspaceCommands,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: colors.textMuted,
                  ),
                ),
              ),
              const KeyHint('ctrl k', dim: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: 'ctrl+,',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 28,
          padding: const EdgeInsets.fromLTRB(3, 3, 8, 3),
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderMuted),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              InitialsAvatar(name: name, size: 20, accent: true),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePane extends StatelessWidget {
  const _WelcomePane({required this.onNewChat, required this.onPalette});

  final VoidCallback onNewChat;
  final VoidCallback onPalette;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r'$ xstack --workspace',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.workspacePickChat,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: colors.text,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.workspacePickChatHint,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  height: 1.7,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 26),
              Container(height: 1, color: colors.borderMuted),
              const SizedBox(height: 14),
              ShortcutHint(
                keys: const ['ctrl', 'k'],
                label: l10n.workspaceCommands,
                onTap: onPalette,
              ),
              const SizedBox(height: 8),
              ShortcutHint(
                keys: const ['ctrl', 'n'],
                label: l10n.workspaceNewChat,
                onTap: onNewChat,
              ),
              const SizedBox(height: 8),
              ShortcutHint(
                keys: const ['ctrl', '/'],
                label: l10n.workspaceShortcuts,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onNewChat,
                child: Text(l10n.workspaceNewChat),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceStatusBar extends StatelessWidget {
  const _WorkspaceStatusBar({
    required this.hasLoaded,
    required this.offline,
    required this.userName,
    required this.chatLabel,
    required this.wide,
    required this.l10n,
  });

  final bool hasLoaded;
  final bool offline;
  final String? userName;
  final String? chatLabel;
  final bool wide;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = offline
        ? colors.danger
        : (hasLoaded ? colors.success : colors.warning);
    final statusLabel = offline
        ? l10n.workspaceOffline
        : (hasLoaded ? l10n.workspaceConnected : l10n.workspaceSyncing);

    return AppStatusBar(
      left: [
        StatusDot(color: statusColor),
        const SizedBox(width: 6),
        StatusText(statusLabel, color: colors.textSecondary),
        if (wide) ...[
          const SizedBox(width: 14),
          StatusText('main'),
          const SizedBox(width: 14),
          StatusText(
            userName == null
                ? l10n.workspaceSignedInAs
                : '${l10n.workspaceSignedInAs} @$userName',
          ),
          if (chatLabel != null) ...[
            const SizedBox(width: 14),
            StatusText(chatLabel!),
          ],
        ],
      ],
      hints: wide
          ? [
              ShortcutHint(
                keys: const ['ctrl', 'k'],
                label: l10n.workspaceCommands,
              ),
              ShortcutHint(
                keys: const ['ctrl', 'n'],
                label: l10n.workspaceNewChat,
              ),
              ShortcutHint(
                keys: const ['ctrl', '/'],
                label: l10n.workspaceShortcuts,
              ),
            ]
          : const [],
      right: [
        StatusText('v0.1.0'),
        const SizedBox(width: 12),
        if (wide) ...[const StatusText('utf-8'), const SizedBox(width: 12)],
        StatusText(offline ? 'api.offline' : 'api.online'),
      ],
    );
  }
}
