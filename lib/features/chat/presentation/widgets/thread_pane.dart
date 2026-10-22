import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/router/routes.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/failure_banner.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/thread_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/typing_controller.dart';
import 'package:xstackapp/features/chat/presentation/widgets/composer.dart';
import 'package:xstackapp/features/chat/presentation/widgets/workspace_widgets.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class ThreadPane extends HookConsumerWidget {
  const ThreadPane({
    super.key,
    required this.chat,
    required this.composerFocusNode,
    this.onBack,
    this.onToggleDetails,
    this.detailsVisible = false,
    this.autoFocusComposer = true,
  });

  final ChatSummary chat;
  final FocusNode composerFocusNode;
  final VoidCallback? onBack;
  final VoidCallback? onToggleDetails;
  final bool detailsVisible;
  final bool autoFocusComposer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = ref.watch(threadControllerProvider);
    final notifier = ref.read(threadControllerProvider.notifier);
    final scroll = useScrollController();
    final lastCount = useRef<int>(0);

    final isCurrentChat = thread.chatId == chat.id;
    final messages = isCurrentChat ? thread.messages : const <ChatMessage>[];
    final details = isCurrentChat ? thread.details : null;
    final memberCount = details?.members.length;

    useEffect(() {
      lastCount.value = 0;
      return null;
    }, [chat.id]);

    useEffect(() {
      if (autoFocusComposer && isCurrentChat && !thread.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) composerFocusNode.requestFocus();
        });
      }
      return null;
    }, [chat.id, thread.isLoading]);

    useEffect(() {
      final count = messages.length;
      if (count == 0) {
        lastCount.value = 0;
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scroll.hasClients) return;
        final position = scroll.position;
        // The thread is reversed: offset 0 is the newest message, while
        // maxScrollExtent is the oldest one.
        final nearBottom = position.pixels <= 24 || lastCount.value == 0;
        if (nearBottom) {
          if (lastCount.value == 0) {
            scroll.jumpTo(0);
          } else {
            scroll.animateTo(
              0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
            );
          }
        }
        lastCount.value = count;
      });
      return null;
    }, [messages.length, thread.isLoading]);

    return Column(
      children: [
        _ThreadHeader(
          chat: chat,
          memberCount: memberCount,
          onBack: onBack,
          onRefresh: () async {
            await notifier.refresh();
            await ref
                .read(chatsControllerProvider.notifier)
                .refresh(silent: true);
          },
          onToggleDetails: onToggleDetails,
          detailsVisible: detailsVisible,
        ),
        Expanded(
          child: _ThreadBody(
            chat: chat,
            thread: thread,
            messages: messages,
            scroll: scroll,
            isCurrentChat: isCurrentChat,
            onRetry: () => notifier.open(chat.id),
          ),
        ),
        if (isCurrentChat && thread.failure != null && messages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: FailureBanner(
              failure: thread.failure!,
              compact: true,
              onDismiss: notifier.clearFailure,
            ),
          ),
        _TypingIndicator(chatId: chat.id),
        MessageComposer(
          focusNode: composerFocusNode,
          enabled: isCurrentChat && !thread.isLoading,
        ),
      ],
    );
  }
}

/// A quiet status line right above the composer: who is typing right now.
class _TypingIndicator extends HookConsumerWidget {
  const _TypingIndicator({required this.chatId});

  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final users =
        ref.watch(typingControllerProvider)[chatId] ?? const <TypingUser>[];
    if (users.isEmpty) return const SizedBox.shrink();

