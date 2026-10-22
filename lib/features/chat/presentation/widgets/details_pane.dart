import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xstackapp/core/theme/app_theme.dart';
import 'package:xstackapp/core/widgets/terminal_spinner.dart';
import 'package:xstackapp/features/chat/domain/entities/chat.dart';
import 'package:xstackapp/features/chat/presentation/controllers/presence_controller.dart';
import 'package:xstackapp/features/chat/presentation/widgets/workspace_widgets.dart';
import 'package:xstackapp/l10n/app_localizations.dart';

class DetailsPane extends StatelessWidget {
  const DetailsPane({
    super.key,
    required this.chat,
    required this.details,
    required this.onClose,
  });

  final ChatSummary chat;
  final ChatDetails? details;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final members = details?.members ?? const <ChatMember>[];
    final selfRole = details?.currentUserRole ?? chat.currentUserRole;

    final sorted = [...members]
      ..sort((a, b) {
        const order = {'owner': 0, 'admin': 1, 'member': 2};
        return (order[a.role] ?? 3).compareTo(order[b.role] ?? 3);
      });

    return Column(
      children: [
        PaneHeader(
          title: l10n.workspaceDetails,
          trailing: [
            IconButton(
              tooltip: '${l10n.workspaceClose}  esc',
              icon: const Icon(Icons.close, size: 14),
              onPressed: onClose,
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InitialsAvatar(
                    name: chat.displayName,
                    size: 34,
                    accent: true,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.displayName,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          chat.isGroup
                              ? l10n.workspaceMemberCount(members.length)
                              : chat.handle,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 10,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _InfoRow(
                label: l10n.workspaceFieldType,
                value: chat.isGroup
                    ? l10n.workspaceGroupChat
                    : l10n.workspaceDirectChat,
              ),
              _InfoRow(
                label: l10n.workspaceFieldRole,
                value: _roleLabel(l10n, selfRole),
              ),
              if (members.isNotEmpty)
                _InfoRow(
                  label: l10n.workspaceFieldMembers,
                  value: l10n.workspaceMemberCount(members.length),
                ),
              _InfoRow(
                label: l10n.workspaceFieldCreated,
                value: formatLongDate(chat.createdAt),
              ),
              _InfoRow(
                label: l10n.workspaceFieldId,
                value: chat.id.length > 8 ? chat.id.substring(0, 8) : chat.id,
                trailing: InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: chat.id));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.workspaceCopied)),
                      );
                    }
                  },
                  child: Icon(Icons.copy, size: 12, color: colors.textMuted),
                ),
              ),
              if (chat.isGroup) ...[
                const SizedBox(height: 22),
                SectionLabel(
                  l10n.workspaceMembers,
                  trailing: Text(
                    '${members.length}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 9,
                      color: colors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (details == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: TerminalSpinner(),
                  )
                else
                  for (final member in sorted) _MemberRow(member: member),
              ] else ...[
                const SizedBox(height: 22),
                SectionLabel(l10n.workspaceAccount),
                const SizedBox(height: 8),
                _DirectCard(chat: chat, details: details),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _roleLabel(AppLocalizations l10n, String role) {
    return switch (role) {
      'owner' => l10n.workspaceRoleOwner,
      'admin' => l10n.workspaceRoleAdmin,
      _ => l10n.workspaceRoleMember,
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 9,
                color: colors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 10,
                color: colors.textSecondary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.member});

  final ChatMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final presence = ref.watch(
      presenceControllerProvider.select(
        (state) => state[member.userId]?.isOnline == true,
      ),
    );
    final role = switch (member.role) {
      'owner' => l10n.workspaceRoleOwner,
      'admin' => l10n.workspaceRoleAdmin,
      _ => l10n.workspaceRoleMember,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          InitialsAvatar(name: member.name, size: 24),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: colors.text,
                  ),
                ),
                if (member.username != null && member.username!.isNotEmpty)
                  Text(
                    '@${member.username}',
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
          if (presence)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
            ),
          if (member.role != 'member')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: member.role == 'owner'
                    ? colors.accentMuted
                    : colors.surfaceMuted,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                role,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 8,
                  color: member.role == 'owner'
                      ? colors.accent
                      : colors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DirectCard extends StatelessWidget {
  const _DirectCard({required this.chat, required this.details});

  final ChatSummary chat;
  final ChatDetails? details;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final person = details?.members.isNotEmpty == true
        ? details!.members.first
        : null;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderMuted),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(name: chat.displayName, size: 26),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  chat.displayName,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (person != null) ...[
            _DirectLine(
              label: l10n.workspaceFieldPhone,
              value: person.phoneNumber,
            ),
            if (person.username != null)
              _DirectLine(
                label: l10n.workspaceFieldUser,
                value: '@${person.username}',
              ),
          ] else ...[
            _DirectLine(
              label: l10n.workspaceFieldPhone,
              value: chat.otherMemberPhone ?? '—',
            ),
            if (chat.otherMemberUsername != null)
              _DirectLine(
                label: l10n.workspaceFieldUser,
                value: '@${chat.otherMemberUsername}',
              ),
          ],
          const SizedBox(height: 2),
          Text(
            l10n.workspaceProfileBio,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 9,
              fontStyle: FontStyle.italic,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectLine extends StatelessWidget {
  const _DirectLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 9,
                color: colors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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
    );
  }
}
