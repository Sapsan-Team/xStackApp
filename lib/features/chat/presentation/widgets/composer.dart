import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/key_hint.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/chat/data/realtime/chat_realtime_service.dart';
import 'package:xstackapp/features/chat/presentation/controllers/chats_controller.dart';
import 'package:xstackapp/features/chat/presentation/controllers/thread_controller.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

/// Sends typing activity over the realtime hub, throttled so a burst of
/// keystrokes produces at most one event per interval.
void _notifyTyping(
  WidgetRef ref,
  ValueNotifier<DateTime?> lastTypingAt,
  String text,
  String? chatId,
) {
  if (chatId == null || text.trim().isEmpty) return;
  final now = DateTime.now();
  final previous = lastTypingAt.value;
  if (previous != null &&
      now.difference(previous) < const Duration(seconds: 2)) {
    return;
  }
  lastTypingAt.value = now;
  ref.read(chatRealtimeServiceProvider).sendTyping(chatId);
}

class MessageComposer extends HookConsumerWidget {
  const MessageComposer({
    super.key,
    required this.focusNode,
    required this.enabled,
  });

  final FocusNode focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final controller = useTextEditingController();
    final focused = useState(false);
    final textLength = useState(0);
    final thread = ref.watch(threadControllerProvider);
    final selectedChatId = ref.watch(chatsControllerProvider).selectedChatId;
    final lastTypingAt = useState<DateTime?>(null);
    final isSending = thread.isSending;

    useEffect(() {
      void listener() => focused.value = focusNode.hasFocus;
      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode]);

    Future<void> send() async {
      if (!enabled || isSending) return;
      final text = controller.text;
      if (text.trim().isEmpty) return;

      controller.clear();
      textLength.value = 0;
      final ok = await ref.read(threadControllerProvider.notifier).send(text);
      if (!ok && controller.text.isEmpty) {
        controller.text = text;
        textLength.value = text.length;
        if (!focusNode.hasFocus) focusNode.requestFocus();
      }
      if (focusNode.hasFocus) focusNode.requestFocus();
    }

    final borderColor = focused.value ? colors.accent : colors.border;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CallbackShortcuts(
            bindings: {const SingleActivator(LogicalKeyboardKey.enter): send},
            child: Container(
              constraints: const BoxConstraints(minHeight: 38),
              padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
              decoration: BoxDecoration(
                color: colors.canvas,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '>',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: focused.value ? colors.accent : colors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 6,
                      autofocus: false,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      autocorrect: false,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12.5,
                        height: 1.5,
                        color: colors.text,
                      ),
                      cursorWidth: 1.5,
                      onChanged: (value) {
                        textLength.value = value.length;
                        _notifyTyping(ref, lastTypingAt, value, selectedChatId);
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 3),
                        hint: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Text(
                            l10n.workspaceMessageHint,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12.5,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isSending)
                    const Padding(
                      padding: EdgeInsets.only(top: 5, right: 4),
                      child: TerminalSpinner(),
                    ),
                  _SendButton(
                    enabled: enabled && textLength.value > 0 && !isSending,
                    onTap: send,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.workspaceSendHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    color: colors.textMuted,
                  ),
                ),
              ),
              if (textLength.value > 3600)
                Text(
                  '${textLength.value}/4000',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 9,
                    color: textLength.value >= 4000
                        ? colors.danger
                        : colors.textMuted,
                  ),
                )
              else
                const KeyHint('enter', dim: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: 'send  enter',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? colors.accent : colors.surfaceMuted,
            border: Border.all(
              color: enabled ? colors.accent : colors.borderMuted,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.arrow_upward,
            size: 14,
            color: enabled
                ? Theme.of(context).colorScheme.onPrimary
                : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