    final names = users.map((user) => user.name).join(', ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 2),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '[',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(width: 34, height: 13, child: TerminalSpinner()),
                Text(
                  ']',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            l10n.workspaceSomeoneTyping(names),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadHeader extends StatelessWidget {
  const _ThreadHeader({
    required this.chat,
    required this.onBack,
    required this.onRefresh,
    required this.memberCount,
    required this.onToggleDetails,
    required this.detailsVisible,
  });

  final ChatSummary chat;
  final int? memberCount;
  final VoidCallback? onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback? onToggleDetails;
  final bool detailsVisible;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final typeLabel = chat.isGroup ? l10n.workspaceGroup : l10n.workspaceDirect;
    final members = memberCount == null
        ? null
        : l10n.workspaceMemberCount(memberCount!);
    final meta = [
      typeLabel,
      ?members,
      if (!chat.isGroup) chat.handle,
    ].join(' / ');

    return Container(
      height: 50,
      padding: EdgeInsets.only(left: onBack != null ? 4 : 14, right: 6),
      decoration: BoxDecoration(
        color: colors.canvas,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              tooltip: l10n.workspaceClose,
              icon: const Icon(Icons.arrow_back, size: 16),
              onPressed: onBack,
            ),
          if (onBack == null) const SizedBox(width: 2),
          Text(
            chat.sigil,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: '${l10n.workspaceRefresh}  ctrl+r',
            icon: const Icon(Icons.refresh, size: 15),
            onPressed: () => onRefresh(),
          ),
          if (onToggleDetails != null)
            IconButton(
              tooltip: '${l10n.workspaceToggleDetails}  ctrl+shift+i',
              icon: Icon(
                Icons.view_sidebar_outlined,
                size: 15,
                color: detailsVisible ? colors.accent : null,
              ),
              onPressed: onToggleDetails,
            ),
          PopupMenuButton<String>(
            tooltip: l10n.workspaceDetails,
            icon: const Icon(Icons.more_horiz, size: 16),
            offset: const Offset(0, 34),
            onSelected: (value) async {
              if (value == 'copy') {
                await Clipboard.setData(ClipboardData(text: chat.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.workspaceCopied)));
                }
              } else if (value == 'logs') {
                context.push(Routes.logs);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'copy',
                height: 32,
                child: _MenuLabel(
                  icon: Icons.copy,
                  label: '${l10n.workspaceCopy} chat id',
                ),
              ),
              PopupMenuItem(
                value: 'logs',
                height: 32,
                child: _MenuLabel(
                  icon: Icons.terminal,
                  label: l10n.workspaceLogs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 13, color: colors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            color: colors.text,
          ),
        ),
      ],
    );
  }
}

class _ThreadBody extends StatelessWidget {
  const _ThreadBody({
    required this.chat,
    required this.thread,
    required this.messages,
    required this.scroll,
    required this.isCurrentChat,
    required this.onRetry,
  });

  final ChatSummary chat;
  final ThreadState thread;
  final List<ChatMessage> messages;
  final ScrollController scroll;
  final bool isCurrentChat;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!isCurrentChat || (thread.isLoading && messages.isEmpty)) {
      return Center(child: TerminalSpinner(label: l10n.workspaceLoadingThread));
    }

    if (thread.failure != null && messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FailureBanner(failure: thread.failure!),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(l10n.workspaceRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return EmptyState(
        title: l10n.workspaceNoMessages,
        hint: l10n.workspaceNoMessagesHint,
        actions: [
          ShortcutHint(keys: const ['enter'], label: l10n.workspaceStartTyping),
        ],
      );
    }

    final items = <Object>[];
    DateTime? previousDay;
    for (final message in messages) {
      final day = message.createdAt.toLocal();
      if (previousDay == null || !isSameDay(previousDay, day)) {
        items.add(_DayMarker(day));
        previousDay = day;
      }
      items.add(message);
    }

    return Scrollbar(
      controller: scroll,
      child: ListView.builder(
        controller: scroll,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          // The list is painted bottom-up, so the newest entry sits at the
          // bottom and the day separator floats above its first message.
          final reverseIndex = items.length - 1 - index;
          final item = items[reverseIndex];
          if (item is _DayMarker) {
            return _DaySeparator(day: item.day);
          }

          final message = item as ChatMessage;
          final previous =
              reverseIndex > 0 && items[reverseIndex - 1] is ChatMessage
              ? items[reverseIndex - 1] as ChatMessage
              : null;
          final continuation =
              previous != null &&
              _sameAuthor(previous, message) &&
              message.createdAt.difference(previous.createdAt).inMinutes < 4;

          return _MessageRow(message: message, continuation: continuation);
        },
      ),
    );
  }

  bool _sameAuthor(ChatMessage a, ChatMessage b) {
    if (a.senderId != null && b.senderId != null) {
      return a.senderId == b.senderId;
    }
    return a.isMine == b.isMine && a.authorName == b.authorName;
  }
}

class _DayMarker {
  const _DayMarker(this.day);

  final DateTime day;
}

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final local = day.toLocal();
    final difference = today
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;

    final label = switch (difference) {
      0 => l10n.workspaceToday,
      1 => l10n.workspaceYesterday,
      _ => formatLongDate(local),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: colors.borderMuted)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 9,
                color: colors.textMuted,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: colors.borderMuted)),
        ],
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.continuation});

  final ChatMessage message;
  final bool continuation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final content = message.isDeleted
        ? l10n.workspaceDeleted
        : (message.content ?? '');

    return Opacity(
      opacity: message.isPending ? 0.55 : 1,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, continuation ? 1 : 7, 18, 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 38,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  continuation ? '' : formatClock(message.createdAt),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    color: colors.textMuted,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!continuation)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              message.isMine
                                  ? l10n.workspaceYouAre
                                  : message.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: message.isMine
                                    ? colors.accent
                                    : colors.textSecondary,
                              ),
                            ),
                          ),
                          if (!message.isMine &&
                              message.senderUsername != null &&
                              message.senderUsername!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '@${message.senderUsername}',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 9,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                          if (message.isEdited) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(${l10n.workspaceEdited})',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 9,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                          if (message.isPending) ...[
                            const SizedBox(width: 8),
                            Text(
                              l10n.workspaceSending,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 9,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  SelectableText(
                    content,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12.5,
                      height: 1.55,
                      color: message.isDeleted ? colors.textMuted : colors.text,
                      fontStyle: message.isDeleted
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
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
