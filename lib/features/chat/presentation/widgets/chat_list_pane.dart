import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/failure_banner.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/features/chat/presentation/widgets/workspace_widgets.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class ChatListPane extends ConsumerWidget {
  const ChatListPane({
    super.key,
    required this.onNewChat,
    required this.searchFocusNode,
    this.showClose = false,
  });

  final VoidCallback onNewChat;
  final FocusNode searchFocusNode;
  final bool showClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(chatsControllerProvider);
    final notifier = ref.read(chatsControllerProvider.notifier);
    final visible = state.visibleChats;

    return Column(
      children: [
        PaneHeader(
          title: l10n.workspaceChats,
          subtitle: state.hasLoaded ? '${state.chats.length}' : null,
          trailing: [
            IconButton(
              tooltip: '${l10n.workspaceNewChat}  ctrl+n',
              icon: const Icon(Icons.add, size: 15),
              onPressed: onNewChat,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Container(
            height: 30,
            padding: const EdgeInsets.only(left: 8, right: 5),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 13, color: colors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    focusNode: searchFocusNode,
                    onChanged: notifier.setQuery,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: colors.text,
                    ),
                    cursorWidth: 1.4,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: l10n.workspaceFilterChats,
                      hintStyle: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
                if (state.query.isEmpty)
                  const KeyHint('ctrl f', dim: true)
                else
                  InkWell(
                    onTap: () => notifier.setQuery(''),
                    child: Icon(Icons.close, size: 12, color: colors.textMuted),
                  ),
              ],
            ),
          ),
        ),
        _FilterRow(state: state, notifier: notifier),
        Container(height: 1, color: colors.borderMuted),
        Expanded(
          child: Builder(
            builder: (context) {
              if (state.failure != null && state.chats.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FailureBanner(
                        failure: state.failure!,
                        compact: true,
                        onDismiss: notifier.clearFailure,
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => notifier.refresh(),
                        child: Text(l10n.workspaceRetry),
                      ),
                    ],
                  ),
                );
              }

              if (state.isLoading && !state.hasLoaded) {
                return Center(
                  child: TerminalSpinner(label: l10n.workspaceLoading),
                );
              }

              if (state.chats.isEmpty) {
                return EmptyState(
                  title: l10n.workspaceNoChats,
                  hint: l10n.workspaceNoChatsHint,
                  actions: [
                    TextButton(
                      onPressed: onNewChat,
                      child: Text(l10n.workspaceNewChat),
                    ),
                  ],
                );
              }

              if (visible.isEmpty) {
                return EmptyState(
                  title: l10n.workspaceNoFilterResults,
                  hint: l10n.workspaceNoFilterResultsHint,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final chat = visible[index];
                  return _ChatRow(
                    chat: chat,
                    selected: chat.id == state.selectedChatId,
                    onTap: () => notifier.openChat(chat.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.state, required this.notifier});

  final ChatsState state;
  final ChatsController notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = state.chats.where((c) => c.unreadCount > 0).length;
    final groups = state.chats.where((c) => c.isGroup).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: Row(
        children: [
          _FilterTab(
            label: l10n.workspaceFilterAll,
            count: state.chats.length,
            active: state.filter == ChatFilter.all,
            onTap: () => notifier.setFilter(ChatFilter.all),
          ),
          const SizedBox(width: 12),
          _FilterTab(
            label: l10n.workspaceFilterUnread,
            count: unread,
            active: state.filter == ChatFilter.unread,
            onTap: () => notifier.setFilter(ChatFilter.unread),
          ),
          const SizedBox(width: 12),
          _FilterTab(
            label: l10n.workspaceFilterGroups,
            count: groups,
            active: state.filter == ChatFilter.groups,
            onTap: () => notifier.setFilter(ChatFilter.groups),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? colors.text : colors.textMuted,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 9,
                color: active ? colors.accent : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.chat,
    required this.selected,
    required this.onTap,
  });

  final ChatSummary chat;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final last = chat.lastMessage;

    String preview;
    if (last == null) {
      preview = l10n.workspaceNoMessages;
    } else if (last.isDeleted) {
      preview = l10n.workspaceDeleted;
    } else {
      final content = last.content ?? '';
      preview = chat.isGroup && last.senderName != null
          ? '${last.senderName}: $content'
          : content;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceMuted : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: selected ? colors.accent : Colors.transparent,
              width: 2,
            ),
            bottom: BorderSide(color: colors.borderMuted),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 16,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  chat.sigil,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? colors.accent : colors.textMuted,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: colors.text,
                          ),
                        ),
                      ),
                      if (last != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          formatChatTimestamp(last.createdAt),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 9,
                            color: chat.unreadCount > 0
                                ? colors.accent
                                : colors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 10.5,
                            height: 1.35,
                            color: chat.unreadCount > 0
                                ? colors.textSecondary
                                : colors.textMuted,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.accent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: colors.canvas,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
