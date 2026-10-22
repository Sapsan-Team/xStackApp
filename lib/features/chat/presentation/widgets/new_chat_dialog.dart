import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/errors/failures.dart';
import 'package:xstackapp/core/errors/failure_mapper.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/failure_banner.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/chat/data/repositories/chat_repository.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/features/chat/presentation/widgets/workspace_widgets.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class NewChatDialog extends HookConsumerWidget {
  const NewChatDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final repository = ref.read(chatRepositoryProvider);
    final chats = ref.read(chatsControllerProvider.notifier);

    final isGroup = useState(false);
    final query = useState('');
    final results = useState<List<UserSearchResult>>([]);
    final selectedIndex = useState(0);
    final selectedUsers = useState<Map<String, UserSearchResult>>({});
    final loading = useState(false);
    final creating = useState(false);
    final failure = useState<Failure?>(null);
    final titleController = useTextEditingController();
    final titleFocus = useFocusNode();

    Future<void> search(String value) async {
      loading.value = true;
      try {
        final found = await repository.searchUsers(value, limit: 30);
        results.value = found;
        if (selectedIndex.value >= found.length) {
          selectedIndex.value = found.isEmpty ? 0 : found.length - 1;
        }
        failure.value = null;
      } catch (error) {
        failure.value = failureFrom(error);
      } finally {
        loading.value = false;
      }
    }

    useEffect(() {
      var cancelled = false;
      final timer = Timer(const Duration(milliseconds: 220), () {
        if (!cancelled) {
          search(query.value);
        }
      });
      return () {
        cancelled = true;
        timer.cancel();
      };
    }, [query.value]);

    Future<void> startDirect(UserSearchResult user) async {
      if (creating.value) return;
      creating.value = true;
      try {
        final details = await repository.createDirectChat(user.id);
        await chats.refresh(silent: true);
        chats.openChat(details.id);
        if (context.mounted) Navigator.of(context).pop();
      } catch (error) {
        failure.value = failureFrom(error);
      } finally {
        creating.value = false;
      }
    }

    Future<void> startGroup() async {
      if (creating.value) return;
      final title = titleController.text.trim();
      if (title.isEmpty) {
        titleFocus.requestFocus();
        return;
      }
      creating.value = true;
      try {
        final details = await repository.createGroupChat(
          title,
          selectedUsers.value.keys.toList(growable: false),
        );
        await chats.refresh(silent: true);
        chats.openChat(details.id);
        if (context.mounted) Navigator.of(context).pop();
      } catch (error) {
        failure.value = failureFrom(error);
      } finally {
        creating.value = false;
      }
    }

    void toggleUser(UserSearchResult user) {
      final next = {...selectedUsers.value};
      if (next.containsKey(user.id)) {
        next.remove(user.id);
      } else {
        next[user.id] = user;
      }
      selectedUsers.value = next;
    }

    void move(int delta) {
      if (results.value.isEmpty) return;
      final next = (selectedIndex.value + delta) % results.value.length;
      selectedIndex.value = next < 0 ? results.value.length - 1 : next;
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).pop(),
        if (!isGroup.value)
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => move(1),
        if (!isGroup.value)
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => move(-1),
        if (!isGroup.value)
          const SingleActivator(LogicalKeyboardKey.enter): () {
            if (results.value.isNotEmpty) {
              startDirect(results.value[selectedIndex.value]);
            }
          },
        if (isGroup.value)
          const SingleActivator(LogicalKeyboardKey.enter): startGroup,
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 540,
          constraints: const BoxConstraints(maxHeight: 540),
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
                      l10n.workspaceNewChat,
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
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.borderMuted)),
                ),
                child: Row(
                  children: [
                    _ModeTab(
                      label: l10n.workspaceDirectMessage,
                      active: !isGroup.value,
                      onTap: () {
                        isGroup.value = false;
                        selectedIndex.value = 0;
                      },
                    ),
                    const SizedBox(width: 18),
                    _ModeTab(
                      label: l10n.workspaceNewGroup,
                      active: isGroup.value,
                      onTap: () {
                        isGroup.value = true;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          titleFocus.requestFocus();
                        });
                      },
                    ),
                    const Spacer(),
                    if (isGroup.value)
                      Text(
                        '${selectedUsers.value.length} ${l10n.workspaceSelected}',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 9,
                          color: colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              if (isGroup.value)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '#',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: TextField(
                            controller: titleController,
                            focusNode: titleFocus,
                            onSubmitted: (_) => startGroup(),
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
                              hintText: l10n.workspaceGroupTitleHint,
                              hintStyle: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 13, color: colors.textMuted),
                      const SizedBox(width: 7),
                      Expanded(
                        child: TextField(
                          autofocus: !isGroup.value,
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
                            hintText: l10n.workspaceNewChatHint,
                            hintStyle: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      if (loading.value) const TerminalSpinner(),
                    ],
                  ),
                ),
              ),
              if (failure.value != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: FailureBanner(
                    failure: failure.value!,
                    compact: true,
                    onDismiss: () => failure.value = null,
                  ),
                ),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: Builder(
                    builder: (context) {
                      if (results.value.isEmpty && !loading.value) {
                        return SizedBox(
                          height: 150,
                          child: EmptyState(
                            title: l10n.workspaceNoUsers,
                            hint: l10n.workspaceNewChatHint,
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        itemCount: results.value.length,
                        itemBuilder: (context, index) {
                          final user = results.value[index];
                          final checked = selectedUsers.value.containsKey(
                            user.id,
                          );
                          final active =
                              !isGroup.value && selectedIndex.value == index;

                          return _UserRow(
                            user: user,
                            active: active,
                            checked: isGroup.value ? checked : null,
                            onTap: () {
                              selectedIndex.value = index;
                              if (isGroup.value) {
                                toggleUser(user);
                              } else {
                                startDirect(user);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Row(
                  children: [
                    if (!isGroup.value)
                      ShortcutHint(
                        keys: const ['↑', '↓'],
                        label: l10n.workspaceSelect,
                      )
                    else
                      ShortcutHint(
                        keys: const ['enter'],
                        label: l10n.workspaceCreate,
                      ),
                    const Spacer(),
                    if (isGroup.value)
                      FilledButton(
                        onPressed: creating.value ? null : startGroup,
                        child: creating.value
                            ? TerminalSpinner(color: colors.canvas)
                            : Text(l10n.workspaceCreate),
                      )
                    else
                      Text(
                        l10n.workspacePressEnter,
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

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? colors.text : colors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.active,
    required this.checked,
    required this.onTap,
  });

  final UserSearchResult user;
  final bool active;
  final bool? checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? colors.accentMuted : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            InitialsAvatar(name: user.name, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11.5,
                      color: colors.text,
                    ),
                  ),
                  Text(
                    user.handle,
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
            if (checked != null)
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked! ? colors.accent : Colors.transparent,
                  border: Border.all(
                    color: checked! ? colors.accent : colors.border,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: checked!
                    ? Icon(Icons.check, size: 12, color: colors.canvas)
                    : null,
              )
            else if (active)
              KeyHint('enter', dim: true),
          ],
        ),
      ),
    );
  }
}
